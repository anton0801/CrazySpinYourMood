

import SwiftUI

struct HistoryView: View {
    @AppStorage("moodHistory") private var moodHistoryData: Data = Data()
    @State private var history: [MoodEntry] = []
    @State private var searchText: String = ""
    
    var filteredHistory: [MoodEntry] {
        if searchText.isEmpty {
            return history
        } else {
            return history.filter {
                $0.mood.name.lowercased().contains(searchText.lowercased()) ||
                ($0.note?.lowercased().contains(searchText.lowercased()) ?? false) ||
                $0.habits.joined().lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search moods, notes, or habits", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                List {
                    ForEach(filteredHistory.sorted(by: { $0.date > $1.date })) { entry in
                        NavigationLink(destination: DayDetailsView(entry: entry, onUpdate: updateEntry, onDelete: deleteEntry)) {
                            HStack {
                                Text(entry.mood.icon)
                                    .font(.title)
                                VStack(alignment: .leading) {
                                    Text(entry.mood.name)
                                        .font(.headline)
                                    Text(entry.date, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    if !entry.habits.isEmpty {
                                        Text(entry.habits.joined(separator: ", "))
                                            .font(.caption)
                                            .foregroundColor(.purple)
                                    }
                                }
                                Spacer()
                                Circle()
                                    .fill(entry.mood.color)
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("History")
            .onAppear {
                history = loadHistory()
            }
        }
    }
    
    func loadHistory() -> [MoodEntry] {
        if let history = try? JSONDecoder().decode([MoodEntry].self, from: moodHistoryData) {
            return history
        }
        return []
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
