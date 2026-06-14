import SwiftUI

struct PermissionPhotoLibraryBottomSheet: View {
    var body: some View {
        PermissionBottomSheet(
            title: .permissionPhotoLibraryTitle,
            description: .permissionPhotoLibraryDescription
        )
    }
}

#Preview {
    PermissionPhotoLibraryBottomSheet()
        .previewable()
}
