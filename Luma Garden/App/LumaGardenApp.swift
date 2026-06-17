import SwiftUI

@main
struct LumaGardenApp: App {
    @State private var container = AppContainer()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container.store)
                .preferredColorScheme(colorScheme)
                .statusBarHidden(true)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background || phase == .inactive {
                container.store.handleBackground()
            }
        }
    }

    private var colorScheme: ColorScheme? {
        switch container.store.state.settings.theme {
        case .dark: return .dark
        case .light: return .light
        case .system: return nil
        }
    }
}
