import DoglyadUI
import SwiftUI

struct ScanSheetHeaderView: View {
    @EnvironmentObject private var theme: DTheme
    private var color: DColor { theme.color }
    private var size: DSize { theme.size }
    private var typography: DTypography { theme.typography }

    @EnvironmentObject private var viewModel: ScanViewModel
    @State private var isBottom: Bool = false

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: .zero
        ) {
            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                HStack(
                    spacing: .zero
                ) {
                    ForEach(viewModel.photos) { photo in
                        PhotoCard(
                            image: photo.image,
                            actionDelete: {
                                viewModel.onTapDeletePhoto(photo: photo)
                            }
                        )
                    }
                    .padding([.horizontal], size.s2)
                }
                .padding([.horizontal], size.s14)
            }
            .padding(.bottom, size.s8)

            DText(.scanMaxPhotoDescription(count: ScanViewModel.photoMaxCount))
                .dStyle(
                    font: typography.textSmall,
                    color: color.grayscalePlacehold
                )
                .padding(.horizontal, size.s16)
                .padding(.bottom, isBottom ? size.s32 : size.s8)
        }
        .onReceive(viewModel.sheetController.$currentPosition) { _ in
            isBottom = viewModel.sheetController.isBottom
        }
    }
}
