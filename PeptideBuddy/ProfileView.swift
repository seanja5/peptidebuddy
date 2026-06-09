import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthManager
    @StateObject private var vm = ProfileViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.lg) {
                    profileHeader
                    if let profile = vm.profile {
                        statsRow(profile: profile)
                        if let bio = profile.bio, !bio.isEmpty {
                            bioSection(bio: bio)
                        }
                    }
                    signOutButton
                }
                .padding(DS.Spacing.md)
            }
            .background(Color.appBackground)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if let userId = auth.session?.user.id {
                    await vm.fetchProfile(userId: userId)
                }
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: DS.Spacing.md) {
            avatarCircle
            VStack(spacing: DS.Spacing.xs) {
                Text(vm.profile?.displayName ?? vm.profile?.username ?? "—")
                    .font(.title2).bold()
                    .foregroundStyle(Color.textPrimary)
                if let username = vm.profile?.username {
                    Text("@\(username)")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DS.Spacing.lg)
    }

    private var avatarCircle: some View {
        ZStack {
            Circle()
                .fill(Color.primaryBlue.opacity(0.12))
                .frame(width: DS.Avatar.profile, height: DS.Avatar.profile)
            Text(initials)
                .font(.title).bold()
                .foregroundStyle(Color.primaryBlue)
        }
    }

    private var initials: String {
        let name = vm.profile?.displayName ?? vm.profile?.username ?? "?"
        return name.prefix(2).uppercased()
    }

    private func statsRow(profile: UserProfile) -> some View {
        HStack(spacing: DS.Spacing.xl) {
            statItem(value: "—", label: "Notes")
            statItem(value: formattedJoinDate(profile.createdAt), label: "Joined")
        }
        .padding(DS.Spacing.md)
        .background(Color.appSurface)
        .cornerRadius(DS.Radius.card)
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.card).stroke(Color.appBorder, lineWidth: 1))
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            Text(value).font(.headline).foregroundStyle(Color.textPrimary)
            Text(label).font(.caption).foregroundStyle(Color.textSecondary)
        }
    }

    private func bioSection(bio: String) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("About").font(.headline).foregroundStyle(Color.textPrimary)
            Text(bio).font(.body).foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Spacing.md)
        .background(Color.appSurface)
        .cornerRadius(DS.Radius.card)
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.card).stroke(Color.appBorder, lineWidth: 1))
    }

    private var signOutButton: some View {
        Button(role: .destructive) {
            Task { try? await auth.signOut() }
        } label: {
            Text("Sign Out")
                .frame(maxWidth: .infinity)
                .frame(height: 50)
        }
        .buttonStyle(.bordered)
        .tint(.red)
        .padding(.top, DS.Spacing.md)
    }

    private func formattedJoinDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        return f.string(from: date)
    }
}

struct ProfileSetupView: View {
    @EnvironmentObject private var auth: AuthManager
    @StateObject private var vm = ProfileViewModel()
    @State private var username = ""
    @State private var displayName = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.lg) {
                    VStack(spacing: DS.Spacing.sm) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(Color.primaryBlue)
                        Text("Create Your Profile")
                            .font(.title2).bold()
                            .foregroundStyle(Color.textPrimary)
                        Text("Choose a username to get started")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(.top, DS.Spacing.xl)

                    VStack(spacing: DS.Spacing.md) {
                        inputField(title: "Username *", text: $username, placeholder: "e.g. peptide_sean", keyboard: .asciiCapable)
                        inputField(title: "Display Name", text: $displayName, placeholder: "Your name (optional)", keyboard: .default)
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task { await submit() }
                    } label: {
                        Text(isSubmitting ? "Creating…" : "Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(username.isEmpty ? Color.appBorder : Color.primaryBlue)
                            .foregroundStyle(.white)
                            .cornerRadius(DS.Radius.button)
                    }
                    .disabled(username.isEmpty || isSubmitting)
                }
                .padding(DS.Spacing.md)
            }
            .background(Color.appBackground)
            .navigationBarBackButtonHidden(true)
        }
    }

    private func inputField(title: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Text(title)
                .font(.subheadline).fontWeight(.medium)
                .foregroundStyle(Color.textPrimary)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(DS.Spacing.md)
                .background(Color.appSurface)
                .cornerRadius(DS.Radius.card)
                .overlay(RoundedRectangle(cornerRadius: DS.Radius.card).stroke(Color.appBorder, lineWidth: 1))
        }
    }

    private func submit() async {
        guard let userId = auth.session?.user.id else { return }
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { errorMessage = "Username is required."; return }
        isSubmitting = true
        errorMessage = nil
        do {
            try await vm.createProfile(userId: userId, username: trimmed, displayName: displayName)
        } catch {
            errorMessage = "That username may already be taken. Try another."
        }
        isSubmitting = false
    }
}
