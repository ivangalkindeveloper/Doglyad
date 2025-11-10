import SwiftUI

protocol ScanStrategyProtocol: AnyObject {
    associatedtype VM: ScanStrategyViewModelProtocol
    associatedtype V: ScanStrategyViewProtocol
    
    var viewModel: VM { get }
    
    var view: V { get }
}
