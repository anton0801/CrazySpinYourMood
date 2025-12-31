import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue, Color.yellow, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack {
                MoodWheel(rotation: $rotation, selectedMood: .constant(nil))
                    .frame(width: 200, height: 200)
                    .shadow(color: .white.opacity(0.5), radius: 10, x: 0, y: 0)
                
                Text("Crazy Spin Your Mood")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .white, radius: 5)
            }
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct OnboardingView: View {
    @Binding var isFirstLaunch: Bool
    var finished: () -> Void
    @State private var currentPage: Int = 0
    @State private var iconRotation: Double = 0
    @State private var glowOpacity: Double = 0.5
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Spin to Feel Your Mood",
            description: "Kickstart your day with a fun spin! Let the wheel capture your current vibe and set the tone for mindful reflection.",
            icon: "arrow.clockwise.circle.fill"
        ),
        OnboardingPage(
            title: "Track Your Daily Emotions",
            description: "Build a personal diary of your feelings. See how your moods evolve over days, weeks, and months for better self-awareness.",
            icon: "chart.bar.fill"
        ),
        OnboardingPage(
            title: "Understand Your Energy Patterns",
            description: "Unlock insights into your emotional rhythms. Discover trends, triggers, and tips to enhance your energy and overall well-being.",
            icon: "bolt.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8), Color.yellow.opacity(0.6), Color.pink.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index], iconRotation: $iconRotation, glowOpacity: $glowOpacity)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            VStack {
                Spacer()
                HStack {
                    if currentPage > 0 {
                        Button(action: {
                            isFirstLaunch = false
                        }) {
                            Text("Skip")
                                .font(.headline)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(20)
                                .shadow(color: .yellow.opacity(0.5), radius: 5)
                        }
                    }
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .font(.headline)
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .shadow(color: .pink.opacity(0.5), radius: 5)
                        }
                    } else {
                        Button(action: {
                            isFirstLaunch = false
                            finished()
                        }) {
                            Text("Start")
                                .font(.headline)
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.pink]), startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .shadow(color: .blue.opacity(0.5), radius: 5)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowOpacity = 1.0
        }
        withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
            iconRotation = 360
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @Binding var iconRotation: Double
    @Binding var glowOpacity: Double
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: page.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.yellow)
                .shadow(color: .white.opacity(glowOpacity), radius: 15)
                .rotationEffect(.degrees(iconRotation))
                .overlay(
                    Circle()
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.yellow]), startPoint: .top, endPoint: .bottom), lineWidth: 4)
                        .frame(width: 140, height: 140)
                        .opacity(0.8)
                )
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}
