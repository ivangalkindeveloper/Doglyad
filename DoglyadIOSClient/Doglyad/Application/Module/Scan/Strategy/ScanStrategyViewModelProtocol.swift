import Foundation

protocol ScanStrategyViewModelProtocol: ObservableObject {
    associatedtype T: ScanStrategyDataProtocol
    
    func validate() -> Void
    
    func fillFromSpeech(
        data: [String:String]
    ) -> Void
    
    func getData() -> T
}
