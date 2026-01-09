import SwiftUI

struct CalendarView: View {
    @AppStorage("moodHistory") private var moodHistoryData: Data = Data()
    let month: Date
    
    init(month: Date = Date()) {
        self.month = month
    }
    
    var body: some View {
        let days = generateDaysInMonth(for: month)
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(days, id: \.self) { day in
                if let moodColor = getMoodColor(for: day) {
                    Text("\(Calendar.current.component(.day, from: day))")
                        .frame(maxWidth: .infinity)
                        .background(moodColor.opacity(0.5))
                        .cornerRadius(5)
                } else {
                    Text("\(Calendar.current.component(.day, from: day))")
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    func generateDaysInMonth(for date: Date) -> [Date] {
        guard let range = Calendar.current.range(of: .day, in: .month, for: date) else { return [] }
        return range.compactMap { day -> Date? in
            Calendar.current.date(bySetting: .day, value: day, of: date)
        }
    }
    
    func getMoodColor(for date: Date) -> Color? {
        let history = loadHistory()
        if let entry = history.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            return entry.mood.swiftColor
        }
        return nil
    }
    
    func loadHistory() -> [MoodEntry] {
        if let history = try? JSONDecoder().decode([MoodEntry].self, from: moodHistoryData) {
            return history
        }
        return []
    }
}
