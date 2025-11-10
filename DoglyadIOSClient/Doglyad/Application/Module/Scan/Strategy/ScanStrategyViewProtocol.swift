import SwiftUI

protocol ScanStrategyViewProtocol: View {
    associatedtype VM: ScanStrategyViewModelProtocol
    
    var viewModel: VM { get }
}
