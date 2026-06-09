import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
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
                    Text(isSignUp ? "Create an account" : "Welcome back")
                        .font(.subheadline)
                        .foregroundStyle(Color.textTertiary)
                }
                Spacer()
                VStack(spacing: DS.Spacing.md) {
                    emailField
                    passwordField

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DS.Spacing.lg)
                    }

                    submitButton
                    toggleModeButton
                }
                Text("Educational and community content only.\nNot medical advice.")
                    .font(.caption2)
                    .foregroundStyle(Color.textTertiary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, DS.Spacing.lg)
            }
        }
    }

    private var emailField: some View {
        TextField("Email", text: $email)
            .keyboardType(.emailAddress)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .padding(DS.Spacing.md)
            .background(Color.white.opacity(0.12))
            .foregroundStyle(Color.splashText)
            .cornerRadius(DS.Radius.button)
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.button).stroke(Color.white.opacity(0.2), lineWidth: 1))
            .padding(.horizontal, DS.Spacing.lg)
    }

    private var passwordField: some View {
        SecureField("Password", text: $password)
            .padding(DS.Spacing.md)
            .background(Color.white.opacity(0.12))
            .foregroundStyle(Color.splashText)
            .cornerRadius(DS.Radius.button)
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.button).stroke(Color.white.opacity(0.2), lineWidth: 1))
            .padding(.horizontal, DS.Spacing.lg)
    }

    private var submitButton: some View {
        Button {
            Task { await submit() }
        } label: {
            Text(isLoading ? "Please wait…" : (isSignUp ? "Create Account" : "Sign In"))
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white)
                .foregroundStyle(Color.primaryBlue)
                .cornerRadius(DS.Radius.button)
        }
        .disabled(isLoading || email.isEmpty || password.isEmpty)
        .padding(.horizontal, DS.Spacing.lg)
    }

    private var toggleModeButton: some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) {
                isSignUp.toggle()
                errorMessage = nil
            }
        } label: {
            Text(isSignUp ? "Already have an account? Sign in" : "No account? Create one")
                .font(.subheadline)
                .foregroundStyle(Color.splashText.opacity(0.7))
        }
    }

    private func submit() async {
        isLoading = true
        errorMessage = nil
        do {
            if isSignUp {
                try await auth.signUp(email: email, password: password)
            } else {
                try await auth.signIn(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
