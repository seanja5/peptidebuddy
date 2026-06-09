import SwiftUI

struct SplashView: View {
    @State private var opacity: Double = 0
    var onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.splashBG.ignoresSafeArea()
            VStack(spacing: DS.Spacing.md) {
                Image(systemName: "pills.fill")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(Color.splashText.opacity(0.7))
                Text("PeptideBuddy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.splashText)
                Text("Community · Education · Science")
                    .font(.subheadline)
                    .foregroundStyle(Color.textTertiary)
            }
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.4)) { opacity = 1 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeOut(duration: 0.3)) { opacity = 0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        onFinished()
                    }
                }
            }
        }
    }
}
