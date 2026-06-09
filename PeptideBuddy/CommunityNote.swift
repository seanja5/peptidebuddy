import Foundation

struct CommunityNote: Codable, Identifiable {
    let id: UUID
    let authorId: UUID?
    let peptideId: UUID?
    var body: String
    var goal: String?
    var authorAgeRange: String?
    let createdAt: Date
    var profiles: NoteAuthor?
    var peptides: NotePeptide?

    enum CodingKeys: String, CodingKey {
        case id
        case authorId      = "author_id"
        case peptideId     = "peptide_id"
        case body
        case goal
        case authorAgeRange = "author_age_range"
        case createdAt     = "created_at"
        case profiles
        case peptides
    }
}

struct NoteAuthor: Codable {
    var username: String
    var displayName: String?
    var avatarURL: String?
    enum CodingKeys: String, CodingKey {
        case username
        case displayName = "display_name"
        case avatarURL   = "avatar_url"
    }
}

struct NotePeptide: Codable {
    var name: String
}

struct Peptide: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var category: String?
}
