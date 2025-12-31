import SwiftUI

struct DayDetailsView: View {
    let entry: MoodEntry
    let onUpdate: (MoodEntry) -> Void
    let onDelete: (MoodEntry) -> Void
    @State private var note: String
    @Environment(\.presentationMode) var presentationMode
    
    init(entry: MoodEntry, onUpdate: @escaping (MoodEntry) -> Void, onDelete: @escaping (MoodEntry) -> Void) {
        self.entry = entry
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _note = State(initialValue: entry.note ?? "")
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(entry.date, style: .date)
                .font(.title)
            
            Text(entry.mood.icon)
                .font(.system(size: 80))
            
            Text(entry.mood.name)
                .font(.title2)
                .foregroundColor(entry.mood.color)
            
            TextEditor(text: $note)
                .frame(height: 150)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
            
            Button("Edit") {
                var updated = entry
                updated.note = note
                onUpdate(updated)
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(FilledButtonStyle(color: .blue))
            
            Button("Delete") {
                onDelete(entry)
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(FilledButtonStyle(color: .red))
        }
        .padding()
        .navigationTitle("Day Details")
    }
}
