import Foundation

public protocol DDatabaseProtocol: AnyObject,
    DDatabaseOnBoardingProtocol,
    DDatabaseNeuralModelSettingsProtocol,
    DDatabaseUSExaminationTypeProtocol,
    DDatabaseUSExaminationNeuralModelProtocol,
    DDatabaseUSExaminationTemplateProtocol,
    DDatabaseModelConclusionProtocol,
    DDatabaseRequestLimitProtocol,
    DDatabaseClearProtocol {}
