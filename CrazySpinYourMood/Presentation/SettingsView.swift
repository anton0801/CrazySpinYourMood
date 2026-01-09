import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("theme") private var theme: String = "Bright"
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("moodHistory") private var moodHistoryData: Data = Data()
    @State var reminderTime: Date = Date()
    // @State var moodHistoryData: Data = Data()
    
    @AppStorage("customMoods") private var customMoodsData: Data = try! JSONEncoder().encode(defaultMoods)
    @State private var moods: [Mood] = []
    
    var body: some View {
        Form {
            Section(header: Text("Theme")) {
                Picker("Theme", selection: $theme) {
                    Text("Bright").tag("Bright")
                    Text("Dark").tag("Dark")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Sound")) {
                Toggle("Sound ON/OFF", isOn: $soundEnabled)
            }
            
            Section(header: Text("Custom Moods")) {
                List {
                    ForEach($moods) { $mood in
                        NavigationLink(destination: EditMoodView(mood: $mood, onSave: saveMoods)) {
                            HStack {
                                Text(mood.icon)
                                Text(mood.name)
                                Spacer()
                                Circle().fill(mood.swiftColor).frame(width: 20)
                            }
                        }
                    }
                    .onDelete(perform: deleteMood)
                }
                Button("Add New Mood") {
                    let newMood = Mood(name: "New Mood", icon: "🙂", color: "#FFFFFF", advice: "Enter advice", value: 0.5)
                    moods.append(newMood)
                    saveMoods()
                }
            }
            
            Section(header: Text("Reminders")) {
                Toggle("Reminder ON/OFF", isOn: $reminderEnabled)
                    .onChange(of: reminderEnabled) { newValue in
                        if newValue {
                            scheduleReminder()
                        } else {
                            cancelReminder()
                        }
                    }
                //                if reminderEnabled {
                //                    DatePicker("Time", selection: $reminderTime, displayedComponents: .time)
                //                        .onChange(of: reminderTime) { _ in
                //                            scheduleReminder()
                //                        }
                //                }
            }
            
            Section {
                Button("Reset History") {
                    moodHistoryData = Data()
                }
            }
            
            //            Section(header: Text("About")) {
            //                Text("Privacy Policy")
            //                Text("About")
            //            }
        }
        .navigationTitle("Settings")
        .onAppear {
            requestNotificationPermission()
            moods = (try? JSONDecoder().decode([Mood].self, from: customMoodsData)) ?? defaultMoods
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    func scheduleReminder() {
        cancelReminder()
        let content = UNMutableNotificationContent()
        content.title = "Spin your mood for today"
        content.body = "How do you feel?"
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dailyMoodReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyMoodReminder"])
    }
    
    func deleteMood(at offsets: IndexSet) {
        moods.remove(atOffsets: offsets)
        saveMoods()
    }
    
    func saveMoods() {
        if let data = try? JSONEncoder().encode(moods) {
            customMoodsData = data
        }
    }
}

struct EditMoodView: View {
    @Binding var mood: Mood
    let onSave: () -> Void
    @State private var selectedColor: Color
    
    init(mood: Binding<Mood>, onSave: @escaping () -> Void) {
        _mood = mood
        self.onSave = onSave
        _selectedColor = State(initialValue: mood.wrappedValue.swiftColor)
    }
    
    var body: some View {
        Form {
            TextField("Name", text: $mood.name)
            TextField("Icon (Emoji)", text: $mood.icon)
            ColorPicker("Color", selection: $selectedColor)
            TextField("Advice", text: $mood.advice)
            Slider(value: $mood.value, in: 0...1, step: 0.1) {
                Text("Mood Value (0-1)")
            }
        }
        .navigationTitle("Edit Mood")
        .onChange(of: selectedColor) { newValue in
            mood.color = newValue.hex
        }
        .onDisappear {
            onSave()
        }
    }
}
