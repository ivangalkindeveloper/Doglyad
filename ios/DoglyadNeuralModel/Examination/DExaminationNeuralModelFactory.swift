import Foundation
import UIKit

/// Создаёт и держит локальную модель разбора диктовок, выбирая её реализацию
/// (Foundation Models или MLX) по доступности на текущей системе и по языку
/// диктовки.
///
/// Модель весит сотни мегабайт и на экране сканирования соседствует с сессией
/// камеры, поэтому грузим её лениво — при первом разборе или прогреве, а не на
/// старте приложения — и отпускаем, когда система просит освободить память.
@MainActor
public final class DExaminationNeuralModelFactory {
    private let locale: Locale
    private let systemPrompt: String
    private let parameters: DExaminationGenerationParameters
    private var loadedModel: (any DExaminationNeuralModelProtocol)?
    private var loadingTask: Task<any DExaminationNeuralModelProtocol, any Error>?
    private var memoryWarningObserver: (any NSObjectProtocol)?

    /// Доступность не требует загрузки модели — только проверок памяти, системы
    /// и языка, поэтому её можно спрашивать откуда угодно, например при
    /// построении экрана.
    public nonisolated var isAvailable: Bool {
        if #available(iOS 26.0, *),
           DExaminationNeuralModelFoundationModels.isAvailable(locale: locale, parameters: parameters)
        {
            return true
        }

        return DExaminationNeuralModelMLX.isAvailable(locale: locale, parameters: parameters)
    }

    public init(
        locale: Locale,
        systemPrompt: String,
        parameters: DExaminationGenerationParameters
    ) {
        self.locale = locale
        self.systemPrompt = systemPrompt
        self.parameters = parameters

        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.unload()
            }
        }
    }

    deinit {
        if let memoryWarningObserver {
            NotificationCenter.default.removeObserver(memoryWarningObserver)
        }
    }

    /// Поднимает модель заранее, не дожидаясь разбора. Вызывается на старте
    /// диктовки: пока врач говорит, загрузка весов и инициализация успевают
    /// пройти в фоне, иначе он ждал бы их уже после того, как закончил.
    public func prewarm() {
        Task { [weak self] in
            guard let model = try? await self?.model() else { return }

            model.prewarm()
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

        let locale = locale
        let systemPrompt = systemPrompt
        let parameters = parameters
        let task = Task { () async throws -> any DExaminationNeuralModelProtocol in
            // Выбираем реализацию здесь же, а не заранее: доступность зависит только
            // от параметров, системы и языка, и повторная проверка ничего не грузит.
            if #available(iOS 26.0, *),
               DExaminationNeuralModelFoundationModels.isAvailable(locale: locale, parameters: parameters)
            {
                return DExaminationNeuralModelFoundationModels(
                    systemPrompt: systemPrompt,
                    parameters: parameters
                )
            }
            if DExaminationNeuralModelMLX.isAvailable(locale: locale, parameters: parameters) {
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
