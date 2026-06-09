import SwiftUI
import Supabase

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var session: Session?
    @Published var isLoadingSession = true

    private init() {
        Task { await listenToAuthChanges() }
    }

    private func listenToAuthChanges() async {
        for await (event, session) in await supabase.auth.authStateChanges {
            self.session = session
            if event == .initialSession { isLoadingSession = false }
        }
    }

    var isAuthenticated: Bool { session != nil }

    func signInWithGoogle() async throws {
        try await supabase.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: "com.seanandrews.PeptideBuddy://login-callback")
        )
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
    }
}
