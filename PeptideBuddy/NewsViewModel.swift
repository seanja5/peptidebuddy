import SwiftUI
import Supabase

@MainActor
class NewsViewModel: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var selectedCategory: NewsCategory = .all
    @Published var isLoading = false

    var filteredArticles: [NewsArticle] {
        guard selectedCategory != .all else { return articles }
        return articles.filter { $0.category == selectedCategory.rawValue }
    }

    func fetch() async {
        isLoading = true
        articles = (try? await supabase
            .from("news_articles")
            .select()
            .order("published_at", ascending: false)
            .execute()
            .value) ?? []
        isLoading = false
    }
}
