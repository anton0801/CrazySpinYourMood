import SwiftUI

struct ContentView: View {
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @AppStorage("showSplash") private var showSplash: Bool = true
    @State private var showOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView(showSplash: $showSplash)
            } else if isFirstLaunch || showOnboarding {
                OnboardingView(isFirstLaunch: $isFirstLaunch) {
                    showOnboarding = false
                }
            } else {
                MainTabView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSplash = false
                }
                if isFirstLaunch {
                    showOnboarding = true
                }
            }
        }
    }
}
#Preview {
    ContentView()
}

struct MainTabView: View {
    var body: some View {
        TabView {
            SpinView()
                .tabItem {
                    Label("Spin", systemImage: "arrow.clockwise")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.pie")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.purple)
    }
}
