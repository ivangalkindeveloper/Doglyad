import UIKit

extension UIApplication {
    static func openSettings() {
        guard let settingsURL = URL(string: openSettingsURLString) else { return }
        if shared.canOpenURL(settingsURL) {
            shared.open(settingsURL)
        }
    }
}
