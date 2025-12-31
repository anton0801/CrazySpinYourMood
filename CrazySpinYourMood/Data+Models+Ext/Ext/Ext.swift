import Foundation
import SwiftUI

extension Color {
    var gradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [self, self.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
    }
    
    static let moodsColors: [String: Color] = [
        "Happy": .yellow,
        "Calm": .blue,
        "Focused": .purple,
        "Tired": .gray,
        "Stressed": .red,
        "Excited": .pink
    ]
}
