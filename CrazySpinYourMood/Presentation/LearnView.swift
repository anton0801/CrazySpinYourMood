import SwiftUI

struct LearnView: View {
    let facts: [Fact] = [
        Fact(title: "Emotions are Contagious", content: "Smiles and yawns can spread from person to person due to mirror neurons.", icon: "😊"),
        Fact(title: "Stress and Health", content: "Chronic stress can weaken the immune system; manage it with exercise.", icon: "😖"),
        Fact(title: "Happiness Boost", content: "Gratitude journaling can increase happiness by 25% according to studies.", icon: "😊"),
        Fact(title: "Calm Breathing", content: "4-7-8 breathing technique helps reduce anxiety quickly.", icon: "😌"),
        Fact(title: "Focus and Productivity", content: "Pomodoro technique: 25 minutes focus, 5 minutes break.", icon: "🎯"),
        Fact(title: "Tiredness Myths", content: "Blue light from screens disrupts sleep; avoid before bed.", icon: "😴"),
        Fact(title: "Excitement vs Anxiety", content: "Both have similar physical symptoms; reframe anxiety as excitement.", icon: "⚡"),
        Fact(title: "Mood and Food", content: "Omega-3 in fish can improve mood and reduce depression.", icon: "🍎"),
        Fact(title: "Laughter Benefits", content: "Laughter releases endorphins, natural painkillers.", icon: "😂"),
        Fact(title: "Sadness Purpose", content: "Sadness helps process loss and seek support from others.", icon: "😢"),
        Fact(title: "Anger Management", content: "Count to 10 before responding to avoid regretful actions.", icon: "😠"),
        Fact(title: "Joy Multipliers", content: "Sharing positive experiences amplifies joy.", icon: "😄"),
        Fact(title: "Mindfulness Basics", content: "5 minutes daily meditation can lower stress levels.", icon: "🧘"),
        Fact(title: "Emotional Intelligence", content: "EQ is more predictive of success than IQ in many cases.", icon: "🧠"),
        Fact(title: "Hydration and Mood", content: "Dehydration can cause irritability; drink water regularly.", icon: "💧"),
        Fact(title: "Nature's Effect", content: "20 minutes in nature reduces cortisol levels.", icon: "🌳"),
        Fact(title: "Music Therapy", content: "Upbeat music can elevate mood in minutes.", icon: "🎵"),
        Fact(title: "Sleep Importance", content: "7-9 hours sleep nightly for optimal emotional regulation.", icon: "🛌"),
        Fact(title: "Kindness Ripple", content: "Acts of kindness boost serotonin for giver and receiver.", icon: "❤️"),
        Fact(title: "Resilience Building", content: "Viewing challenges as growth opportunities builds emotional strength.", icon: "💪")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(facts) { fact in
                        FactCard(fact: fact)
                    }
                }
                .padding()
            }
            .navigationTitle("Learn About Moods")
        }
    }
}

struct Fact: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let icon: String
}

struct FactCard: View {
    let fact: Fact
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            CardView {
                Text(fact.icon)
                    .font(.largeTitle)
                Text(fact.title)
                    .font(.headline)
            }
            .opacity(isFlipped ? 0 : 1)
            
            CardView {
                Text(fact.content)
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
            .opacity(isFlipped ? 1 : 0)
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.4, dampingFraction: 0.8))
        .onTapGesture { isFlipped.toggle() }
    }
}


#Preview {
    LearnView()
}
