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

    func signUp(email: String, password: String) async throws {
        try await supabase.auth.signUp(email: email, password: password)
    }

    func signIn(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
    }
}
