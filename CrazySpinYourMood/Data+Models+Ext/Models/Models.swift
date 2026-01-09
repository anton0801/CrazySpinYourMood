import SwiftUI
import Foundation

//enum Mood: String, Identifiable, Codable {
//    case happy = "Happy"
//    case calm = "Calm"
//    case focused = "Focused"
//    case tired = "Tired"
//    case stressed = "Stressed"
//    case excited = "Excited"
//    
//    var id: String { rawValue }
//    
//    var name: String { rawValue }
//    
//    var icon: String {
//        switch self {
//        case .happy: "😊"
//        case .calm: "😌"
//        case .focused: "🎯"
//        case .tired: "😴"
//        case .stressed: "😖"
//        case .excited: "⚡"
//        }
//    }
//    
//    var color: Color {
//        switch self {
//        case .happy: .yellow
//        case .calm: .blue
//        case .focused: .purple
//        case .tired: .gray
//        case .stressed: .red
//        case .excited: .pink
//        }
//    }
//    
//    var advice: String {
//        switch self {
//        case .happy: "Enjoy the positive vibes and share your happiness."
//        case .calm: "Take a moment to breathe deeply and appreciate the peace."
//        case .focused: "Great day to focus on important tasks."
//        case .tired: "Take small breaks and be gentle with yourself."
//        case .stressed: "Try some relaxation techniques to ease the tension."
//        case .excited: "Channel this energy into something productive."
//        }
//    }
//}

struct Mood: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var icon: String
    var color: String // Hex string
    var advice: String
    var value: Double // 0.0 to 1.0 for positivity/energy level
    
    var swiftColor: Color {
        Color(hex: color) ?? .gray
    }
}

//struct MoodEntry: Identifiable, Codable {
//    var id = UUID()
//    let date: Date
//    let mood: Mood
//    var note: String?
//    var habits: [String] = []
//}

struct MoodEntry: Identifiable, Codable, Hashable, Equatable {
    let id = UUID()
    let date: Date
    let mood: Mood
    var note: String?
    var habits: [String] = []
    
    static func == (lhs: MoodEntry, rhs: MoodEntry) -> Bool {
        lhs.id == rhs.id
    }
}

// Default moods (initial in UserDefaults)
let defaultMoods: [Mood] = [
    Mood(name: "Happy", icon: "😊", color: "#FFFF00", advice: "Enjoy the positive vibes and share your happiness.", value: 0.9),
    Mood(name: "Calm", icon: "😌", color: "#0000FF", advice: "Take a moment to breathe deeply and appreciate the peace.", value: 0.6),
    Mood(name: "Focused", icon: "🎯", color: "#800080", advice: "Great day to focus on important tasks.", value: 0.7),
    Mood(name: "Tired", icon: "😴", color: "#808080", advice: "Take small breaks and be gentle with yourself.", value: 0.3),
    Mood(name: "Stressed", icon: "😖", color: "#FF0000", advice: "Try some relaxation techniques to ease the tension.", value: 0.2),
    Mood(name: "Excited", icon: "⚡", color: "#FFC0CB", advice: "Channel this energy into something productive.", value: 0.8)
]

struct Badge: Identifiable {
    let id: UUID = UUID()
    let name: String
    let requirement: Int
    let icon: String
}
