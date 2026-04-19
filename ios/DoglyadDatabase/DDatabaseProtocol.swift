import Foundation

public protocol DDatabaseProtocol: AnyObject,
    DDatabaseOnBoardingProtocol,
    DDatabaseNeuralModelSettingsProtocol,
    DDatabaseUSExaminationTypeProtocol,
    DDatabaseUSExaminationNeuralModelProtocol,
    DDatabaseClearProtocol
{
    var examinationConclusions: DExaminationConclusionsStore { get }
    var requestLimit: DRequestLimitStore { get }
    var examinationTemplates: DExaminationTemplatesStore { get }
}
