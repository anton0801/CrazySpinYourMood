import SwiftUI
import Charts // For iOS 16+, but since min iOS 14, use custom charts or text stats

struct StatsView: View {
    @AppStorage("moodHistory") private var moodHistoryData: Data = Data()
    @State private var history: [MoodEntry] = []
    
    var daysTracked: Int {
        history.count
    }
    
    var mostCommonMood: String {
        let counts = Dictionary(grouping: history, by: { $0.mood.name }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key ?? "None"
    }
    
    var mostCommonHabit: String {
        let allHabits = history.flatMap { $0.habits }
        let counts = Dictionary(grouping: allHabits, by: { $0 }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key ?? "None"
    }
        
    let badges: [Badge] = [
        Badge(name: "Daily Spinner", requirement: 1, icon: "star.fill"),
        Badge(name: "Week Warrior", requirement: 7, icon: "trophy.fill"),
        Badge(name: "Mood Master", requirement: 30, icon: "crown.fill")
    ]
    
    var unlockedBadges: [Badge] {
        badges.filter { bestStreak >= $0.requirement }
    }
    
    var bestStreak: Int {
        // Simple current streak calculation, assuming daily
        var streak = 1
        var maxStreak = 1
        let sorted = history.sorted(by: { $0.date < $1.date })
        if sorted.count > 1 {
            for i in 1..<sorted.count {
                if Calendar.current.isDate(sorted[i].date, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: sorted[i-1].date)!) {
                    streak += 1
                    maxStreak = max(maxStreak, streak)
                } else {
                    streak = 1
                }
            }
        }
        return maxStreak
    }
    
    var currentStreak: Int {

        1 // Placeholder, implement similarly
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                StatCard(title: "Days Tracked", value: "\(daysTracked)")
                StatCard(title: "Most Common Mood", value: mostCommonMood)
                StatCard(title: "Most Common Habit", value: mostCommonHabit)
                StatCard(title: "Best Mood Streak", value: "\(bestStreak) days")
                StatCard(title: "Current Streak", value: "\(currentStreak) days")
                
                Text("Mood Distribution")
                    .font(.headline)
                MoodPieChart(history: history)
                
                Text("Achievements")
                    .font(.headline)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(unlockedBadges) { badge in
                        VStack {
                            Image(systemName: badge.icon)
                                .font(.largeTitle)
                                .foregroundColor(.yellow)
                            Text(badge.name)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                
                Text("Mood Over Weeks")
                    .font(.headline)
                Text("Graph placeholder")
            }
            .padding()
        }
        .navigationTitle("Stats")
        .onAppear {
            history = loadHistory()
        }
    }
    
    func loadHistory() -> [MoodEntry] {
        if let history = try? JSONDecoder().decode([MoodEntry].self, from: moodHistoryData) {
            return history
        }
        return []
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

// MoodPieChart.swift (Custom simple pie)
struct MoodPieChart: View {
    let history: [MoodEntry]
    
    var moodCounts: [String: Int] {
        Dictionary(grouping: history, by: { $0.mood.name }).mapValues { $0.count }
    }
    
    var total: Double {
        Double(history.count)
    }
    
    var body: some View {
        GeometryReader { geo in
            let sortedMoods = Array(moodCounts.keys.sorted())
            let angleSlices: [Double] = sortedMoods.map { mood in
                360 * Double(moodCounts[mood] ?? 0) / total
            }
            let cumulativeAngles: [Double] = angleSlices.reduce(into: [0.0]) { partial, angle in
                partial.append(partial.last! + angle)
            }
            ZStack {
                ForEach(sortedMoods.indices, id: \.self) { i in
                    let mood = sortedMoods[i]
                    PieSlice(startAngle: cumulativeAngles[i], endAngle: cumulativeAngles[i + 1])
                        .fill(Color.moodsColors[mood] ?? .gray)
                }
            }
        }
        .frame(height: 200)
    }
}

struct PieSlice: Shape {
    var startAngle: Double
    var endAngle: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: .degrees(startAngle), endAngle: .degrees(endAngle), clockwise: false)
        return path
    }
}
