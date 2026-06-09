import SwiftUI

struct CommunityNotesView: View {
    @StateObject private var vm = CommunityViewModel()
    @State private var showPeptidePicker = false
    @State private var showGoalPicker = false
    @State private var showAgePicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                Divider()
                Group {
                    if vm.isLoading {
                        loadingView
                    } else if vm.filteredNotes.isEmpty {
                        emptyView
                    } else {
                        notesList
                    }
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Community Notes")
            .navigationBarTitleDisplayMode(.inline)
            .task { await vm.fetch() }
            .sheet(isPresented: $showPeptidePicker) {
                pickerSheet(
                    title: "Filter by Peptide",
                    items: vm.peptides.map(\.name),
                    selected: vm.selectedPeptideName,
                    onSelect: { vm.selectedPeptideName = $0 },
                    onClear: { vm.selectedPeptideName = nil }
                )
            }
            .sheet(isPresented: $showGoalPicker) {
                pickerSheet(
                    title: "Filter by Goal",
                    items: CommunityViewModel.goals,
                    selected: vm.selectedGoal,
                    onSelect: { vm.selectedGoal = $0 },
                    onClear: { vm.selectedGoal = nil }
                )
            }
            .sheet(isPresented: $showAgePicker) {
                pickerSheet(
                    title: "Filter by Age Range",
                    items: CommunityViewModel.ageRanges,
                    selected: vm.selectedAgeRange,
                    onSelect: { vm.selectedAgeRange = $0 },
                    onClear: { vm.selectedAgeRange = nil }
                )
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                recentChip
                filterChip(label: vm.selectedPeptideName ?? "Peptide", isActive: vm.selectedPeptideName != nil) {
                    showPeptidePicker = true
                }
                filterChip(label: vm.selectedGoal ?? "Goal", isActive: vm.selectedGoal != nil) {
                    showGoalPicker = true
                }
                filterChip(label: vm.selectedAgeRange ?? "Age", isActive: vm.selectedAgeRange != nil) {
                    showAgePicker = true
                }
                if vm.selectedPeptideName != nil || vm.selectedGoal != nil || vm.selectedAgeRange != nil || !vm.sortByRecent {
                    clearButton
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
        }
        .background(Color.appBackground)
    }

    private var recentChip: some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) { vm.sortByRecent.toggle() }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: vm.sortByRecent ? "clock.fill" : "clock")
                    .font(.caption)
                Text("Recent")
                    .font(.subheadline).fontWeight(.medium)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(vm.sortByRecent ? Color.chipActive : Color.chipInactive)
            .foregroundStyle(vm.sortByRecent ? .white : Color.textSecondary)
            .cornerRadius(DS.Radius.chip)
        }
        .buttonStyle(.plain)
    }

    private func filterChip(label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.subheadline).fontWeight(.medium)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(isActive ? Color.chipActive : Color.chipInactive)
            .foregroundStyle(isActive ? .white : Color.textSecondary)
            .cornerRadius(DS.Radius.chip)
        }
        .buttonStyle(.plain)
    }

    private var clearButton: some View {
        Button {
            withAnimation { vm.clearFilters() }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "xmark").font(.caption)
                Text("Clear").font(.subheadline).fontWeight(.medium)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            .background(Color.chipInactive)
            .foregroundStyle(Color.textSecondary)
            .cornerRadius(DS.Radius.chip)
        }
        .buttonStyle(.plain)
    }

    private var notesList: some View {
        ScrollView {
            LazyVStack(spacing: DS.Spacing.md) {
                ForEach(vm.filteredNotes) { note in
                    NoteCardView(note: note)
                }
            }
            .padding(DS.Spacing.md)
        }
    }

    private var loadingView: some View {
        ScrollView {
            LazyVStack(spacing: DS.Spacing.md) {
                ForEach(0..<5, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: DS.Radius.card)
                        .fill(Color.appSurface)
                        .frame(height: 130)
                        .redacted(reason: .placeholder)
                }
            }
            .padding(DS.Spacing.md)
        }
    }

    private var emptyView: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundStyle(Color.textTertiary)
            Text("No notes yet")
                .font(.headline).foregroundStyle(Color.textPrimary)
            Text("Be the first to share your experience with the community.")
                .font(.subheadline).foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DS.Spacing.xl)
    }

    private func pickerSheet(
        title: String,
        items: [String],
        selected: String?,
        onSelect: @escaping (String) -> Void,
        onClear: @escaping () -> Void
    ) -> some View {
        NavigationStack {
            List {
                ForEach(items, id: \.self) { item in
                    Button {
                        onSelect(item)
                        showPeptidePicker = false
                        showGoalPicker = false
                        showAgePicker = false
                    } label: {
                        HStack {
                            Text(item).foregroundStyle(Color.textPrimary)
                            Spacer()
                            if selected == item {
                                Image(systemName: "checkmark").foregroundStyle(Color.primaryBlue)
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear") {
                        onClear()
                        showPeptidePicker = false
                        showGoalPicker = false
                        showAgePicker = false
                    }
                    .foregroundStyle(Color.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showPeptidePicker = false
                        showGoalPicker = false
                        showAgePicker = false
                    }
                    .foregroundStyle(Color.primaryBlue)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct NoteCardView: View {
    let note: CommunityNote
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            authorRow
            badgeRow
            bodyText
        }
        .padding(DS.Spacing.md)
        .background(Color.appSurface)
        .cornerRadius(DS.Radius.card)
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.card).stroke(Color.appBorder, lineWidth: 1))
    }

    private var authorRow: some View {
        HStack(spacing: DS.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.primaryBlue.opacity(0.12))
                    .frame(width: DS.Avatar.feed, height: DS.Avatar.feed)
                Text(avatarInitial)
                    .font(.subheadline).bold()
                    .foregroundStyle(Color.primaryBlue)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(note.profiles?.displayName ?? note.profiles?.username ?? "Anonymous")
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                Text(relativeDate(note.createdAt))
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)
            }
            Spacer()
        }
    }

    private var badgeRow: some View {
        HStack(spacing: DS.Spacing.sm) {
            if let peptide = note.peptides?.name {
                badge(peptide, color: Color.primaryBlue)
            }
            if let goal = note.goal {
                badge(goal, color: Color.textSecondary)
            }
            if let age = note.authorAgeRange {
                badge(age, color: Color.textTertiary)
            }
        }
    }

    private func badge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption).fontWeight(.medium)
            .padding(.horizontal, DS.Spacing.sm)
            .padding(.vertical, 3)
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .cornerRadius(DS.Radius.chip)
    }

    private var bodyText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.body)
                .font(.body)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(isExpanded ? nil : 3)
            if note.body.count > 150 {
                Button(isExpanded ? "Show less" : "Read more") {
                    withAnimation(.easeOut(duration: 0.2)) { isExpanded.toggle() }
                }
                .font(.caption).fontWeight(.medium)
                .foregroundStyle(Color.primaryBlue)
            }
        }
    }

    private var avatarInitial: String {
        let name = note.profiles?.displayName ?? note.profiles?.username ?? "?"
        return String(name.prefix(1)).uppercased()
    }

    private func relativeDate(_ date: Date) -> String {
        let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: date, to: Date())
        if let days = diff.day, days > 0 { return "\(days)d ago" }
        if let hours = diff.hour, hours > 0 { return "\(hours)h ago" }
        if let mins = diff.minute, mins > 0 { return "\(mins)m ago" }
        return "Just now"
    }
}
