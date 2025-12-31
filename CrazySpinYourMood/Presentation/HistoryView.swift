

import SwiftUI

struct HistoryView: View {
    @AppStorage("moodHistory") private var moodHistoryData: Data = Data()
    @State private var history: [MoodEntry] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(history.sorted(by: { $0.date > $1.date })) { entry in
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
