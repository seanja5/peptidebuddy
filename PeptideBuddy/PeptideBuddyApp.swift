import SwiftUI

@main
struct PeptideBuddyApp: App {
    @StateObject private var auth = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .onOpenURL { url in
                    Task {
                        try? await supabase.auth.session(from: url)
                    }
                }
        }
    }
}
