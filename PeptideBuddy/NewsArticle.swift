import Foundation

struct NewsArticle: Codable, Identifiable {
    let id: UUID
    var title: String
    var body: String
    var category: String
    var sourceName: String?
    var sourceURL: String?
    var imageURL: String?
    let publishedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case category
        case sourceName  = "source_name"
        case sourceURL   = "source_url"
        case imageURL    = "image_url"
        case publishedAt = "published_at"
    }
}

enum NewsCategory: String, CaseIterable, Identifiable {
    case all         = "all"
    case origins     = "origins"
    case advancements = "advancements"
    case regulation  = "regulation"
    case companies   = "companies"
    case labs        = "labs"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all:          return "All"
        case .origins:      return "Origins"
        case .advancements: return "Advancements"
        case .regulation:   return "Regulation"
        case .companies:    return "Companies"
        case .labs:         return "Labs"
        }
    }
}
