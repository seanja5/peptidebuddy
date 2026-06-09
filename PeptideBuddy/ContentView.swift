import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "pills.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("PeptideBuddy")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Your peptide companion")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
