import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: AuthManager
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.splashBG.ignoresSafeArea()
            VStack(spacing: DS.Spacing.xl) {
                Spacer()
                VStack(spacing: DS.Spacing.md) {
                    Image(systemName: "pills.fill")
                        .font(.system(size: 56, weight: .light))
                        .foregroundStyle(Color.splashText.opacity(0.7))
                    Text("PeptideBuddy")
                        .font(.largeTitle).bold()
                        .foregroundStyle(Color.splashText)
                    Text("Join the community")
                        .font(.subheadline)
                        .foregroundStyle(Color.textTertiary)
                }
                Spacer()
                VStack(spacing: DS.Spacing.sm) {
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red.opacity(0.9))
                            .padding(.horizontal, DS.Spacing.md)
                            .multilineTextAlignment(.center)
                    }
                    Button {
                        Task { await signInWithGoogle() }
                    } label: {
                        HStack(spacing: DS.Spacing.sm) {
                            Image(systemName: "globe")
                                .font(.system(size: 18, weight: .medium))
                            Text(isLoading ? "Signing in…" : "Continue with Google")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.white)
                        .foregroundStyle(Color.textPrimary)
                        .cornerRadius(DS.Radius.button)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, DS.Spacing.lg)
                }
                Text("Educational and community content only.\nNot medical advice.")
                    .font(.caption2)
                    .foregroundStyle(Color.textTertiary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, DS.Spacing.lg)
            }
        }
    }

    private func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        do {
            try await auth.signInWithGoogle()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
