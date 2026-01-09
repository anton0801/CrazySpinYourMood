

import SwiftUI

struct HistoryView: View {
    @AppStorage("moodHistory") private var moodHistoryData: Data = Data()
    @State private var history: [MoodEntry] = []
    @State private var searchText: String = ""
    
    var groupedHistory: [Date: [MoodEntry]] {
        Dictionary(grouping: history) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
    }
    
    var filteredGrouped: [(key: Date, value: [MoodEntry])] {
        groupedHistory.sorted { $0.key > $1.key }.filter { group in
            searchText.isEmpty || group.value.contains { entry in
                entry.mood.name.lowercased().contains(searchText.lowercased()) || (entry.note?.contains(searchText) ?? false)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredGrouped, id: \.key) { group in
                    Section(header: Text(group.key, style: .date)) {
                        ForEach(group.value.sorted { $0.date > $1.date }) { entry in
                            NavigationLink(destination: DayDetailsView(entry: entry, onUpdate: updateEntry, onDelete: deleteEntry)) {
                                HStack {
                                    Text(entry.mood.icon)
                                    VStack(alignment: .leading) {
                                        Text(entry.mood.name)
                                        Text(entry.date, style: .time) // Show time for multiple
                                    }
                                    Spacer()
                                    Circle().fill(entry.mood.swiftColor)
                                }
                            }
                        }
                        .onDelete { indices in
                            deleteEntries(in: group.value, at: indices)
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("History")
            .onAppear { history = loadHistory() }
        }
    }
    
    func loadHistory() -> [MoodEntry] {
        if let history = try? JSONDecoder().decode([MoodEntry].self, from: moodHistoryData) {
            return history
        }
        return []
    }
    
    func deleteEntries(in group: [MoodEntry], at indices: IndexSet) {
        var newHistory = history
        for index in indices {
            if let globalIndex = newHistory.firstIndex(of: group[index]) {
                newHistory.remove(at: globalIndex)
            }
        }
        saveHistory(newHistory)
        history = newHistory
    }
    
    func delete(at offsets: IndexSet) {
        var currentHistory = history
        currentHistory.remove(atOffsets: offsets)
        saveHistory(currentHistory)
        history = currentHistory
    }
    
    func deleteEntry(_ entry: MoodEntry) {
        history.removeAll { $0.id == entry.id }
        saveHistory(history)
    }
    
    func updateEntry(_ updatedEntry: MoodEntry) {
        if let index = history.firstIndex(where: { $0.id == updatedEntry.id }) {
            history[index] = updatedEntry
            saveHistory(history)
        }
    }
    
    func saveHistory(_ history: [MoodEntry]) {
        if let data = try? JSONEncoder().encode(history) {
            moodHistoryData = data
        }
    }
}

