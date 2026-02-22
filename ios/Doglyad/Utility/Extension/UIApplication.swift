import UIKit

extension UIApplication {
    static func openSettings() {
        guard let settingsURL = URL(string: openSettingsURLString) else { return }
        guard shared.canOpenURL(settingsURL) else { return }
        shared.open(settingsURL)
    }
    
    static func openAppStore(
        environment: EnvironmentProtocol,
        id: String
    ) {
        let url = environment.updateUrl.appendingPathComponent(id)
        guard shared.canOpenURL(url) else { return }
        shared.open(url)
    }
}
