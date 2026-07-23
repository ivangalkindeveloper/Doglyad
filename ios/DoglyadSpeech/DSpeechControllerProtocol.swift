import Combine
import Foundation

/// Контроллер преобразования речи в текст.
///
/// Наблюдаемый объект: экран сканирования подписывается на `status`, `text` и
/// `audioMeter`, чтобы отражать ход диктовки. Конкретную реализацию выбирает
/// ``DSpeechFactory`` по доступности на текущей системе и поддержке локали.
///
/// Требование `ObjectWillChangePublisher == ObservableObjectPublisher` позволяет
/// потребителю подписаться на `objectWillChange` через экзистенциал
/// `any DSpeechControllerProtocol`, не зная конкретный тип.
@MainActor
public protocol DSpeechControllerProtocol: ObservableObject
    where ObjectWillChangePublisher == ObservableObjectPublisher
{
    init(
        locale: Locale,
        contextualStrings: [String]
    )

    var status: DRecordingStatus { get }
    var text: String? { get }
    var audioMeter: Float { get }

    func start()
    func stop()
}
