import SwiftUI

struct NewsView: View {
    @StateObject private var vm = NewsViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryBar
                Divider()
                Group {
                    if vm.isLoading {
                        loadingView
                    } else if vm.filteredArticles.isEmpty {
                        emptyView
                    } else {
                        articleList
                    }
                }
            }
            .background(Color.appBackground)
            .navigationTitle("News")
            .navigationBarTitleDisplayMode(.inline)
            .task { await vm.fetch() }
        }
    }

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                ForEach(NewsCategory.allCases) { cat in
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            vm.selectedCategory = cat
                        }
                    } label: {
                        Text(cat.label)
                            .font(.subheadline).fontWeight(.medium)
                            .padding(.horizontal, DS.Spacing.md)
                            .padding(.vertical, DS.Spacing.sm)
                            .background(vm.selectedCategory == cat ? Color.chipActive : Color.chipInactive)
                            .foregroundStyle(vm.selectedCategory == cat ? .white : Color.textSecondary)
                            .cornerRadius(DS.Radius.chip)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
        }
        .background(Color.appBackground)
    }

    private var articleList: some View {
        ScrollView {
            LazyVStack(spacing: DS.Spacing.md) {
                ForEach(vm.filteredArticles) { article in
                    NavigationLink(destination: NewsDetailView(article: article)) {
                        NewsCardView(article: article)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(DS.Spacing.md)
        }
    }

    private var loadingView: some View {
        ScrollView {
            LazyVStack(spacing: DS.Spacing.md) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: DS.Radius.card)
                        .fill(Color.appSurface)
                        .frame(height: 120)
                        .redacted(reason: .placeholder)
                }
            }
            .padding(DS.Spacing.md)
        }
    }

    private var emptyView: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: "newspaper").font(.system(size: 48)).foregroundStyle(Color.textTertiary)
            Text("No articles yet").font(.headline).foregroundStyle(Color.textPrimary)
            Text("Check back soon for peptide news and education.")
                .font(.subheadline).foregroundStyle(Color.textSecondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DS.Spacing.xl)
    }
}

struct NewsCardView: View {
    let article: NewsArticle

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            categoryBadge
            Text(article.title)
                .font(.headline)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                if let source = article.sourceName {
                    Text(source)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
                Text(relativeDate(article.publishedAt))
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .padding(DS.Spacing.md)
        .background(Color.appSurface)
        .cornerRadius(DS.Radius.card)
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.card).stroke(Color.appBorder, lineWidth: 1))
    }

    private var categoryBadge: some View {
        Text(NewsCategory(rawValue: article.category)?.label ?? article.category)
            .font(.caption).fontWeight(.medium)
            .padding(.horizontal, DS.Spacing.sm)
            .padding(.vertical, 3)
            .background(Color.lightBlue.opacity(0.12))
            .foregroundStyle(Color.primaryBlue)
            .cornerRadius(DS.Radius.chip)
    }

    private func relativeDate(_ date: Date) -> String {
        let diff = Calendar.current.dateComponents([.day, .hour], from: date, to: Date())
        if let days = diff.day, days > 0 { return "\(days)d ago" }
        if let hours = diff.hour, hours > 0 { return "\(hours)h ago" }
        return "Just now"
    }
}

struct NewsDetailView: View {
    let article: NewsArticle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                Text(NewsCategory(rawValue: article.category)?.label ?? article.category)
                    .font(.caption).fontWeight(.medium)
                    .padding(.horizontal, DS.Spacing.sm).padding(.vertical, 3)
                    .background(Color.lightBlue.opacity(0.12))
                    .foregroundStyle(Color.primaryBlue)
                    .cornerRadius(DS.Radius.chip)

                Text(article.title)
                    .font(.title2).bold()
                    .foregroundStyle(Color.textPrimary)

                HStack {
                    if let source = article.sourceName {
                        Text(source).font(.caption).foregroundStyle(Color.textSecondary)
                    }
                    Spacer()
                    Text(article.publishedAt, style: .date).font(.caption).foregroundStyle(Color.textTertiary)
                }

                Divider()

                Text(article.body)
                    .font(.body)
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(6)
            }
            .padding(DS.Spacing.md)
        }
        .background(Color.appBackground)
        .navigationBarTitleDisplayMode(.inline)
    }
}
