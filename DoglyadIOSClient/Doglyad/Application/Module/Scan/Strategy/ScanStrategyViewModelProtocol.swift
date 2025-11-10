import Foundation

protocol ScanStrategyViewModelProtocol: ObservableObject {
    associatedtype T: ScanStrategyDataProtocol
    
    func validate() -> Void
    
    func getData() -> T
}
