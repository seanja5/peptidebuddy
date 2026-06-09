import SwiftUI
import Supabase

@MainActor
class CommunityViewModel: ObservableObject {
    @Published var notes: [CommunityNote] = []
    @Published var peptides: [Peptide] = []
    @Published var isLoading = false

    @Published var selectedPeptideName: String? = nil
    @Published var selectedGoal: String? = nil
    @Published var selectedAgeRange: String? = nil
    @Published var sortByRecent = true

    static let goals = ["Recovery", "Performance", "Longevity", "Cognitive", "Skin", "Metabolic", "Other"]
    static let ageRanges = ["18–25", "26–35", "36–45", "46–55", "55+"]

    var filteredNotes: [CommunityNote] {
        var result = notes
        if let peptide = selectedPeptideName {
            result = result.filter { $0.peptides?.name == peptide }
        }
        if let goal = selectedGoal {
            result = result.filter { $0.goal?.lowercased() == goal.lowercased() }
        }
        if let age = selectedAgeRange {
            result = result.filter { $0.authorAgeRange == age }
        }
        if sortByRecent {
            result.sort { $0.createdAt > $1.createdAt }
        }
        return result
    }

    func fetch() async {
        isLoading = true
        async let notesTask: [CommunityNote] = (try? await supabase
            .from("community_notes")
            .select("*, profiles(username, display_name, avatar_url), peptides(name)")
            .order("created_at", ascending: false)
            .execute()
            .value) ?? []

        async let peptidesTask: [Peptide] = (try? await supabase
            .from("peptides")
            .select()
            .order("name")
            .execute()
            .value) ?? []

        notes = await notesTask
        peptides = await peptidesTask
        isLoading = false
    }

    func clearFilters() {
        selectedPeptideName = nil
        selectedGoal = nil
        selectedAgeRange = nil
        sortByRecent = true
    }
}
