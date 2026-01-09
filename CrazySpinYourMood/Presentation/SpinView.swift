import SwiftUI
import ConfettiSwiftUI

struct SpinView: View {
    @State private var rotation: Double = 0
    @State private var isSpinning: Bool = false
    @State private var selectedMood: Mood?
    @State private var showResult: Bool = false
    @State private var confetti: Int = 0
    
    let moods: [Mood] = defaultMoods // [.happy, .calm, .focused, .tired, .stressed, .excited]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("How do you feel today?")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(Date(), style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                MoodWheel(rotation: $rotation, selectedMood: $selectedMood)
                    .frame(maxWidth: 300, maxHeight: 300)
                
                Spacer()
                
                Button(action: spin) {
                    Text("SPIN")
                        .font(.title2)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: .yellow.opacity(0.5), radius: 5)
                }
                .disabled(isSpinning)
                
                Text("Spin to reflect your mood")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]), startPoint: .top, endPoint: .bottom).ignoresSafeArea())
            .sheet(isPresented: $showResult) {
                MoodResultView(selectedMood: $selectedMood, showResult: $showResult)
            }
            .confettiCannon(trigger: $confetti, num: 50, confettis: [.text("✨"), .text("🌟"), .text("⚡")], colors: [.yellow, .pink, .blue], radius: 300)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func spin() {
        isSpinning = true
        let randomSpins = Double.random(in: 5...10) * 360
        let randomSegment = Double.random(in: 0..<360)
        rotation = 0
        
        withAnimation(Animation.easeOut(duration: 4)) {
            rotation = randomSpins + randomSegment
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            let segmentAngle = 360.0 / Double(moods.count)
            let normalizedRotation = fmod(rotation, 360)
            let index = Int((360 - normalizedRotation) / segmentAngle) % moods.count
            selectedMood = moods[index]
            confetti += 1
            showResult = true
            isSpinning = false
        }
    }
}

#Preview {
    SpinView()
}
