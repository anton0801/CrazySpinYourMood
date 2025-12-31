
import SwiftUI

struct AddNoteView: View {
    let mood: Mood
    let onSave: (String) -> Void
    @State private var note: String = ""
    
    var body: some View {
        VStack {
            Text("What’s affecting your mood?")
                .font(.title2)
            
            TextEditor(text: $note)
                .frame(height: 200)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
            
            Button("Save") {
                onSave(note)
            }
            .buttonStyle(FilledButtonStyle(color: .pink))
        }
        .padding()
    }
}
