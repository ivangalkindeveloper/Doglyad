import SwiftUI
import Router
import DoglyadUI

final class SpeechFullScreenCoverArguments: RouteArgumentsProtocol {
    let description: String?
    let completion: () -> Void
    
    init(
        description: String?,
        completion: @escaping () -> Void
    ) {
        self.description = description
        self.completion = completion
    }
}

struct SpeechFullScreenCover: View {
    @EnvironmentObject var router: DRouter
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    let arguments: SpeechFullScreenCoverArguments?
    @StateObject private var viewModel = SpeechViewModel()
    
    var body: some View {
        
    }
}
