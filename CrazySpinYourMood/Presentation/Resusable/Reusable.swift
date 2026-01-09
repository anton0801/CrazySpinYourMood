
import SwiftUI

//struct MoodWheel: View {
//    @Binding var rotation: Double
//    @Binding var selectedMood: Mood?
//    @State private var pulseScale: CGFloat = 1.0
//    
//    let moods: [Mood] = [.happy, .calm, .focused, .tired, .stressed, .excited]
//    
//    var body: some View {
//        GeometryReader { geometry in
//            let radius = min(geometry.size.width, geometry.size.height) / 2
//            ZStack {
//                ForEach(0..<moods.count, id: \.self) { index in
//                    let angle = Double(index) * (360.0 / Double(moods.count)) + (180.0 / Double(moods.count))
//                    let offsetX = radius * 0.7 * cos(Angle(degrees: angle).radians)
//                    let offsetY = radius * 0.7 * sin(Angle(degrees: angle).radians)
//                    
//                    Path { path in
//                        let segmentAngle = 360.0 / Double(moods.count)
//                        let startAngle = Double(index) * segmentAngle
//                        let endAngle = startAngle + segmentAngle
//                        
//                        path.move(to: CGPoint(x: radius, y: radius))
//                        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: .degrees(startAngle), endAngle: .degrees(endAngle), clockwise: false)
//                    }
//                    .fill(moods[index].color.gradient)
//                    .overlay {
//                        Text(moods[index].icon)
//                            .font(.largeTitle)
//                            .offset(x: offsetX, y: offsetY)
//                    }
//                }
//                .rotationEffect(.degrees(rotation))
//                
//                Triangle()
//                    .fill(Color.white)
//                    .frame(width: 20, height: 40)
//                    .offset(y: radius - 20)
//                    .shadow(color: .yellow.opacity(0.8), radius: 5)
//                    .rotationEffect(.degrees(180))
////                Triangle()
////                    .fill(Color.white)
////                    .frame(width: 20, height: 40)
////                    .offset(y: -radius - 20)
////                    .shadow(color: .yellow.opacity(0.8), radius: 5)
//            }
//            .frame(width: geometry.size.width, height: geometry.size.height)
//            .scaleEffect(pulseScale)
//            .onAppear {
//                withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
//                    pulseScale = 1.05
//                }
//            }
//        }
//    }
//}
//
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct MoodWheel: View {
    @Binding var rotation: Double
    @Binding var selectedMood: Mood?
    @AppStorage("customMoods") private var customMoodsData: Data = Data()
    
    var moods: [Mood] {
        if let moods = try? JSONDecoder().decode([Mood].self, from: customMoodsData), !moods.isEmpty {
            return moods
        } else {
            return defaultMoods
        }
    }
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5
    
    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            ZStack {
                ForEach(0..<moods.count, id: \.self) { index in
                    let segmentAngle = 360.0 / Double(moods.count)
                    let startAngle = Double(index) * segmentAngle
                    let textAngle = startAngle + segmentAngle / 2
                    let radian = Angle(degrees: textAngle).radians
                    Path { path in
                        path.move(to: CGPoint(x: radius, y: radius))
                        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: .degrees(startAngle), endAngle: .degrees(startAngle + segmentAngle), clockwise: false)
                    }
                    .fill(LinearGradient(gradient: Gradient(colors: [moods[index].swiftColor, moods[index].swiftColor.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                    .shadow(color: .white.opacity(glowOpacity), radius: 5)
                    .overlay {
                        Text(moods[index].icon)
                            .font(.largeTitle)
                            .position(x: radius + radius * 0.7 * cos(radian), y: radius + radius * 0.7 * sin(radian))
                    }
                }
                
                Triangle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 30, height: 50)
                    .offset(y: -radius - 25)
                    .shadow(color: .yellow, radius: 10)
            }
            .rotationEffect(.degrees(rotation))
            .scaleEffect(pulseScale)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(.ultraThinMaterial)
            .cornerRadius(radius)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulseScale = 1.05
                }
                withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    glowOpacity = 1.0
                }
            }
        }
    }
}

//#Preview {
//    MoodWheel(rotation: .constant(0), selectedMood: .constant(.calm))
//}
