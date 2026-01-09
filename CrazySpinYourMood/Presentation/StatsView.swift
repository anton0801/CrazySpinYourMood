import SwiftUI
import Charts // For iOS 16+, but since min iOS 14, use custom charts or text stats

struct StatsView: View {
    @AppStorage("moodHistory") private var moodHistoryData: Data = Data()
    @State private var history: [MoodEntry] = []
    @State private var selectedDate: Date = Date()
    
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
    
    var dailyMoods: [MoodEntry] {
        history.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }.sorted { $0.date < $1.date }
    }
    
    var moodForecast: String {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let weekday = Calendar.current.component(.weekday, from: tomorrow)
        let pastMoods = history.filter { Calendar.current.component(.weekday, from: $0.date) == weekday }
        if pastMoods.isEmpty { return "No data for predictions yet." }
        let counts = Dictionary(grouping: pastMoods, by: { $0.mood.name })
        let mostCommon = counts.max { $0.value.count < $1.value.count }?.key ?? "Unknown"
        return "Based on your patterns, tomorrow might feel \(mostCommon)."
    }
    
    let challenges: [Challenge] = [
        Challenge(name: "Daily Spin", goal: 1, reward: "Unlock Starter Badge"),
        Challenge(name: "Week Streak", goal: 7, reward: "New App Theme"),
        Challenge(name: "Month Master", goal: 30, reward: "Custom Mood Pack")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    StatCard(title: "Days Tracked", value: "\(daysTracked)")
                    StatCard(title: "Most Common Mood", value: mostCommonMood)
                    StatCard(title: "Most Common Habit", value: mostCommonHabit)
                    StatCard(title: "Best Mood Streak", value: "\(bestStreak) days")
                    StatCard(title: "Current Streak", value: "\(currentStreak) days")
                    
                    CardView {
                        Text("Mood Forecast")
                            .font(.headline)
                        Text(moodForecast)
                            .font(.subheadline)
                            .animation(.spring())
                    }
                    
                    CardView {
                        Text("Daily Mood Changes")
                            .font(.headline)
                        DatePicker("Select Day", selection: $selectedDate, displayedComponents: .date)
                        if !dailyMoods.isEmpty {
                            DailyMoodChart(moods: dailyMoods)
                                .frame(height: 200)
                        } else {
                            Text("No entries for this day")
                        }
                    }
                    
                    CardView {
                        Text("Challenges")
                            .font(.headline)
                        ForEach(challenges) { challenge in
                            ChallengeRow(challenge: challenge, currentStreak: bestStreak)
                        }
                    }
                    
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
                    
    //                Text("Mood Over Weeks")
    //                    .font(.headline)
    //                Text("Graph placeholder")
                    
                    NavigationLink("Generate Report", destination: ReportsView(history: history))
                        .buttonStyle(NeumorphicButtonStyle())
                }
                .padding()
            }
            .navigationTitle("Stats")
            .onAppear {
                history = loadHistory()
            }
            .onChange(of: bestStreak) { _ in checkChallengeCompletion() }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func loadHistory() -> [MoodEntry] {
        if let history = try? JSONDecoder().decode([MoodEntry].self, from: moodHistoryData) {
            return history
        }
        return []
    }
    
    func checkChallengeCompletion() {
        for challenge in challenges {
            if bestStreak >= challenge.goal {
                // Schedule notification
                let content = UNMutableNotificationContent()
                content.title = "Challenge Completed!"
                content.body = "You achieved \(challenge.name)! Reward: \(challenge.reward)"
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
                // Unlock reward, e.g., set UserDefaults for new theme
            }
        }
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

struct Challenge: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    let goal: Int
    let reward: String
}

struct ChallengeRow: View {
    let challenge: Challenge
    let currentStreak: Int
    
    var progress: Double { min(Double(currentStreak) / Double(challenge.goal), 1.0) }
    
    var body: some View {
        HStack {
            Text(challenge.name)
            Spacer()
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .pink))
                .frame(width: 100)
            Text(challenge.reward)
                .font(.caption)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct DailyMoodChart: View {
    let moods: [MoodEntry]
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            let points = moods.enumerated().map { index, entry in
                CGPoint(x: CGFloat(index) / CGFloat(moods.count - 1) * geo.size.width, y: geo.size.height * (1 - entry.mood.value))
            }
            Path { path in
                path.move(to: points.first ?? .zero)
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .trim(from: 0, to: animationProgress)
            .stroke(LinearGradient(gradient: Gradient(colors: [.blue, .purple, .pink]), startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .animation(.easeInOut(duration: 1.5))
            .onAppear {
                animationProgress = 1.0
            }
            ForEach(0..<points.count, id: \.self) { i in
                Circle()
                    .fill(moods[i].mood.swiftColor)
                    .frame(width: 10, height: 10)
                    .position(points[i])
                    .scaleEffect(animationProgress)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(i) * 0.1))
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

struct ReportsView: View {
    let history: [MoodEntry]
    @State private var period: Period = .weekly
    @State private var animationPhase: Double = 0
    
    enum Period { case weekly, monthly }
    
    var filteredHistory: [MoodEntry] {
        let startDate = period == .weekly ? Calendar.current.date(byAdding: .day, value: -7, to: Date())! : Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        return history.filter { $0.date >= startDate }.sorted { $0.date < $1.date }
    }
    
    var improvement: Double {
        guard !filteredHistory.isEmpty else { return 0 }
        let half = filteredHistory.count / 2
        let earlyAvg = filteredHistory.prefix(half).reduce(0.0) { $0 + $1.mood.value } / Double(half)
        let lateAvg = filteredHistory.suffix(half).reduce(0.0) { $0 + $1.mood.value } / Double(half)
        return (lateAvg - earlyAvg) / earlyAvg * 100
    }
    
    var advice: String {
        if improvement > 0 {
            return "Your mood has improved by \(Int(improvement))%! Keep nurturing positive habits."
        } else if improvement < 0 {
            return "Mood dipped by \(Int(-improvement))%. Consider more rest or stress-relief activities."
        } else {
            return "Your mood is stable. Maintain the balance!"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Picker("Period", selection: $period) {
                    Text("Weekly").tag(Period.weekly)
                    Text("Monthly").tag(Period.monthly)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                CardView {
                    Text(advice)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                MoodPieChart(history: filteredHistory)
                    .frame(height: 250)
                    .scaleEffect(1 + abs(sin(animationPhase)) * 0.05)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: true)) {
                            animationPhase = .pi * 2
                        }
                    }
                
                DailyMoodChart(moods: filteredHistory)
                    .frame(height: 200)
            }
            .padding()
        }
        .navigationTitle("Reports")
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]), startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }
}

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 10)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(LinearGradient(colors: [.pink, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
    }
}
