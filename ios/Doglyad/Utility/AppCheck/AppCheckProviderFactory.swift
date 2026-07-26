import FirebaseAppCheck
import FirebaseCore

class DAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if DEBUG
            return AppCheckDebugProvider(app: app)
        #else
            return AppAttestProvider(app: app)
        #endif
    }
}
