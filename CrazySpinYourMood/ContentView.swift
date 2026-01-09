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
    @AppStorage("theme") private var theme: String = "Bright"
    
    var body: some View {
        TabView {
            SpinView()
                .tabItem { Label("Spin", systemImage: "arrow.clockwise") }
            
            HistoryView()
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
            
            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.pie") }
            
            LearnView()
                .tabItem { Label("Learn", systemImage: "book.fill") }
            
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .accentColor(.purple)
        .environment(\.colorScheme, theme == "Dark" ? .dark : .light)
        .preferredColorScheme(theme == "Dark" ? .dark : .light)
    }
}

struct NeumorphicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.5), radius: 5, x: 5, y: 5)
            .shadow(color: .white.opacity(0.7), radius: 5, x: -5, y: -5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
