import Foundation
import UIKit

/// Держит локальную модель разбора диктовок.
///
/// Модель весит сотни мегабайт и на экране сканирования соседствует с сессией
/// камеры, поэтому грузим её лениво — при первом разборе, а не на старте
/// приложения — и отпускаем, когда система просит освободить память.
@MainActor
public final class DExaminationNeuralModelProvider {
    private let systemPrompt: String
    private let parameters: DExaminationGenerationParameters
    private var loadedModel: (any DExaminationNeuralModelProtocol)?
    private var loadingTask: Task<any DExaminationNeuralModelProtocol, any Error>?
    private var memoryWarningObserver: (any NSObjectProtocol)?

    /// Доступность не требует загрузки модели — только проверок памяти и системы,
    /// поэтому её можно спрашивать откуда угодно, например при построении экрана.
    public nonisolated var isAvailable: Bool {
        if #available(iOS 26.0, *),
           DExaminationNeuralModelFoundationModels.isAvailable(parameters: parameters)
        {
            return true
        }

        return DExaminationNeuralModelMLX.isAvailable(parameters: parameters)
    }

    public init(
        systemPrompt: String,
        parameters: DExaminationGenerationParameters
    ) {
        self.systemPrompt = systemPrompt
        self.parameters = parameters

        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.unload()
            }
        }
    }

    deinit {
        if let memoryWarningObserver {
            NotificationCenter.default.removeObserver(memoryWarningObserver)
        }
    }

    public func model() async throws -> any DExaminationNeuralModelProtocol {
        if let loadedModel {
            return loadedModel
        }
        // Пока идёт загрузка, параллельные вызовы ждут её, а не грузят модель повторно.
        if let loadingTask {
            return try await loadingTask.value
        }

        let systemPrompt = systemPrompt
        let parameters = parameters
        let task = Task { () async throws -> any DExaminationNeuralModelProtocol in
            // Выбираем реализацию здесь же, а не заранее: доступность зависит только
            // от параметров и системы, и повторная проверка ничего не грузит.
            if #available(iOS 26.0, *),
               DExaminationNeuralModelFoundationModels.isAvailable(parameters: parameters)
            {
                return DExaminationNeuralModelFoundationModels(
                    systemPrompt: systemPrompt,
                    parameters: parameters
                )
            }
            if DExaminationNeuralModelMLX.isAvailable(parameters: parameters) {
                return try await DExaminationNeuralModelMLX(
                    systemPrompt: systemPrompt,
                    parameters: parameters
                )
            }

            throw DExaminationNeuralModelError.unavailable
        }
        loadingTask = task

        defer { loadingTask = nil }
        let model = try await task.value
        loadedModel = model

        return model
    }

    public func unload() {
        loadedModel = nil
    }
}
