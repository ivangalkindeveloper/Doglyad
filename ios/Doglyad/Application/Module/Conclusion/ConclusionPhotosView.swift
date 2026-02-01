import DoglyadUI
import SwiftUI

struct ConclusionPhotosView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @EnvironmentObject private var viewModel: ConclusionViewModel

    var body: some View {
        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {
            HStack(
                spacing: .zero
            ) {
                ForEach(viewModel.conclusion.data.photos) { photo in
                    PhotoCard(
                        image: photo.image
                    )
                }
                .padding([.horizontal], size.s2)
            }
            .padding([.horizontal], size.s14)
        }
        .padding(.bottom, size.s16)
    }
}
