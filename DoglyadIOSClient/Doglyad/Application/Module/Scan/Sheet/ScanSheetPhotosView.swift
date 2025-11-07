import DoglyadUI
import SwiftUI

struct ScanSheetPhotosView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }
    
    @EnvironmentObject private var viewModel: ScanViewModel
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: .zero
        ) {
            ScrollView(.horizontal) {
                HStack(spacing: .zero) {
                    ForEach(viewModel.photos) { photo in
                        DPhotoCard(
                            image: photo.image,
                            actionDelete: {
                                viewModel.onPressedDeletePhoto(photo: photo)
                            }
                        )
                    }
                    .padding([.horizontal], size.s2)
                }
                .padding([.horizontal], size.s14)
            }
            .padding(.bottom, size.s8)
            
            DText(
                .scanMaxPhotoDescription(count: ScanViewModel.photoMaxCount)
            )
            .dStyle(
                font: typography.textSmall,
                color: color.grayscalePlaceholder
            )
            .padding(.horizontal, size.s16)
            .padding(.bottom, size.s32)
        }
    }
}
