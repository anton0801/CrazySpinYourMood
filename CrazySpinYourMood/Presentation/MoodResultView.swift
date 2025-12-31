import SwiftUI

struct MoodResultView: View {
    @Binding var selectedMood: Mood?
    @Binding var showResult: Bool
    @State private var showAddNote: Bool = false
    @AppStorage("moodHistory") private var moodHistoryData: Data = Data()
    
    var body: some View {
        if let mood = selectedMood {
            VStack(spacing: 20) {
                Text("Your mood today")
                    .font(.title2)
                
                Text(mood.icon)
                    .font(.system(size: 100))
                
                Text(mood.name)
                    .font(.title)
                    .foregroundColor(mood.color)
                
                Text(mood.advice)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Save Mood") {
                    saveMood(mood)
                    showResult = false
                }
                .buttonStyle(FilledButtonStyle(color: .purple))
                
                Button("Spin Again") {
                    showResult = false
                }
                .buttonStyle(FilledButtonStyle(color: .blue))
                
                Button("Add Note") {
                    showAddNote = true
                }
                .buttonStyle(FilledButtonStyle(color: .yellow))
            }
            .padding()
            .sheet(isPresented: $showAddNote) {
                AddNoteView(mood: mood, onSave: { note in
                    saveMood(mood, note: note)
                    showResult = false
                })
            }
        }
    }
    
    func saveMood(_ mood: Mood, note: String? = nil) {
        var history = loadHistory()
        let entry = MoodEntry(date: Date(), mood: mood, note: note)
        history.append(entry)
        if let data = try? JSONEncoder().encode(history) {
            moodHistoryData = data
        }
    }
    
    func loadHistory() -> [MoodEntry] {
        if let history = try? JSONDecoder().decode([MoodEntry].self, from: moodHistoryData) {
            return history
        }
        return []
    }
}

struct FilledButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
