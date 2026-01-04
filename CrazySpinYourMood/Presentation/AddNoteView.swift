
import SwiftUI

struct AddNoteView: View {
    let mood: Mood
    let onSave: (String, [String]) -> Void
    @State private var note: String = ""
    @State private var selectedHabits: [String] = []
    let commonHabits = ["Exercise", "Meditation", "Coffee", "Sleep", "Work", "Friends"] // Example habits
    
    var body: some View {
        VStack {
            Text("What’s affecting your mood?")
                .font(.title2)
            
            TextEditor(text: $note)
                .frame(height: 100)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
            
            Text("Associated Habits")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(commonHabits, id: \.self) { habit in
                    Button(habit) {
                        if selectedHabits.contains(habit) {
                            selectedHabits.removeAll { $0 == habit }
                        } else {
                            selectedHabits.append(habit)
                        }
                    }
                    .padding(8)
                    .background(selectedHabits.contains(habit) ? Color.pink : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            
            Button("Save") {
                onSave(note, selectedHabits)
            }
            .buttonStyle(FilledButtonStyle(color: .pink))
        }
        .padding()
    }
}
