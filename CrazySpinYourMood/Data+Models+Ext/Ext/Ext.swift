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

extension Color {
    init?(hex: String) {
        let r, g, b, a: Double
        var hexColor = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexColor.hasPrefix("#") { hexColor.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: hexColor).scanHexInt64(&rgb)
        r = Double((rgb >> 16) & 0xFF) / 255
        g = Double((rgb >> 8) & 0xFF) / 255
        b = Double(rgb & 0xFF) / 255
        a = 1.0
        self = Color(red: r, green: g, blue: b, opacity: a)
    }
    
    var hex: String {
        let components = UIColor(self).cgColor.components ?? [0,0,0,1]
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02x%02x%02x", r, g, b)
    }
}
