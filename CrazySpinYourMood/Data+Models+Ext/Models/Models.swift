import SwiftUI
import Foundation

enum Mood: String, Identifiable, Codable {
    case happy = "Happy"
    case calm = "Calm"
    case focused = "Focused"
    case tired = "Tired"
    case stressed = "Stressed"
    case excited = "Excited"
    
    var id: String { rawValue }
    
    var name: String { rawValue }
    
    var icon: String {
        switch self {
        case .happy: "😊"
        case .calm: "😌"
        case .focused: "🎯"
        case .tired: "😴"
        case .stressed: "😖"
        case .excited: "⚡"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: .yellow
        case .calm: .blue
        case .focused: .purple
        case .tired: .gray
        case .stressed: .red
        case .excited: .pink
        }
    }
    
    var advice: String {
        switch self {
        case .happy: "Enjoy the positive vibes and share your happiness."
        case .calm: "Take a moment to breathe deeply and appreciate the peace."
        case .focused: "Great day to focus on important tasks."
        case .tired: "Take small breaks and be gentle with yourself."
        case .stressed: "Try some relaxation techniques to ease the tension."
        case .excited: "Channel this energy into something productive."
        }
    }
}

struct MoodEntry: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let mood: Mood
    var note: String?
    var habits: [String] = []
}

struct Badge: Identifiable {
    let id: UUID = UUID()
    let name: String
    let requirement: Int
    let icon: String
}
