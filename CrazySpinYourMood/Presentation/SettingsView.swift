import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("theme") private var theme: String = "Bright"
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("moodHistory") private var moodHistoryData: Data = Data()
    @State var reminderTime: Date = Date()
    // @State var moodHistoryData: Data = Data()
    
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
}
