import Foundation

public protocol DDatabaseProtocol: AnyObject,
    DDatabaseOnBoardingProtocol,
    DDatabaseNeuralModelSettingsProtocol,
    DDatabaseUSExaminationTypeProtocol,
    DDatabaseUSExaminationNeuralModelProtocol,
    DDatabaseUserSettingsProtocol,
    DDatabaseClearProtocol
{
    var examinationConclusions: DExaminationConclusionsStore { get }
    var examinationTemplates: DExaminationTemplatesStore { get }
}
