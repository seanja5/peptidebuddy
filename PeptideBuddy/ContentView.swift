import SwiftUI

struct RootView: View {
    @EnvironmentObject private var auth: AuthManager
    @State private var splashDone = false
    @StateObject private var profileVM = ProfileViewModel()

    var body: some View {
        Group {
            if !splashDone {
                SplashView { splashDone = true }
            } else if auth.isLoadingSession {
                loadingView
            } else if !auth.isAuthenticated {
                AuthView()
            } else if !profileVM.hasProfile && !profileVM.isLoading {
                ProfileSetupView()
                    .environmentObject(auth)
            } else {
                MainTabView()
                    .environmentObject(auth)
            }
        }
        .task {
            if let userId = auth.session?.user.id {
                await profileVM.fetchProfile(userId: userId)
            }
        }
        .onChange(of: auth.session) { _, newSession in
            if let userId = newSession?.user.id {
                Task { await profileVM.fetchProfile(userId: userId) }
            } else {
                profileVM.hasProfile = false
                profileVM.profile = nil
            }
        }
    }

    private var loadingView: some View {
        ZStack {
            Color.splashBG.ignoresSafeArea()
            ProgressView().tint(.white)
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            CommunityNotesView()
                .tabItem {
                    Label("Community", systemImage: "bubble.left.and.bubble.right.fill")
                }
            NewsView()
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(Color.primaryBlue)
    }
}
