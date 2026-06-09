import SwiftUI
import Supabase

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var hasProfile = false

    func fetchProfile(userId: UUID) async {
        isLoading = true
        do {
            let result: UserProfile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            profile = result
            hasProfile = true
        } catch {
            hasProfile = false
        }
        isLoading = false
    }

    func createProfile(userId: UUID, username: String, displayName: String) async throws {
        let newProfile = UserProfile(
            id: userId,
            username: username,
            displayName: displayName.isEmpty ? nil : displayName,
            avatarURL: nil,
            bio: nil,
            createdAt: Date()
        )
        try await supabase
            .from("profiles")
            .insert(newProfile)
            .execute()
        profile = newProfile
        hasProfile = true
    }
}
