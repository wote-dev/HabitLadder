//
//  ContentView.swift
//  HabitLadder
//
//  Created by Daniel Zverev on 1/7/2025.
//

import SwiftUI
import Foundation

// MARK: - Onboarding System
struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isAnimating = false
    @State private var backgroundGradientAnimation = false
    @State private var selectedProfile: HabitProfile?
    @State private var showWalkthrough = false
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var habitManager: HabitManager
    
    let onComplete: () -> Void
    
    private let freeProfiles: [HabitProfile] = [
        HabitProfile(type: .basicWellness, habits: [
            Habit(name: "Drink water upon waking", description: "Start your day hydrated"),
            Habit(name: "Take 3 deep breaths", description: "Center yourself for the day"),
            Habit(name: "Eat one piece of fruit", description: "Get essential vitamins"),
            Habit(name: "Step outside for 2 minutes", description: "Connect with nature"),
            Habit(name: "Express gratitude", description: "End your day positively")
        ]),
        HabitProfile(type: .morningStarter, habits: [
            Habit(name: "Make your bed", description: "Start with a small win"),
            Habit(name: "Drink a glass of water", description: "Rehydrate after sleep"),
            Habit(name: "Write 3 priorities", description: "Focus your day"),
            Habit(name: "Do 5 jumping jacks", description: "Wake up your body"),
            Habit(name: "Read for 5 minutes", description: "Feed your mind")
        ]),
        HabitProfile(type: .focusEssentials, habits: [
            Habit(name: "Clear your workspace", description: "Start with a clean environment"),
            Habit(name: "Set a 25-minute timer", description: "Use the Pomodoro technique"),
            Habit(name: "Turn off notifications", description: "Eliminate distractions"),
            Habit(name: "Take a 5-minute break", description: "Rest between focus sessions"),
            Habit(name: "Review what you accomplished", description: "Celebrate your progress")
        ]),
        HabitProfile(type: .sleepHygiene, habits: [
            Habit(name: "Set phone to Do Not Disturb", description: "Prepare for rest"),
            Habit(name: "Dim the lights 1 hour before bed", description: "Signal your body it's bedtime"),
            Habit(name: "Write tomorrow's top 3 tasks", description: "Clear your mind"),
            Habit(name: "Do gentle stretches", description: "Relax your body"),
            Habit(name: "Practice gratitude", description: "End with positive thoughts")
        ])
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Enhanced gradient background with dynamic animation
                ZStack {
                    // Base gradient
                    LinearGradient(
                        colors: [
                            HabitTheme.backgroundPrimary,
                            HabitTheme.backgroundSecondary,
                            currentPage == 0 ? HabitTheme.primary.opacity(0.08) : 
                            (currentPage == 1 ? HabitTheme.accent.opacity(0.08) : HabitTheme.success.opacity(0.08))
                        ],
                        startPoint: backgroundGradientAnimation ? .topTrailing : .topLeading,
                        endPoint: backgroundGradientAnimation ? .bottomLeading : .bottomTrailing
                    )
                    
                    // Floating orbs for depth
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        (currentPage == 0 ? HabitTheme.primary : HabitTheme.accent).opacity(0.15),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .offset(
                                x: backgroundGradientAnimation ? CGFloat.random(in: -50...50) : CGFloat.random(in: -30...30),
                                y: backgroundGradientAnimation ? CGFloat.random(in: -100...100) : CGFloat.random(in: -50...50)
                            )
                            .animation(
                                .easeInOut(duration: Double.random(in: 3...5))
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.5),
                                value: backgroundGradientAnimation
                            )
                    }
                }
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: backgroundGradientAnimation)
                
                if showWalkthrough {
                    FirstHabitWalkthroughView(
                        selectedProfile: selectedProfile!,
                        onComplete: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showWalkthrough = false
                                onComplete()
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))
                } else {
                    VStack(spacing: 0) {
                        // Skip button
                        HStack {
                            Spacer()
                            Button("Skip") {
                                onComplete()
                            }
                            .font(.subheadline)
                            .foregroundColor(Color.secondary)
                            .padding()
                        }
                        
                        // Page content
                        TabView(selection: $currentPage) {
                            // Screen 1: Welcome + Ladder Concept
                            WelcomeLadderView(geometry: geometry, isActive: currentPage == 0)
                                .tag(0)
                            
                            // Screen 2: Choose Starter Profile
                            ProfileSelectionView(
                                geometry: geometry,
                                isActive: currentPage == 1,
                                selectedProfile: $selectedProfile,
                                profiles: freeProfiles
                            )
                            .tag(1)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .animation(.spring(response: 0.6, dampingFraction: 0.85, blendDuration: 0.2), value: currentPage)
                        
                        // Page indicators and controls
                        VStack(spacing: 20) {
                            // Page indicators
                            HStack(spacing: 8) {
                                ForEach(0..<2, id: \.self) { index in
                                    Circle()
                                        .fill(currentPage == index ? HabitTheme.primary : HabitTheme.inactive.opacity(0.5))
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
                                }
                            }
                            
                            // Navigation buttons
                            HStack(spacing: 16) {
                                if currentPage > 0 {
                                    Button("Previous") {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            currentPage -= 1
                                        }
                                    }
                                    .font(.headline)
                                    .foregroundColor(Color.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            HabitTheme.cardBackground.opacity(0.9),
                                                            HabitTheme.cardBackground.opacity(0.7)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(.regularMaterial)
                                                )
                                            
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.white.opacity(0.1),
                                                            Color.clear
                                                        ],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(
                                                    HabitTheme.inactive.opacity(0.4),
                                                    lineWidth: 1.5
                                                )
                                        )
                                        .shadow(
                                            color: Color.black.opacity(0.08),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                    )
                                }
                                
                                Button(getButtonText()) {
                                    handleButtonTap()
                                }
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(buttonTextColor())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    ZStack {
                                        // Glass morphism base
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(
                                                LinearGradient(
                                                    colors: currentPage == 1 && selectedProfile == nil ? [
                                                        HabitTheme.inactive.opacity(0.4),
                                                        HabitTheme.inactive.opacity(0.2)
                                                    ] : [
                                                        (currentPage == 0 ? HabitTheme.primary : (selectedProfile?.gradientColors.first ?? HabitTheme.accent)),
                                                        (currentPage == 0 ? HabitTheme.primary : (selectedProfile?.gradientColors.first ?? HabitTheme.accent)).opacity(0.8)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(.ultraThinMaterial)
                                            )
                                        
                                        // Highlight overlay
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(currentPage == 1 && selectedProfile == nil ? 0.05 : 0.2),
                                                        Color.clear
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                    }
                                    .shadow(
                                        color: currentPage == 1 && selectedProfile == nil ? 
                                            Color.black.opacity(0.05) : 
                                            (currentPage == 0 ? HabitTheme.primary : (selectedProfile?.gradientColors.first ?? HabitTheme.accent)).opacity(0.3),
                                        radius: currentPage == 1 && selectedProfile == nil ? 4 : 12,
                                        x: 0,
                                        y: currentPage == 1 && selectedProfile == nil ? 2 : 6
                                    )
                                    .shadow(
                                        color: currentPage == 1 && selectedProfile == nil ? 
                                            Color.clear : 
                                            (currentPage == 0 ? HabitTheme.primary : (selectedProfile?.gradientColors.last ?? HabitTheme.accent)).opacity(0.2),
                                        radius: currentPage == 1 && selectedProfile == nil ? 0 : 20,
                                        x: 0,
                                        y: 0
                                    )
                                )
                                .scaleEffect(isAnimating ? 0.95 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAnimating)
                                .disabled(currentPage == 1 && selectedProfile == nil)
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, max(20, geometry.safeAreaInsets.bottom))
                    }
                }
            }
        }
        .onAppear {
            backgroundGradientAnimation = true
        }
    }
    
    private func getButtonText() -> String {
        switch currentPage {
        case 0: return "Next"
        case 1: return selectedProfile != nil ? "Start Tutorial" : "Choose a Profile"
        default: return "Get Started"
        }
    }
    
    private func handleButtonTap() {
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isAnimating = false
        }
        
        switch currentPage {
        case 0:
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentPage = 1
            }
        case 1:
            if let profile = selectedProfile {
                // Activate the selected profile
                habitManager.activateHabitProfile(profile)
                
                // Wait a moment for profile activation to complete, then start walkthrough
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showWalkthrough = true
                    }
                }
            }
        default:
            onComplete()
        }
    }
    
    private func buttonTextColor() -> Color {
        if currentPage == 1 && selectedProfile == nil {
            return HabitTheme.secondaryText
        }
        return .white
    }
    
    private func buttonBackground() -> AnyShapeStyle {
        if currentPage == 1 && selectedProfile == nil {
            return AnyShapeStyle(HabitTheme.inactive.opacity(0.3))
        }
        
        let color = currentPage == 0 ? HabitTheme.primary : 
                   (selectedProfile?.gradientColors.first ?? HabitTheme.accent)
        
        return AnyShapeStyle(LinearGradient(
            colors: [color, color.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        ))
    }
}

// MARK: - Welcome + Ladder Concept View
struct WelcomeLadderView: View {
    let geometry: GeometryProxy
    let isActive: Bool
    
    @State private var iconScale: CGFloat = 0.8
    @State private var contentOffset: CGFloat = 50
    @State private var contentOpacity: Double = 0
    @State private var ladderAnimationOffset: CGFloat = 20
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer(minLength: 40)
                
                // App Icon with animation
                VStack(spacing: 24) {
                    ZStack {
                        // Glass morphism background
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        HabitTheme.primary.opacity(0.15),
                                        HabitTheme.accent.opacity(0.1),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                            )
                            .frame(width: 100, height: 100)
                        
                        // App icon
                        Image("SplashIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        HabitTheme.primary.opacity(0.4),
                                        HabitTheme.accent.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(
                        color: HabitTheme.primary.opacity(0.3),
                        radius: 20,
                        x: 0,
                        y: 10
                    )
                    .shadow(
                        color: HabitTheme.accent.opacity(0.2),
                        radius: 35,
                        x: 0,
                        y: 0
                    )
                    .scaleEffect(iconScale)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: iconScale)
                }
                
                // Title and subtitle
                VStack(spacing: 12) {
                    Text("Welcome to HabitLadder")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(HabitTheme.primaryText)
                        .multilineTextAlignment(.center)
                        .offset(y: contentOffset)
                        .opacity(contentOpacity)
                    
                    Text("Build Better Habits, One Step at a Time")
                        .font(.title2)
                        .foregroundColor(HabitTheme.accent)
                        .multilineTextAlignment(.center)
                        .offset(y: contentOffset)
                        .opacity(contentOpacity)
                }
                
                // Ladder concept visualization
                VStack(spacing: 16) {
                    Text("The Ladder System")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(HabitTheme.primaryText)
                        .offset(y: contentOffset)
                        .opacity(contentOpacity)
                    
                    // Visual ladder representation
                    VStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            HStack(spacing: 12) {
                                // Step number
                                ZStack {
                                    Circle()
                                        .fill(index == 0 ? HabitTheme.success : 
                                             (index == 1 ? HabitTheme.warning : HabitTheme.inactive))
                                        .frame(width: 32, height: 32)
                                    
                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                
                                // Step description
                                VStack(alignment: .leading, spacing: 2) {
                                    let titles = ["Complete for 3 days", "Unlock next habit", "Build momentum"]
                                    let descriptions = ["Build consistency", "Progress naturally", "Transform your life"]
                                    
                                    Text(titles[index])
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(HabitTheme.primaryText)
                                    
                                    Text(descriptions[index])
                                        .font(.caption)
                                        .foregroundColor(HabitTheme.secondaryText)
                                }
                                
                                Spacer()
                                
                                // Arrow for all but last
                                if index < 2 {
                                    Image(systemName: "arrow.down")
                                        .font(.caption)
                                        .foregroundColor(HabitTheme.accent)
                                }
                            }
                            .padding(.horizontal, 20)
                            .offset(y: ladderAnimationOffset)
                            .opacity(contentOpacity)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(Double(index) * 0.2),
                                value: contentOpacity
                            )
                        }
                    }
                    .padding(.vertical, 20)
                    .background(
                        ZStack {
                            // Glass morphism base
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            HabitTheme.cardBackground.opacity(0.9),
                                            HabitTheme.cardBackground.opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.regularMaterial)
                                )
                            
                            // Highlight overlay
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.1),
                                            Color.clear
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            HabitTheme.primary.opacity(0.3),
                                            HabitTheme.accent.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(
                            color: HabitTheme.primary.opacity(0.15),
                            radius: 15,
                            x: 0,
                            y: 8
                        )
                    )
                    .padding(.horizontal, 20)
                }
                
                // Key benefits
                VStack(spacing: 12) {
                    ForEach(Array([
                        ("arrow.up.circle.fill", "Progressive building prevents overwhelm"),
                        ("chart.line.uptrend.xyaxis", "Visual progress keeps you motivated"),
                        ("sparkles", "Celebrations make habits enjoyable")
                    ].enumerated()), id: \.offset) { index, item in
                        HStack(spacing: 12) {
                            Image(systemName: item.0)
                                .foregroundColor(HabitTheme.primary)
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(item.1)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(HabitTheme.primaryText)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .offset(y: contentOffset)
                        .opacity(contentOpacity)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.85)
                            .delay(Double(index) * 0.1 + 0.6),
                            value: contentOpacity
                        )
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            if isActive {
                startAnimations()
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        // Icon animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            iconScale = 1.0
        }
        
        // Content animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4)) {
            contentOffset = 0
            contentOpacity = 1.0
        }
        
        // Ladder animation
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.8)) {
            ladderAnimationOffset = 0
        }
    }
}

// MARK: - Profile Selection View
struct ProfileSelectionView: View {
    let geometry: GeometryProxy
    let isActive: Bool
    @Binding var selectedProfile: HabitProfile?
    let profiles: [HabitProfile]
    
    @State private var contentOffset: CGFloat = 50
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer(minLength: 40)
                
                // Header
                VStack(spacing: 16) {
                    Text("Choose Your Starting Path")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(HabitTheme.primaryText)
                        .multilineTextAlignment(.center)
                        .offset(y: contentOffset)
                        .opacity(contentOpacity)
                    
                    Text("Pick a curated set of habits designed for your lifestyle")
                        .font(.body)
                        .foregroundColor(HabitTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .offset(y: contentOffset)
                        .opacity(contentOpacity)
                }
                
                // Profile cards
                LazyVStack(spacing: 16) {
                    ForEach(Array(profiles.enumerated()), id: \.element.id) { index, profile in
                        OnboardingProfileCard(
                            profile: profile,
                            isSelected: selectedProfile?.id == profile.id,
                            onTap: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedProfile = profile
                                }
                            }
                        )
                        .offset(y: contentOffset)
                        .opacity(contentOpacity)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1),
                            value: contentOpacity
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            if isActive {
                startAnimations()
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
            contentOffset = 0
            contentOpacity = 1.0
        }
    }
}

// MARK: - Onboarding Profile Card Component
struct OnboardingProfileCard: View {
    let profile: HabitProfile
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(HabitTheme.primaryText)
                        
                        Text(profile.description)
                            .font(.subheadline)
                            .foregroundColor(HabitTheme.secondaryText)
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    ZStack {
                        Circle()
                            .stroke(isSelected ? HabitTheme.primary : HabitTheme.inactive, lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if isSelected {
                            Circle()
                                .fill(HabitTheme.primary)
                                .frame(width: 12, height: 12)
                                .scaleEffect(isSelected ? 1.0 : 0.1)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                        }
                    }
                }
                
                // Sample habits preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Includes:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(HabitTheme.secondaryText)
                    
                    ForEach(Array(profile.habits.prefix(3).enumerated()), id: \.offset) { index, habit in
                        HStack(spacing: 8) {
                            Text("•")
                                .foregroundColor(profile.gradientColors.first ?? HabitTheme.accent)
                                .fontWeight(.bold)
                            
                            Text(habit.name)
                                .font(.caption)
                                .foregroundColor(HabitTheme.primaryText)
                            
                            Spacer()
                        }
                    }
                    
                    if profile.habits.count > 3 {
                        Text("+ \(profile.habits.count - 3) more habits")
                            .font(.caption2)
                            .foregroundColor(HabitTheme.secondaryText)
                            .italic()
                    }
                }
            }
            .padding(24)
            .background(
                ZStack {
                    // Glass morphism base
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: isSelected ? [
                                    (profile.gradientColors.first ?? HabitTheme.primary).opacity(0.12),
                                    (profile.gradientColors.last ?? HabitTheme.accent).opacity(0.08)
                                ] : [
                                    HabitTheme.cardBackground.opacity(0.9),
                                    HabitTheme.cardBackground.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(isSelected ? .ultraThinMaterial : .regularMaterial)
                        )
                    
                    // Highlight overlay
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isSelected ? 0.15 : 0.08),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: isSelected ? [
                                    (profile.gradientColors.first ?? HabitTheme.primary).opacity(0.6),
                                    (profile.gradientColors.last ?? HabitTheme.accent).opacity(0.4)
                                ] : [
                                    HabitTheme.inactive.opacity(0.3),
                                    HabitTheme.inactive.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 2 : 1.5
                        )
                )
                .shadow(
                    color: isSelected ? (profile.gradientColors.first?.opacity(0.25) ?? .clear) : Color.black.opacity(0.05),
                    radius: isSelected ? 15 : 8,
                    x: 0,
                    y: isSelected ? 8 : 4
                )
                .shadow(
                    color: isSelected ? (profile.gradientColors.last?.opacity(0.15) ?? .clear) : .clear,
                    radius: isSelected ? 25 : 0,
                    x: 0,
                    y: 0
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - First Habit Walkthrough
struct FirstHabitWalkthroughView: View {
    let selectedProfile: HabitProfile
    let onComplete: () -> Void
    
    @State private var currentStep = 0
    @State private var isAnimating = false
    @State private var showCompletionCelebration = false
    @State private var hasCompletedFirstHabit = false
    @EnvironmentObject var habitManager: HabitManager
    
    private let walkthroughSteps = [
        WalkthroughStep(
            title: "Meet Your First Habit",
            description: "This is your starting habit. You only need to focus on this one for now.",
            highlightArea: .habitCard,
            actionText: "Got it!"
        ),
        WalkthroughStep(
            title: "Complete Your Habit",
            description: "Tap the circle to mark this habit as complete for today.",
            highlightArea: .completeButton,
            actionText: "Mark Complete"
        ),
        WalkthroughStep(
            title: "Track Your Progress",
            description: "See your streak counter! Complete this habit 3 days in a row to unlock the next one.",
            highlightArea: .streakCounter,
            actionText: "Amazing!"
        ),
        WalkthroughStep(
            title: "You're All Set!",
            description: "Keep building your habits one day at a time. Remember: consistency beats perfection!",
            highlightArea: .none,
            actionText: "Start My Journey"
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    HabitTheme.backgroundPrimary,
                    HabitTheme.backgroundSecondary,
                    HabitTheme.success.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("Let's Get Started!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(HabitTheme.primaryText)
                    
                    Text("Here's how HabitLadder works")
                        .font(.body)
                        .foregroundColor(HabitTheme.secondaryText)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Demo habit card
                if let firstHabit = habitManager.habits.first {
                    DemoHabitCard(
                        habit: firstHabit,
                        currentStep: currentStep,
                        hasCompleted: hasCompletedFirstHabit,
                        onComplete: {
                            if currentStep == 1 {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    hasCompletedFirstHabit = true
                                    showCompletionCelebration = true
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showCompletionCelebration = false
                                        currentStep = 2
                                    }
                                }
                            }
                        }
                    )
                }
                
                Spacer()
                
                // Walkthrough instruction panel
                WalkthroughInstructionPanel(
                    step: walkthroughSteps[currentStep],
                    onAction: handleStepAction
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            
            // Celebration overlay
            if showCompletionCelebration {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("🎉")
                            .font(.system(size: 60))
                            .scaleEffect(showCompletionCelebration ? 1.0 : 0.1)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showCompletionCelebration)
                        
                        Text("Great job!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("You completed your first habit!")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .scaleEffect(showCompletionCelebration ? 1.0 : 0.8)
                    .opacity(showCompletionCelebration ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCompletionCelebration)
                }
            }
        }
    }
    
    private func handleStepAction() {
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isAnimating = false
        }
        
        if currentStep < walkthroughSteps.count - 1 {
            if currentStep == 1 && !hasCompletedFirstHabit {
                // Don't advance until they complete the habit
                return
            }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        } else {
            onComplete()
        }
    }
}

// MARK: - Walkthrough Step Model
struct WalkthroughStep {
    let title: String
    let description: String
    let highlightArea: HighlightArea
    let actionText: String
    
    enum HighlightArea {
        case habitCard
        case completeButton
        case streakCounter
        case none
    }
}

// MARK: - Demo Habit Card
struct DemoHabitCard: View {
    let habit: Habit
    let currentStep: Int
    let hasCompleted: Bool
    let onComplete: () -> Void
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Habit info
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(habit.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(HabitTheme.primaryText)
                    
                    Text(habit.description)
                        .font(.subheadline)
                        .foregroundColor(HabitTheme.secondaryText)
                    
                    // Streak counter - highlighted in step 2
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text("\(hasCompleted ? 1 : 0)/3")
                            .font(.caption)
                            .foregroundColor(hasCompleted ? .green : HabitTheme.secondaryText)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(currentStep == 2 ? HabitTheme.warning.opacity(0.2) : HabitTheme.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(currentStep == 2 ? HabitTheme.warning : Color.clear, lineWidth: 2)
                            )
                    )
                    .scaleEffect(currentStep == 2 ? pulseScale : 1.0)
                }
                
                Spacer()
            }
            
            // Status and complete button
            HStack {
                if hasCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Completed today")
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "circle")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("Ready to complete")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                // Complete button - highlighted in step 1
                Button(action: onComplete) {
                    HStack(spacing: 8) {
                        Image(systemName: hasCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundColor(hasCompleted ? .green : .blue)
                        
                        Text(hasCompleted ? "Completed" : "Mark Complete")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(hasCompleted ? .green : .blue)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(hasCompleted ? Color.green.opacity(0.12) : Color.blue.opacity(0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        hasCompleted ? Color.green.opacity(0.4) : Color.blue.opacity(0.4),
                                        lineWidth: currentStep == 1 ? 3 : 1.5
                                    )
                            )
                            .shadow(
                                color: currentStep == 1 ? Color.blue.opacity(0.4) : .clear,
                                radius: currentStep == 1 ? 12 : 0,
                                x: 0,
                                y: 0
                            )
                    )
                }
                .disabled(hasCompleted)
                .scaleEffect(currentStep == 1 ? pulseScale : 1.0)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(HabitTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            currentStep == 0 ? HabitTheme.primary : Color.clear,
                            lineWidth: currentStep == 0 ? 3 : 0
                        )
                )
                .shadow(
                    color: currentStep == 0 ? HabitTheme.primary.opacity(0.3) : .black.opacity(0.05),
                    radius: currentStep == 0 ? 16 : 10,
                    x: 0,
                    y: currentStep == 0 ? 8 : 4
                )
        )
        .padding(.horizontal, 20)
        .onAppear {
            if currentStep == 0 || currentStep == 1 || currentStep == 2 {
                startPulseAnimation()
            }
        }
        .onChange(of: currentStep) { _, newValue in
            if newValue == 0 || newValue == 1 || newValue == 2 {
                startPulseAnimation()
            }
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }
    }
}

// MARK: - Walkthrough Instruction Panel
struct WalkthroughInstructionPanel: View {
    let step: WalkthroughStep
    let onAction: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text(step.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(HabitTheme.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(step.description)
                    .font(.body)
                    .foregroundColor(HabitTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onAction) {
                Text(step.actionText)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [HabitTheme.success, HabitTheme.success.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
            }
            .scaleEffect(isAnimating ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAnimating)
            .onTapGesture {
                isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    isAnimating = false
                }
                onAction()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(HabitTheme.cardBackground)
                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - Color Theme
struct HabitTheme {
    // Primary colors using specific asset names to avoid conflicts
    static let primary = Color("AppPrimaryColor")
    static let secondary = Color("AppSecondaryColor") 
    static let accent = Color("AccentColor")
    
    // Background colors
    static let backgroundPrimary = Color("BackgroundPrimary")
    static let backgroundSecondary = Color("BackgroundSecondary")
    static let cardBackground = Color("CardBackground")
    
    // State colors
    static let success = Color("SuccessColor")
    static let warning = Color("WarningColor")
    static let inactive = Color("InactiveColor")
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0) // Celebration gold color
    
    // Enhanced gradient colors for modern UI
    static let gradientStart = Color("GradientStart")
    static let gradientEnd = Color("GradientEnd")
    
    // Semantic colors with dark mode support
    static let primaryText: Color = Color.primary
    static let secondaryText: Color = Color.secondary
    static let tertiaryText: Color = Color(UIColor.tertiaryLabel)
    
    // Enhanced background colors with better visual hierarchy
    static let unlockedBackground: Color = Color(UIColor.systemBackground)
    static let lockedBackground: Color = Color(UIColor.secondarySystemBackground).opacity(0.6)
    static let completedBackground: Color = Color(UIColor.systemGreen).opacity(0.15)
    
    static func completedBackgroundGradient() -> LinearGradient {
        LinearGradient(
            colors: [Color(UIColor.systemGreen).opacity(0.15), Color(UIColor.systemMint).opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Enhanced border colors with better contrast
    static let unlockedBorder: Color = Color(UIColor.systemBlue).opacity(0.4)
    static let lockedBorder: Color = Color(UIColor.separator).opacity(0.8)
    static let completedBorder: Color = Color(UIColor.systemGreen).opacity(0.6)
    
    // Modern shadow colors
    static let shadowLight: Color = Color.black.opacity(0.08)
    static let shadowMedium: Color = Color.black.opacity(0.12)
    static let shadowHeavy: Color = Color.black.opacity(0.16)
    
    // Glass morphism effect colors
    static let glassMorphismBackground: Color = Color.white.opacity(0.1)
    static let glassMorphismBorder: Color = Color.white.opacity(0.2)
    
    // Enhanced state-specific gradients
    static func completedGradient() -> LinearGradient {
        LinearGradient(
            colors: [Color(UIColor.systemGreen), Color(UIColor.systemMint)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func primaryGradient() -> LinearGradient {
        LinearGradient(
            colors: [primary, accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func warningGradient() -> LinearGradient {
        LinearGradient(
            colors: [warning, Color.orange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Modern Text Field Style
struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.body)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    // Glass morphism base
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [
                                    HabitTheme.cardBackground.opacity(0.9),
                                    HabitTheme.cardBackground.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.regularMaterial)
                        )
                    
                    // Highlight overlay
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Border gradient
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    HabitTheme.unlockedBorder.opacity(0.4),
                                    HabitTheme.unlockedBorder.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 10,
                    x: 0,
                    y: 5
                )
                .shadow(
                    color: Color.black.opacity(0.04),
                    radius: 4,
                    x: 0,
                    y: 2
                )
            )
    }
}

// MARK: - Modern Large Text Field Style for Titles
struct ModernLargeTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    // Glass morphism base
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [
                                    HabitTheme.cardBackground.opacity(0.9),
                                    HabitTheme.cardBackground.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(.regularMaterial)
                        )
                    
                    // Highlight overlay
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Border gradient
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    HabitTheme.unlockedBorder.opacity(0.5),
                                    HabitTheme.unlockedBorder.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 15,
                    x: 0,
                    y: 8
                )
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 6,
                    x: 0,
                    y: 3
                )
            )
    }
}

// MARK: - Confetti Particle
struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var velocityX: CGFloat
    var velocityY: CGFloat
    var color: Color
    var size: CGFloat
    var rotation: Double
    var rotationSpeed: Double
    var life: Double = 1.0
    
    static func createRandom(in rect: CGRect) -> ConfettiParticle {
        let celebrationColors: [Color] = [
            .red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan,
            .mint, .indigo, .teal, .brown, HabitTheme.gold,
            Color(red: 1.0, green: 0.4, blue: 0.6), // Hot pink
            Color(red: 0.5, green: 1.0, blue: 0.3), // Lime green
            Color(red: 1.0, green: 0.6, blue: 0.0), // Bright orange
            Color(red: 0.3, green: 0.8, blue: 1.0), // Sky blue
            Color(red: 1.0, green: 0.0, blue: 1.0)  // Magenta equivalent
        ]
        
        // Create particles from top and slightly off-screen for dramatic effect
        let startY = CGFloat.random(in: -100...(-20))
        let velocityMagnitude = CGFloat.random(in: 6...12)
        let angle = CGFloat.random(in: 0...(2 * .pi))
        
        return ConfettiParticle(
            x: CGFloat.random(in: 0...rect.width),
            y: startY,
            velocityX: cos(angle) * velocityMagnitude * CGFloat.random(in: 0.3...1.0),
            velocityY: sin(angle) * velocityMagnitude + CGFloat.random(in: 2...5),
            color: celebrationColors.randomElement() ?? .blue,
            size: CGFloat.random(in: 6...14),
            rotation: Double.random(in: 0...360),
            rotationSpeed: Double.random(in: -8...8)
        )
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var timer: Timer?
    let duration: TimeInterval
    
    init(duration: TimeInterval = 3.0) {
        self.duration = duration
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    RoundedRectangle(cornerRadius: particle.size * 0.2)
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.life)
                        .scaleEffect(particle.life * 0.8 + 0.2) // Fade out with scale
                }
            }
            .onAppear {
                startConfetti(in: geometry.size)
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
        .allowsHitTesting(false)
    }
    
    private func startConfetti(in size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        
        // Initial dramatic burst
        for _ in 0..<80 {
            particles.append(ConfettiParticle.createRandom(in: rect))
        }
        
        // Continuous generation with more particles
        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
            // Add new particles
            for _ in 0..<5 {
                particles.append(ConfettiParticle.createRandom(in: rect))
            }
            
            // Update existing particles
            particles = particles.compactMap { particle in
                var updatedParticle = particle
                updatedParticle.x += particle.velocityX
                updatedParticle.y += particle.velocityY
                updatedParticle.velocityY += 0.25 // gravity
                updatedParticle.velocityX *= 0.995 // air resistance
                updatedParticle.rotation += particle.rotationSpeed
                updatedParticle.life -= 0.015
                
                return updatedParticle.life > 0 && updatedParticle.y < size.height + 150 ? updatedParticle : nil
            }
        }
        
        // Stop after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            timer?.invalidate()
            withAnimation(.easeOut(duration: 1.5)) {
                particles.removeAll()
            }
        }
    }
}

// MARK: - Celebration Popup View
struct CelebrationPopup: View {
    let message: String
    @Binding var isShowing: Bool
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var rotationAngle: Double = -10
    @State private var bounceOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isShowing = false
                    }
                }
            
            // Celebration popup
            VStack(spacing: 20) {
                // Celebration icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange, Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.yellow.opacity(0.6), radius: 16, x: 0, y: 4)
                    
                    Text("🎉")
                        .font(.system(size: 40))
                        .rotationEffect(.degrees(rotationAngle))
                        .offset(y: bounceOffset)
                }
                
                // Message
                Text(message)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(HabitTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Tap to continue
                Text("Tap anywhere to continue")
                    .font(.caption)
                    .foregroundColor(HabitTheme.secondaryText)
                    .opacity(0.8)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(HabitTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: Color.yellow.opacity(0.4),
                        radius: 20,
                        x: 0,
                        y: 8
                    )
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            // Entry animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.2)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Bounce animation for emoji
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                bounceOffset = -5
            }
            
            // Rotation animation for emoji
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                rotationAngle = 10
            }
        }
    }
}

// MARK: - Micro Affirmation View
struct MicroAffirmationView: View {
    let message: String
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                // Heart icon
                Image(systemName: "heart.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.pink)
                    .scaleEffect(scale)
                
                // Message
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(HabitTheme.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(HabitTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.pink.opacity(0.3), lineWidth: 1.5)
                    )
                    .shadow(
                        color: Color.pink.opacity(0.2),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
            .offset(y: offset)
            .opacity(opacity)
            .scaleEffect(scale)
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .onAppear {
            // Entry animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)) {
                offset = -20
                opacity = 1.0
                scale = 1.0
            }
            
            // Heart pulse animation
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var habitManager: HabitManager
    @StateObject private var notificationManager = NotificationManager.shared
    
    // Onboarding and navigation states
    @State private var showOnboarding = false
    @State private var showingCustomLadderView = false
    @State private var showingLadderSelection = false
    @State private var showingCuratedLadders = false
    @State private var showingResetAlert = false
    @State private var showingCustomLadderLimitAlert = false
    @State private var customLadderLimitMessage = ""
    @State private var showingProfileSelection = false
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    // End-of-day recap state
    @State private var showingEndOfDayRecap = false
    
    // Check if we should show the end-of-day recap
    private var shouldShowEndOfDayRecap: Bool {
        guard storeManager.isPremiumUser else { return false }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Check if it's after 7 PM
        let hour = calendar.component(.hour, from: now)
        guard hour >= 19 else { return false } // 19:00 = 7 PM
        
        // Check if we've already shown the recap today
        let lastShownDateKey = "EndOfDayRecapLastShown"
        if let lastShownDate = UserDefaults.standard.object(forKey: lastShownDateKey) as? Date,
           calendar.isDateInToday(lastShownDate) {
            return false
        }
        
        return true
    }
    
    var body: some View {
        Group {
            if !habitManager.isDataLoaded {
                // Show loading state while data is being loaded
                LoadingView()
            } else if shouldShowOnboarding {
                OnboardingView {
                    completeOnboarding()
                }
                .environmentObject(storeManager)
                .environmentObject(habitManager)
            } else {
                mainAppContent
            }
        }
        .task {
            // Use task for async initialization
            await initializeApp()
        }
        .onAppear {
            // Lightweight onAppear for immediate UI updates only
            if shouldShowOnboarding {
                showOnboarding = true
            }
        }
        .onChange(of: storeManager.isPremiumUser) { oldValue, newValue in
            // Update notifications when premium status changes
            notificationManager.handlePremiumStatusChange(isPremium: newValue, habits: habitManager.habits)
        }
    }
    
    // MARK: - Async Initialization
    @MainActor
    private func initializeApp() async {
        // Debug: Print current state when app appears
        print("📱 ContentView: App appeared, printing current state:")
        
        // Delay state printing to allow data loading to complete
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        habitManager.printCurrentState()
        
        // Set up notification integration
        habitManager.setPremiumStatusCallback { [weak storeManager] in
            return storeManager?.isPremiumUser ?? false
        }
        
        // Initial notification scheduling
        notificationManager.scheduleNotifications(for: habitManager.habits, isPremiumUser: storeManager.isPremiumUser)
        
        // Check for end-of-day recap after app settles
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        if shouldShowEndOfDayRecap {
            showingEndOfDayRecap = true
            // Mark recap as shown for today
            UserDefaults.standard.set(Date(), forKey: "EndOfDayRecapLastShown")
        }
    }
    
    private var mainAppContent: some View {
        TabView {
            // Main Habits Tab
            habitTrackingView
                .tabItem {
                    Image(systemName: "checklist")
                    Text("Habits")
                }
            
            // Settings Tab
            SettingsView(
                storeManager: storeManager,
                habitManager: habitManager
            )
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
        .accentColor(HabitTheme.primary)
        .onAppear {
            // Apply modern tab bar styling
            setupModernTabBarAppearance()
        }
    }
    
    // MARK: - Tab Bar Styling
    private func setupModernTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Background styling with blur effect
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
        appearance.shadowImage = UIImage()
        appearance.shadowColor = UIColor.clear
        
        // Get primary color from HabitTheme
        let primaryUIColor = UIColor(HabitTheme.primary)
        
        // Normal item appearance with better spacing
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)
        
        // Selected item appearance with app's primary color
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: primaryUIColor,
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = primaryUIColor
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)
        
        // Apply to all tab bar instances
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure modern spacing and positioning
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBarController = window.rootViewController as? UITabBarController ?? 
                                     window.rootViewController?.children.compactMap({ $0 as? UITabBarController }).first {
                
                let tabBar = tabBarController.tabBar
                
                // Add subtle shadow with better parameters
                tabBar.layer.shadowColor = UIColor.black.cgColor
                tabBar.layer.shadowOpacity = 0.06
                tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
                tabBar.layer.shadowRadius = 12
                tabBar.layer.masksToBounds = false
                
                // Improve item positioning and spacing
                tabBar.itemSpacing = 20
                tabBar.itemPositioning = .centered
                
                // Add subtle top border for definition
                let borderLayer = CALayer()
                borderLayer.backgroundColor = UIColor.separator.withAlphaComponent(0.2).cgColor
                borderLayer.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.33)
                borderLayer.name = "modernTopBorder" // Add identifier to avoid duplicates
                
                // Remove existing border if present
                if let existingBorder = tabBar.layer.sublayers?.first(where: { $0.name == "modernTopBorder" }) {
                    existingBorder.removeFromSuperlayer()
                }
                
                tabBar.layer.addSublayer(borderLayer)
                
                // Ensure proper edge padding for modern look
                // iOS 17+ has better default styling
                tabBar.scrollEdgeAppearance?.shadowColor = .clear
                tabBar.standardAppearance.shadowColor = .clear
            }
        }
    }
    
    private var habitTrackingView: some View {
        NavigationStack {
            ZStack {
                // Background
                HabitTheme.unlockedBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with ladder selector
                    VStack(spacing: 16) {
                        // App title
                        Text("HabitLadder")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(HabitTheme.primaryText)
                        
                        // Current Ladder Display with Switch Option
                        Button(action: {
                            showingLadderSelection = true
                        }) {
                            HStack(spacing: 12) {
                                // Current ladder icon
                                Text(getCurrentLadderEmoji())
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(getCurrentLadderName())
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(HabitTheme.primaryText)
                                    
                                    HStack(spacing: 4) {
                                        Text("\(habitManager.habits.count) habits")
                                            .font(.caption)
                                            .foregroundColor(HabitTheme.secondaryText)
                                        
                                        if habitManager.activeCustomLadder != nil {
                                            Text("• Custom")
                                                .font(.caption)
                                                .foregroundColor(HabitTheme.accent)
                                        } else if habitManager.defaultLadder != nil {
                                            Text("• Default")
                                                .font(.caption)
                                                .foregroundColor(HabitTheme.accent)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                // Switch indicator
                                HStack(spacing: 4) {
                                    Text("Switch")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(HabitTheme.accent)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(HabitTheme.accent)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(HabitTheme.cardBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(HabitTheme.accent.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        
                        // Quick Actions
                        HStack(spacing: 12) {
                            // Add Custom Ladder
                            Button(action: {
                                if habitManager.canAddCustomLadder(isPremium: storeManager.isPremiumUser) {
                                    showingCustomLadderView = true
                                } else {
                                    customLadderLimitMessage = habitManager.getCustomLadderLimitMessage()
                                    showingCustomLadderLimitAlert = true
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.caption)
                                    Text("New Ladder")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(habitManager.canAddCustomLadder(isPremium: storeManager.isPremiumUser) ? HabitTheme.accent : HabitTheme.inactive)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(HabitTheme.cardBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(habitManager.canAddCustomLadder(isPremium: storeManager.isPremiumUser) ? HabitTheme.accent.opacity(0.3) : HabitTheme.inactive.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .disabled(!habitManager.canAddCustomLadder(isPremium: storeManager.isPremiumUser))
                            
                            // Browse Curated Ladders
                            Button(action: {
                                showingCuratedLadders = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "star")
                                        .font(.caption)
                                    Text("Browse")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(HabitTheme.accent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(HabitTheme.cardBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(HabitTheme.accent.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top)
                    
                    // Habits List and Reset Button in ScrollView
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Show loading or empty state if no habits
                            if habitManager.habits.isEmpty {
                                EmptyHabitsView()
                                    .padding()
                            } else {
                                ForEach(Array(habitManager.habits.enumerated()), id: \.element.id) { index, habit in
                                    HabitRow(
                                        habit: habit,
                                        index: index,
                                        onToggle: { 
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                habitManager.toggleHabitCompletion(for: habit.id)
                                            }
                                        },
                                        habits: habitManager.habits,
                                        isNewlyUnlocked: habitManager.unlockedHabitForAnimation == habit.id
                                    )
                                    .id(habit.id) // Stable identity for better performance
                                }
                            }
                        }
                        .padding()
                        
                        // Reset Button inside ScrollView
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Reset All Habits")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.red, Color.red.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .scaleEffect(showingResetAlert ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: showingResetAlert)
                        
                        // Bottom spacing for safe area
                        Color.clear.frame(height: 20)
                    }
                }
                
                // Confetti overlay
                if habitManager.showConfetti {
                    ConfettiView(duration: 3.0)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
                
                // Enhanced sparkle animation overlay
                if habitManager.showSparkleAnimation {
                    SparkleAnimation()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                        .zIndex(0.5)
                }
                
                // Unlock toast notification
                if habitManager.showUnlockToast {
                    VStack {
                        UnlockToast(message: habitManager.unlockToastMessage)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        Spacer()
                    }
                    .allowsHitTesting(false)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(3)
                }
                
                // Celebration popup overlay
                if habitManager.showCelebrationPopup {
                    CelebrationPopup(
                        message: habitManager.celebrationMessage,
                        isShowing: .constant(habitManager.showCelebrationPopup)
                    )
                    .allowsHitTesting(true)
                    .transition(.opacity)
                    .zIndex(1)
                    .onTapGesture {
                        // Allow dismissing by tapping
                        withAnimation(.easeOut(duration: 0.3)) {
                            habitManager.showCelebrationPopup = false
                        }
                    }
                }
                
                // Micro-affirmation overlay
                if habitManager.showMicroAffirmation {
                    MicroAffirmationView(message: habitManager.microAffirmationMessage)
                        .allowsHitTesting(false)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        .zIndex(2)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCustomLadderView) {
            CustomHabitLadderView(habitManager: habitManager)
                .environmentObject(storeManager)
        }
        .sheet(isPresented: $showingLadderSelection) {
            LadderSelectionView(habitManager: habitManager)
        }
        .sheet(isPresented: $showingCuratedLadders) {
            CuratedLaddersView()
                .environmentObject(storeManager)
                .environmentObject(habitManager)
        }
        .sheet(isPresented: $showingEndOfDayRecap) {
            EndOfDayRecapView(habits: habitManager.habits)
        }
        .sheet(isPresented: $showingProfileSelection) {
            HabitProfileSelectionView(
                onProfileSelected: { profile in
                    habitManager.activateHabitProfile(profile)
                    showingProfileSelection = false
                },
                onDismiss: {
                    showingProfileSelection = false
                }
            )
        }
        .alert("Reset All Habits", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    habitManager.resetAllHabits()
                }
            }
        } message: {
            Text("This will reset all habit progress. Are you sure?")
        }
        .alert("Upgrade to Premium", isPresented: $showingCustomLadderLimitAlert) {
            Button("Upgrade") {
                // TODO: Show premium paywall
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(customLadderLimitMessage)
        }
                        .onChange(of: habitManager.lastUnlockedHabitId) { oldValue, newValue in
            // Clear the newly unlocked indicator after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                habitManager.lastUnlockedHabitId = nil
            }
        }

    }
    
    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
            showOnboarding = false
        }
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(true, forKey: "hasSelectedProfile")
        UserDefaults.standard.synchronize() // Force immediate save
        
        // Ensure the habit manager data is also saved
        habitManager.saveHabits()
        habitManager.saveUsageFlags()
        
        print("✅ ContentView: Onboarding completed and data saved")
    }

    // Computed property to determine if onboarding should be shown
    private var shouldShowOnboarding: Bool {
        // Always show onboarding if it hasn't been completed
        if !hasCompletedOnboarding {
            return true
        }
        
        // Wait for data to be loaded before making decisions
        guard habitManager.isDataLoaded else {
            return false // Show loading state, not onboarding
        }
        
        // If onboarding was completed but there's no data loaded, show onboarding again
        // This handles cases where profile selection was completed but data didn't persist
        if habitManager.defaultLadder == nil && habitManager.habits.isEmpty && habitManager.activeCustomLadder == nil {
            print("⚠️ ContentView: Onboarding was completed but no profile data found, showing onboarding again")
            return true
        }
        
        // Show onboarding if explicitly requested
        return showOnboarding
    }
    
    // MARK: - Helper Functions for Ladder Selector
    private func getCurrentLadderEmoji() -> String {
        if let activeCustomLadder = habitManager.activeCustomLadder {
            return activeCustomLadder.emoji ?? "🪜"
        } else if let defaultLadder = habitManager.defaultLadder {
            return defaultLadder.emoji ?? "👤"
        } else {
            return "👤"
        }
    }
    
    private func getCurrentLadderName() -> String {
        if let activeCustomLadder = habitManager.activeCustomLadder {
            return activeCustomLadder.name
        } else if let defaultLadder = habitManager.defaultLadder {
            return defaultLadder.name
        } else {
            return "Choose Profile"
        }
    }
    
    // MARK: - End-of-day recap logic
}

// MARK: - Empty Habits View
struct EmptyHabitsView: View {
    @EnvironmentObject var habitManager: HabitManager
    @State private var isAnimating = false
    @State private var showProfileSelection = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            VStack(spacing: 16) {
                Image(systemName: "list.clipboard")
                    .font(.system(size: 60))
                    .foregroundColor(HabitTheme.secondaryText)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                Text("No Habits Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(HabitTheme.primaryText)
            }
            
            // Message
            VStack(spacing: 12) {
                Text("Your habit journey is just beginning!")
                    .font(.body)
                    .foregroundColor(HabitTheme.secondaryText)
                    .multilineTextAlignment(.center)
                
                Text("Choose a starter profile to get your first set of habits.")
                    .font(.subheadline)
                    .foregroundColor(HabitTheme.tertiaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            
            // Action button
            Button(action: {
                showProfileSelection = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.headline)
                    Text("Choose Profile")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [HabitTheme.primary, HabitTheme.primary.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: HabitTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .onAppear {
            isAnimating = true
        }
        .sheet(isPresented: $showProfileSelection) {
            HabitProfileSelectionView(
                onProfileSelected: { profile in
                    habitManager.activateHabitProfile(profile)
                    showProfileSelection = false
                },
                onDismiss: {
                    showProfileSelection = false
                }
            )
        }
    }
}

// MARK: - Reusable Footer Component
struct AppFooter: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Text("Built by")
                    .font(.caption)
                    .foregroundColor(HabitTheme.secondaryText)
                
                Button(action: {
                    if let url = URL(string: "https://blackcubesolutions.com") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image("BCSLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
        .padding(.top, 16)
    }
}

// MARK: - Ladder Selection View
struct LadderSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var habitManager: HabitManager
    @State private var showingDeleteAlert = false
    @State private var ladderToDelete: CustomHabitLadder?
    @State private var showingRenameAlert = false
    @State private var ladderToRename: CustomHabitLadder?
    @State private var newLadderName = ""
    @State private var isSelectionMode = false
    @State private var selectedLadders: Set<UUID> = []
    @State private var showingDeleteSelectedAlert = false
    @State private var showingProfileSelection = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Modern background
                HabitTheme.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        headerView
                        
                        VStack(spacing: 12) {
                            defaultLadderCard
                            customLaddersSection
                        }
                        .padding(.horizontal, 20)
                        
                        // Footer at bottom of scrollable content
                        AppFooter()
                        
                        // Bottom spacing for safe area
                        Color.clear.frame(height: 20)
                    }
                }
            }
            .navigationTitle("🪜 Select Ladder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingToolbarButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingToolbarButton
                }
            }
        }
        .alert("Delete Ladder", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let ladder = ladderToDelete {
                    habitManager.deleteCustomLadder(ladder)
                }
            }
        } message: {
            Text("Are you sure you want to delete this custom ladder?")
        }
        .alert("Rename Ladder", isPresented: $showingRenameAlert) {
            TextField("Ladder Name", text: $newLadderName)
                .textInputAutocapitalization(.words)
            Button("Cancel", role: .cancel) {
                newLadderName = ""
                ladderToRename = nil
            }
            Button("Save") {
                if let ladder = ladderToRename,
                   !newLadderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    habitManager.renameCustomLadder(ladder, to: newLadderName.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                newLadderName = ""
                ladderToRename = nil
            }
            .disabled(newLadderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } message: {
            Text("Enter a new name for your custom ladder")
        }
        .alert("Delete Selected Ladders", isPresented: $showingDeleteSelectedAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSelectedLadders()
            }
        } message: {
            Text("Are you sure you want to delete \(selectedLadders.count) selected ladder\(selectedLadders.count == 1 ? "" : "s")?")
        }
        .sheet(isPresented: $showingProfileSelection) {
            HabitProfileSelectionView(
                onProfileSelected: { profile in
                    habitManager.activateHabitProfile(profile)
                    showingProfileSelection = false
                    dismiss() // Also dismiss the ladder selection view
                },
                onDismiss: {
                    showingProfileSelection = false
                }
            )
        }
        .onChange(of: habitManager.customLadders) { oldValue, newValue in
            // Exit selection mode if in selection mode and ladders list changes
            if isSelectionMode {
                isSelectionMode = false
                selectedLadders.removeAll()
            }
        }
    }
    
    // MARK: - Computed Views
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("🪜")
                .font(.system(size: 60))
            Text("Choose Your Ladder")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(HabitTheme.primaryText)
            Text("Switch between different habit ladders")
                .font(.subheadline)
                .foregroundColor(HabitTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    private var defaultLadderCard: some View {
        Button(action: {
            if habitManager.defaultLadder != nil {
                withAnimation(.easeInOut(duration: 0.3)) {
                    habitManager.switchToDefaultLadder()
                }
                dismiss()
            } else {
                // No default profile selected, show profile selection
                showingProfileSelection = true
            }
        }) {
            HStack(spacing: 16) {
                // Ladder icon
                VStack {
                    Text(habitManager.defaultLadder?.emoji ?? "👤")
                        .font(.title)
                    Text("Default")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(HabitTheme.secondaryText)
                }
                .frame(width: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habitManager.defaultLadder?.name ?? "Choose Profile")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(habitManager.defaultLadder != nil ? HabitTheme.primaryText : HabitTheme.secondaryText)
                    
                    if let defaultLadder = habitManager.defaultLadder {
                        Text("\(defaultLadder.habits.count) habits")
                            .font(.subheadline)
                            .foregroundColor(HabitTheme.secondaryText)
                    } else {
                        Text("Tap to select a profile")
                            .font(.subheadline)
                            .foregroundColor(HabitTheme.tertiaryText)
                    }
                }
                
                Spacer()
                
                if habitManager.defaultLadder != nil {
                    if habitManager.activeCustomLadder == nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(HabitTheme.inactive)
                            .font(.title2)
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(HabitTheme.inactive)
                        .font(.headline)
                }
            }
            .padding(20)
            .background(defaultLadderBackground)
        }
        .buttonStyle(.plain)
    }
    
    private var defaultLadderBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(HabitTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        getDefaultLadderBorderColor(),
                        lineWidth: getDefaultLadderBorderWidth()
                    )
            )
            .shadow(
                color: getDefaultLadderShadowColor(),
                radius: getDefaultLadderShadowRadius(),
                x: 0,
                y: 4
            )
    }
    
    private func getDefaultLadderBorderColor() -> Color {
        if habitManager.defaultLadder == nil {
            return HabitTheme.inactive.opacity(0.4)
        } else if habitManager.activeCustomLadder == nil {
            return Color.blue.opacity(0.4)
        } else {
            return HabitTheme.inactive.opacity(0.3)
        }
    }
    
    private func getDefaultLadderBorderWidth() -> CGFloat {
        if habitManager.defaultLadder == nil {
            return 1.5
        } else if habitManager.activeCustomLadder == nil {
            return 2
        } else {
            return 1
        }
    }
    
    private func getDefaultLadderShadowColor() -> Color {
        if habitManager.defaultLadder == nil {
            return .black.opacity(0.05)
        } else if habitManager.activeCustomLadder == nil {
            return Color.blue.opacity(0.15)
        } else {
            return .black.opacity(0.05)
        }
    }
    
    private func getDefaultLadderShadowRadius() -> CGFloat {
        if habitManager.defaultLadder == nil {
            return 4
        } else if habitManager.activeCustomLadder == nil {
            return 8
        } else {
            return 4
        }
    }
    
    private var customLaddersSection: some View {
        ForEach(habitManager.customLadders) { ladder in
            customLadderCard(ladder: ladder)
        }
    }
    
    @ViewBuilder
    private func customLadderCard(ladder: CustomHabitLadder) -> some View {
        Button(action: {
            if isSelectionMode {
                if selectedLadders.contains(ladder.id) {
                    selectedLadders.remove(ladder.id)
                } else {
                    selectedLadders.insert(ladder.id)
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    habitManager.activateCustomLadder(ladder)
                }
                dismiss()
            }
        }) {
            HStack(spacing: 16) {
                // Selection indicator in selection mode
                if isSelectionMode {
                    Image(systemName: selectedLadders.contains(ladder.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedLadders.contains(ladder.id) ? .blue : HabitTheme.inactive)
                        .font(.title2)
                        .animation(.easeInOut(duration: 0.2), value: selectedLadders.contains(ladder.id))
                }
                
                // Custom ladder icon
                VStack {
                    Text(ladder.emoji ?? "🪜")
                        .font(.title)
                    Text("Custom")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(HabitTheme.secondaryText)
                }
                .frame(width: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(ladder.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(HabitTheme.primaryText)
                    Text("\(ladder.habits.count) habits")
                        .font(.subheadline)
                        .foregroundColor(HabitTheme.secondaryText)
                }
                
                Spacer()
                
                // Active indicator (only shown when not in selection mode)
                if !isSelectionMode {
                    if habitManager.activeCustomLadder?.id == ladder.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(HabitTheme.inactive)
                            .font(.title2)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if !isSelectionMode {
                Button {
                    ladderToRename = ladder
                    newLadderName = ladder.name
                    showingRenameAlert = true
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
                .tint(.blue)
                
                Button(role: .destructive) {
                    ladderToDelete = ladder
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .contextMenu {
            if !isSelectionMode {
                Button {
                    ladderToRename = ladder
                    newLadderName = ladder.name
                    showingRenameAlert = true
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    ladderToDelete = ladder
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .background(customLadderBackground(ladder: ladder))
    }
    
    @ViewBuilder
    private func customLadderBackground(ladder: CustomHabitLadder) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(getCardBackgroundColor(ladder: ladder))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        getCardBorderColor(ladder: ladder), 
                        lineWidth: getCardBorderWidth(ladder: ladder)
                    )
            )
            .shadow(
                color: getCardShadowColor(ladder: ladder),
                radius: getCardShadowRadius(ladder: ladder),
                x: 0,
                y: 4
            )
    }
    
    @ViewBuilder
    private var leadingToolbarButton: some View {
        if !habitManager.customLadders.isEmpty {
            if isSelectionMode {
                Button("Cancel") {
                    isSelectionMode = false
                    selectedLadders.removeAll()
                }
            } else {
                Button("Select") {
                    isSelectionMode = true
                }
            }
        }
    }
    
    @ViewBuilder
    private var trailingToolbarButton: some View {
        if isSelectionMode {
            Button("Delete") {
                showingDeleteSelectedAlert = true
            }
            .disabled(selectedLadders.isEmpty)
            .foregroundColor(selectedLadders.isEmpty ? .gray : .red)
            .fontWeight(.semibold)
        } else {
            Button("Done") {
                dismiss()
            }
            .fontWeight(.semibold)
        }
    }
    
    // MARK: - Helper Functions
    private func getCardBackgroundColor(ladder: CustomHabitLadder) -> Color {
        if isSelectionMode && selectedLadders.contains(ladder.id) {
            return Color.blue.opacity(0.1)
        } else if habitManager.activeCustomLadder?.id == ladder.id {
            return HabitTheme.cardBackground
        } else {
            return HabitTheme.cardBackground
        }
    }
    
    private func getCardBorderColor(ladder: CustomHabitLadder) -> Color {
        if isSelectionMode && selectedLadders.contains(ladder.id) {
            return Color.blue.opacity(0.5)
        } else if habitManager.activeCustomLadder?.id == ladder.id {
            return Color.blue.opacity(0.4)
        } else {
            return HabitTheme.inactive.opacity(0.3)
        }
    }
    
    private func getCardBorderWidth(ladder: CustomHabitLadder) -> CGFloat {
        if isSelectionMode && selectedLadders.contains(ladder.id) {
            return 2
        } else if habitManager.activeCustomLadder?.id == ladder.id {
            return 2
        } else {
            return 1
        }
    }
    
    private func getCardShadowColor(ladder: CustomHabitLadder) -> Color {
        if isSelectionMode && selectedLadders.contains(ladder.id) {
            return Color.blue.opacity(0.2)
        } else if habitManager.activeCustomLadder?.id == ladder.id {
            return Color.blue.opacity(0.15)
        } else {
            return .black.opacity(0.05)
        }
    }
    
    private func getCardShadowRadius(ladder: CustomHabitLadder) -> CGFloat {
        if isSelectionMode && selectedLadders.contains(ladder.id) {
            return 8
        } else if habitManager.activeCustomLadder?.id == ladder.id {
            return 8
        } else {
            return 4
        }
    }
    
    private func deleteSelectedLadders() {
        let laddersToDelete = habitManager.customLadders.filter { selectedLadders.contains($0.id) }
        
        for ladder in laddersToDelete {
            habitManager.deleteCustomLadder(ladder)
        }
        
        // Check if all custom ladders were deleted
        if habitManager.customLadders.isEmpty {
            // Switch back to default ladder and show profile selection
            habitManager.switchToDefaultLadder()
            showingProfileSelection = true
        }
        
        // Exit selection mode
        isSelectionMode = false
        selectedLadders.removeAll()
    }
}

// MARK: - Habit Row View
struct HabitRow: View {
    let habit: Habit
    let index: Int
    let onToggle: () -> Void
    let habits: [Habit]  // Pass the full habits array to access previous habit info
    let isNewlyUnlocked: Bool
    
    @State private var isPressed = false
    @State private var completionScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0
    @State private var unlockScale: CGFloat = 1.0
    @State private var showDescription = false
    
    private var cardBackgroundColor: AnyView {
        if habit.isUnlocked {
            if habit.isCompletedToday {
                return AnyView(
                    ZStack {
                        // Glass morphism base
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(UIColor.systemGreen).opacity(0.12),
                                        Color(UIColor.systemMint).opacity(0.08),
                                        Color(UIColor.systemTeal).opacity(0.06)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(.ultraThinMaterial)
                            )
                        
                        // Shimmer overlay for completed habits
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.1),
                                        Color.clear,
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                )
            } else {
                return AnyView(
                    ZStack {
                        // Glass morphism base
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        HabitTheme.cardBackground.opacity(0.9),
                                        HabitTheme.cardBackground.opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(.regularMaterial)
                            )
                        
                        // Subtle highlight
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.08),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                )
            }
        } else {
            return AnyView(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    HabitTheme.lockedBackground.opacity(0.6),
                                    HabitTheme.lockedBackground.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.thickMaterial)
                        )
                }
            )
        }
    }
    
    private var cardBorderColor: Color {
        if habit.isUnlocked {
            return habit.isCompletedToday ? 
                HabitTheme.completedBorder : 
                HabitTheme.unlockedBorder
        } else {
            return HabitTheme.lockedBorder
        }
    }
    
    private var shadowColor: Color {
        if habit.isUnlocked {
            return habit.isCompletedToday ? 
                Color.green.opacity(0.2) : 
                Color.blue.opacity(0.15)
        } else {
            return Color.black.opacity(0.05)
        }
    }
    
    private var shadowRadius: CGFloat {
        habit.isUnlocked ? (habit.isCompletedToday ? 12 : 8) : 4
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header section with title and lock icon
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(habit.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(habit.isUnlocked ? HabitTheme.primaryText : HabitTheme.secondaryText)
                        .multilineTextAlignment(.leading)
                        .animation(.easeInOut(duration: 0.3), value: habit.isUnlocked)
                    
                    // Description (conditional display)
                    if showDescription {
                        Text(habit.description)
                            .font(.subheadline)
                            .foregroundColor(HabitTheme.secondaryText)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                
                Spacer()
                
                // Unlock animation or lock icon
                if habit.isUnlocked {
                    if isNewlyUnlocked {
                        ZStack {
                            // Glowing background
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.yellow.opacity(glowOpacity),
                                            Color.orange.opacity(glowOpacity * 0.6),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 5,
                                        endRadius: 25
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            // Main unlock icon
                            Image(systemName: "lock.open.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                                .scaleEffect(unlockScale)
                                .shadow(color: .yellow.opacity(0.6), radius: 8, x: 0, y: 2)
                            
                            // Floating sparkles
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .offset(x: 15, y: -10)
                                .scaleEffect(0.8)
                                .opacity(glowOpacity)
                                .rotationEffect(.degrees(45))
                            
                            Image(systemName: "sparkles")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                                .offset(x: -12, y: 8)
                                .scaleEffect(0.6)
                                .opacity(glowOpacity * 0.8)
                                .rotationEffect(.degrees(-30))
                        }
                        .onAppear {
                            // Pulsing glow animation
                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                glowOpacity = 0.8
                            }
                            
                            // Scale bounce animation
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.4)) {
                                unlockScale = 1.3
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                                    unlockScale = 1.0
                                }
                            }
                        }
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                            .scaleEffect(0.9)
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundColor(HabitTheme.tertiaryText)
                        .scaleEffect(0.9)
                        .animation(.easeInOut(duration: 0.2), value: habit.isUnlocked)
                }
            }
            
            // Progress indicator section
            VStack(spacing: 12) {
                // Progress bar
                HStack(spacing: 12) {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(HabitTheme.secondaryText)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    // Simple progress bar
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(HabitTheme.tertiaryText.opacity(0.2))
                            .frame(height: 8)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                habit.hasThreeConsecutiveCompletions ? 
                                LinearGradient(colors: [HabitTheme.gold, .yellow], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [.green, .green], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: max(0, CGFloat(habit.isUnlocked ? habit.consecutiveStreakCount : 0) / 3.0 * 60), height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: habit.consecutiveStreakCount)
                    }
                    .frame(width: 60)
                    
                    Text("\(habit.isUnlocked ? habit.consecutiveStreakCount : 0)/3")
                        .font(.caption)
                        .foregroundColor(habit.hasThreeConsecutiveCompletions ? .green : (habit.consecutiveStreakCount > 0 ? .blue : HabitTheme.secondaryText))
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .scaleEffect(habit.hasThreeConsecutiveCompletions ? 1.1 : (habit.consecutiveStreakCount > 0 ? 1.05 : 1.0))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: habit.consecutiveStreakCount)
                }
                
                // Status and unlock information
                HStack {
                    if habit.isUnlocked {
                        if habit.isCompletedToday {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                    .scaleEffect(completionScale)
                                Text("Completed today")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .fontWeight(.medium)
                            }
                            .transition(.scale.combined(with: .opacity))
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "circle")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                Text("Ready to complete")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .fontWeight(.medium)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        Spacer()
                        
                        Text("Total: \(habit.totalCompletionDays)")
                            .font(.caption)
                            .foregroundColor(HabitTheme.secondaryText)
                            .monospacedDigit()
                    } else {
                        VStack(alignment: .leading, spacing: 2) {
                            if index > 0 {
                                let previousHabit = habits[index - 1]
                                Text("Complete '\(previousHabit.name)' 3 days in a row")
                                    .font(.caption)
                                    .foregroundColor(HabitTheme.secondaryText)
                                    .italic()
                                Text("(\(previousHabit.consecutiveStreakCount)/3 days completed)")
                                    .font(.caption)
                                    .foregroundColor(HabitTheme.tertiaryText)
                                    .italic()
                            } else {
                                Text("Complete previous habit to unlock")
                                    .font(.caption)
                                    .foregroundColor(HabitTheme.secondaryText)
                                    .italic()
                            }
                        }
                        Spacer()
                    }
                }
            }
            
            // Checkbox section
            HStack {
                Spacer()
                
                if habit.isUnlocked {
                    Button(action: {
                        if !habit.isCompletedToday {
                            // Trigger completion animation
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                completionScale = 1.3
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    completionScale = 1.0
                                }
                            }
                        }
                        onToggle()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundColor(habit.isCompletedToday ? .green : .blue)
                                .scaleEffect(isPressed ? 0.9 : 1.0)
                            
                            Text(habit.isCompletedToday ? "Completed" : "Mark Complete")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(habit.isCompletedToday ? .green : .blue)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(
                            ZStack {
                                // Glass morphism base
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(
                                        LinearGradient(
                                            colors: habit.isCompletedToday ? [
                                                Color(UIColor.systemGreen).opacity(0.15),
                                                Color(UIColor.systemMint).opacity(0.1)
                                            ] : [
                                                Color(UIColor.systemBlue).opacity(0.15),
                                                Color(UIColor.systemIndigo).opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: 28)
                                            .fill(.ultraThinMaterial)
                                    )
                                
                                // Highlight overlay
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.15),
                                                Color.clear
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(
                                        LinearGradient(
                                            colors: habit.isCompletedToday ? [
                                                Color(UIColor.systemGreen).opacity(0.5),
                                                Color(UIColor.systemMint).opacity(0.3)
                                            ] : [
                                                Color(UIColor.systemBlue).opacity(0.5),
                                                Color(UIColor.systemIndigo).opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(
                                color: habit.isCompletedToday ? 
                                    Color.green.opacity(0.25) : 
                                    Color.blue.opacity(0.2),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                            .shadow(
                                color: habit.isCompletedToday ? 
                                    Color.green.opacity(0.1) : 
                                    Color.blue.opacity(0.08),
                                radius: 16,
                                x: 0,
                                y: 0
                            )
                        )
                    }
                    .disabled(habit.isCompletedToday)
                    .scaleEffect(habit.isCompletedToday ? 0.95 : (isPressed ? 0.95 : 1.0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: habit.isCompletedToday)
                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = pressing
                        }
                    }, perform: {})
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.circle")
                            .font(.title2)
                            .foregroundColor(HabitTheme.tertiaryText)
                        
                        Text("Locked")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(HabitTheme.tertiaryText)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            HabitTheme.tertiaryText.opacity(0.08),
                                            HabitTheme.tertiaryText.opacity(0.04)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(.thickMaterial)
                                )
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(
                                    HabitTheme.tertiaryText.opacity(0.25),
                                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                                )
                        )
                        .shadow(
                            color: Color.black.opacity(0.08),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                    )
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                // Base card with enhanced styling
                cardBackgroundColor
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: habit.isUnlocked ? [
                                        habit.isCompletedToday ? 
                                            Color(UIColor.systemGreen).opacity(0.4) : 
                                            HabitTheme.primary.opacity(0.3),
                                        habit.isCompletedToday ? 
                                            Color(UIColor.systemMint).opacity(0.3) : 
                                            HabitTheme.accent.opacity(0.2)
                                    ] : [
                                        HabitTheme.inactive.opacity(0.2),
                                        HabitTheme.inactive.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: habit.isUnlocked ? 1.5 : 1
                            )
                    )
                    .shadow(
                        color: shadowColor,
                        radius: shadowRadius,
                        x: 0,
                        y: habit.isUnlocked ? 8 : 3
                    )
                    .shadow(
                        color: habit.isUnlocked ? 
                            (habit.isCompletedToday ? Color.green.opacity(0.1) : Color.blue.opacity(0.08)) : 
                            Color.clear,
                        radius: habit.isUnlocked ? 20 : 0,
                        x: 0,
                        y: 0
                    )
                
                // Enhanced glow for newly unlocked habits
                if isNewlyUnlocked {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.yellow.opacity(glowOpacity * 0.9),
                                    Color.orange.opacity(glowOpacity * 0.6),
                                    Color.pink.opacity(glowOpacity * 0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .shadow(
                            color: Color.yellow.opacity(glowOpacity * 0.7),
                            radius: 20,
                            x: 0,
                            y: 0
                        )
                        .shadow(
                            color: Color.orange.opacity(glowOpacity * 0.5),
                            radius: 35,
                            x: 0,
                            y: 0
                        )
                }
                
                // Locked state dashed border overlay
                if !habit.isUnlocked {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            HabitTheme.inactive.opacity(0.4),
                            style: StrokeStyle(lineWidth: 1.5, dash: [8, 6])
                        )
                }
            }
        )
        .scaleEffect(habit.isUnlocked ? (isNewlyUnlocked ? 1.02 : 1.0) : 0.96)
        .opacity(habit.isUnlocked ? 1.0 : 0.7)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: habit.isUnlocked)
        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: isNewlyUnlocked)
        .onTapGesture {
            // Toggle description visibility on tap
            withAnimation(.easeInOut(duration: 0.3)) {
                showDescription.toggle()
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            // Also toggle description on long press
            withAnimation(.easeInOut(duration: 0.3)) {
                showDescription.toggle()
            }
        }
    }
}

// MARK: - Custom Habit Ladder View
struct CustomHabitLadderView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var habitManager: HabitManager
    @EnvironmentObject var storeManager: StoreManager
    
    @State private var ladderName = ""
    @State private var selectedEmoji = "🪜"
    @State private var habits: [NewHabit] = [NewHabit()]
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingEmojiPicker = false
    
    private let availableEmojis = ["🪜", "🎯", "🚀", "💪", "⭐", "🔥", "🌟", "💎", "🏆", "🎖️", "🎨", "📚", "🧘", "🏃", "💡", "🌅", "🌱", "⚡", "🎵", "🔑", "🎭", "🧩", "🎳", "🎪", "🎨", "🎺", "🎸", "🎮", "🎲"]
    
    private struct NewHabit: Identifiable {
        let id = UUID()
        var name = ""
        var description = ""
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Modern background
                HabitTheme.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ladder Details")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(HabitTheme.primaryText)
                            
                            TextField("Enter ladder name", text: $ladderName)
                                .textFieldStyle(ModernLargeTextFieldStyle())
                            
                            // Emoji Selection (Premium Feature)
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Ladder Icon")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(HabitTheme.primaryText)
                                    
                                    if !storeManager.isPremiumUser {
                                        Image(systemName: "crown.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                    }
                                }
                                
                                if storeManager.isPremiumUser {
                                    Button(action: { showingEmojiPicker = true }) {
                                        HStack(spacing: 12) {
                                            Text(selectedEmoji)
                                                .font(.title)
                                            Text("Tap to change")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.blue)
                                                .font(.caption)
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(HabitTheme.cardBackground)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(.blue.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    HStack(spacing: 12) {
                                        Text("🪜")
                                            .font(.title)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Premium Feature")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(HabitTheme.primaryText)
                                            Text("Upgrade to choose custom icons")
                                                .font(.caption)
                                                .foregroundColor(HabitTheme.secondaryText)
                                        }
                                        Spacer()
                                        Button("Upgrade") {
                                            // TODO: Show premium upgrade view
                                        }
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(.blue)
                                        .cornerRadius(8)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(HabitTheme.cardBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Habits Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Habits (in order of difficulty)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(HabitTheme.primaryText)
                                .padding(.horizontal, 20)
                            
                            ForEach(habits.indices, id: \.self) { index in
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("\(index + 1).")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                            .frame(width: 24, alignment: .leading)
                                        
                                        Text("Habit \(index + 1)")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(HabitTheme.primaryText)
                                        
                                        Spacer()
                                        
                                        if habits.count > 1 {
                                            Button(action: {
                                                deleteHabit(at: IndexSet(integer: index))
                                            }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                    
                                    VStack(spacing: 8) {
                                        TextField("Habit name", text: $habits[index].name)
                                            .textFieldStyle(ModernTextFieldStyle())
                                        
                                        TextField("Description (optional)", text: $habits[index].description)
                                            .textFieldStyle(ModernTextFieldStyle())
                                    }
                                }
                                .padding(20)
                                .background(
                                    ZStack {
                                        // Glass morphism base
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        HabitTheme.cardBackground.opacity(0.8),
                                                        HabitTheme.cardBackground.opacity(0.6)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(.regularMaterial)
                                            )
                                        
                                        // Highlight overlay
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.15),
                                                        Color.clear
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                        
                                        // Border gradient
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.3),
                                                        Color.white.opacity(0.1),
                                                        HabitTheme.inactive.opacity(0.2)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    }
                                    .shadow(
                                        color: Color.black.opacity(0.08),
                                        radius: 12,
                                        x: 0,
                                        y: 6
                                    )
                                    .shadow(
                                        color: Color.black.opacity(0.04),
                                        radius: 4,
                                        x: 0,
                                        y: 2
                                    )
                                )
                                .padding(.horizontal, 20)
                            }
                            
                            // Add habit button
                            Button(action: addHabit) {
                                HStack(spacing: 12) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                    Text("Add Another Habit")
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.blue)
                                .padding(.vertical, 18)
                                .padding(.horizontal, 24)
                                .frame(maxWidth: .infinity)
                                .background(
                                    ZStack {
                                        // Glass morphism base
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.blue.opacity(0.12),
                                                        Color.blue.opacity(0.06)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .background(
                                                RoundedRectangle(cornerRadius: 18)
                                                    .fill(.ultraThinMaterial)
                                            )
                                        
                                        // Highlight overlay
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.2),
                                                        Color.clear
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                        
                                        // Border gradient
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color.blue.opacity(0.4),
                                                        Color.blue.opacity(0.2)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    }
                                    .shadow(
                                        color: Color.blue.opacity(0.2),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                                    .shadow(
                                        color: Color.black.opacity(0.05),
                                        radius: 4,
                                        x: 0,
                                        y: 2
                                    )
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Bottom spacing
                        Color.clear.frame(height: 100)
                    }
                }
            }
            .navigationTitle("Create Custom Ladder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCustomLadder()
                    }
                    .disabled(!isValidLadder)
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingEmojiPicker) {
            EmojiPickerView(selectedEmoji: $selectedEmoji, availableEmojis: availableEmojis)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isValidLadder: Bool {
        !ladderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        habits.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count >= 1
    }
    
    private func addHabit() {
        habits.append(NewHabit())
    }
    
    private func deleteHabit(at offsets: IndexSet) {
        if habits.count > 1 {
            habits.remove(atOffsets: offsets)
        }
    }
    
    private func saveCustomLadder() {
        let trimmedName = ladderName.trimmingCharacters(in: .whitespacesAndNewlines)
        let validHabits = habits.filter { 
            !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
        }
        
        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter a ladder name."
            showingError = true
            return
        }
        
        guard validHabits.count >= 1 else {
            errorMessage = "Please add at least one habit."
            showingError = true
            return
        }
        
        let habitModels = validHabits.map { habit in
            Habit(
                name: habit.name.trimmingCharacters(in: .whitespacesAndNewlines),
                description: habit.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 
                    habit.name.trimmingCharacters(in: .whitespacesAndNewlines) : 
                    habit.description.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
        
        let customLadder = CustomHabitLadder(
            name: trimmedName,
            habits: habitModels,
            emoji: storeManager.isPremiumUser ? selectedEmoji : nil
        )
        
        habitManager.addCustomLadder(customLadder)
        dismiss()
    }
}

// MARK: - Emoji Picker View
struct EmojiPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedEmoji: String
    let availableEmojis: [String]
    
    let columns = Array(repeating: GridItem(.flexible()), count: 6)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(availableEmojis, id: \.self) { emoji in
                        Button(action: {
                            selectedEmoji = emoji
                            dismiss()
                        }) {
                            Text(emoji)
                                .font(.largeTitle)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(selectedEmoji == emoji ? .blue.opacity(0.2) : .clear)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedEmoji == emoji ? .blue : .clear, lineWidth: 2)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - End of Day Recap View
struct EndOfDayRecapView: View {
    @Environment(\.dismiss) private var dismiss
    let habits: [Habit]
    
    private var habitsCompletedToday: [Habit] {
        habits.filter { $0.isCompletedToday }
    }
    
    private var habitsNotCompletedToday: [Habit] {
        habits.filter { !$0.isCompletedToday }
    }
    
    private var completionRate: String {
        let completed = habitsCompletedToday.count
        let total = habits.count
        return "\(completed) out of \(total)"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [HabitTheme.backgroundPrimary, HabitTheme.backgroundSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Text("🌅")
                                .font(.system(size: 60))
                                .scaleEffect(1.1)
                                .padding(.top, 20)
                            
                            Text("Daily Recap")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(HabitTheme.primaryText)
                            
                            Text("How did your day go?")
                                .font(.headline)
                                .foregroundColor(HabitTheme.secondaryText)
                        }
                        
                        // Completion summary card
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(habitsCompletedToday.count > habitsNotCompletedToday.count ? 
                                          HabitTheme.success : HabitTheme.warning)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text("\(habitsCompletedToday.count)")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Habits Completed")
                                        .font(.headline)
                                        .foregroundColor(HabitTheme.primaryText)
                                    
                                    Text(completionRate + " habits completed")
                                        .font(.subheadline)
                                        .foregroundColor(HabitTheme.secondaryText)
                                    
                                    // Progress bar
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .fill(HabitTheme.inactive.opacity(0.3))
                                                .frame(height: 6)
                                                .cornerRadius(3)
                                            
                                            Rectangle()
                                                .fill(habitsCompletedToday.count > habitsNotCompletedToday.count ? 
                                                      HabitTheme.success : HabitTheme.warning)
                                                .frame(
                                                    width: habits.isEmpty ? 0 : 
                                                        geometry.size.width * CGFloat(habitsCompletedToday.count) / CGFloat(habits.count),
                                                    height: 6
                                                )
                                                .cornerRadius(3)
                                        }
                                    }
                                    .frame(height: 6)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(HabitTheme.cardBackground)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        
                        // Completed habits section
                        if !habitsCompletedToday.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("✅ Completed Today")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(HabitTheme.success)
                                    Spacer()
                                }
                                
                                ForEach(habitsCompletedToday, id: \.id) { habit in
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(HabitTheme.success)
                                            .frame(width: 8, height: 8)
                                        
                                        Text(habit.name)
                                            .font(.body)
                                            .foregroundColor(HabitTheme.primaryText)
                                        
                                        Spacer()
                                        
                                        Text("✅")
                                            .font(.body)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(HabitTheme.success.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(HabitTheme.success.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // Not completed habits section
                        if !habitsNotCompletedToday.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("❌ Not Completed Today")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(HabitTheme.warning)
                                    Spacer()
                                }
                                
                                ForEach(habitsNotCompletedToday, id: \.id) { habit in
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(HabitTheme.warning)
                                            .frame(width: 8, height: 8)
                                        
                                        Text(habit.name)
                                            .font(.body)
                                            .foregroundColor(HabitTheme.primaryText)
                                        
                                        Spacer()
                                        
                                        Text("❌")
                                            .font(.body)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(HabitTheme.warning.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(HabitTheme.warning.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // Motivational message
                        VStack(spacing: 8) {
                            Text(motivationalMessage)
                                .font(.body)
                                .foregroundColor(HabitTheme.secondaryText)
                                .multilineTextAlignment(.center)
                                .italic()
                            
                            Text("Keep building those habits! 💪")
                                .font(.caption)
                                .foregroundColor(HabitTheme.secondaryText)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(HabitTheme.cardBackground.opacity(0.5))
                        )
                        .padding(.horizontal, 20)
                        
                        // Bottom spacing
                        Color.clear.frame(height: 40)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var motivationalMessage: String {
        let completionPercentage = habits.isEmpty ? 0 : (Double(habitsCompletedToday.count) / Double(habits.count))
        
        switch completionPercentage {
        case 1.0:
            return "Perfect day! You completed all your habits. You're unstoppable! 🌟"
        case 0.8...0.99:
            return "Amazing work! You're so close to a perfect day. Keep it up! 🚀"
        case 0.6...0.79:
            return "Great progress today! You're building strong momentum. 💪"
        case 0.4...0.59:
            return "Good effort today! Every habit counts toward your goals. 📈"
        case 0.2...0.39:
            return "Tomorrow is a fresh start! Small steps lead to big changes. 🌱"
        case 0.01...0.19:
            return "Every journey starts with a single step. You've got this! ✨"
        default:
            return "Tomorrow is a new opportunity to build great habits! 🌅"
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Unlock Toast View
struct UnlockToast: View {
    let message: String
    @State private var offsetY: CGFloat = -100
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var sparkleOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 12) {
            // Animated unlock icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: Color.yellow.opacity(0.4), radius: 8, x: 0, y: 2)
                
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(sparkleOffset * 0.1))
            }
            .scaleEffect(scale)
            
            // Message text
            Text(message)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(HabitTheme.primaryText)
                .lineLimit(2)
            
            Spacer()
            
            // Sparkle animation
            Image(systemName: "sparkles")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.yellow)
                .rotationEffect(.degrees(sparkleOffset))
                .scaleEffect(1.0 + sin(sparkleOffset * .pi / 180) * 0.2)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(HabitTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.6), Color.orange.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: Color.yellow.opacity(0.3),
                    radius: 12,
                    x: 0,
                    y: 4
                )
        )
        .offset(y: offsetY)
        .opacity(opacity)
        .scaleEffect(scale)
        .onAppear {
            // Entry animation
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8, blendDuration: 0.2)) {
                offsetY = 0
                opacity = 1
                scale = 1.0
            }
            
            // Continuous sparkle animation
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                sparkleOffset = 360
            }
        }
    }
}

// MARK: - Sparkle Animation Component
struct SparkleAnimation: View {
    @State private var sparkles: [SparkleParticle] = []
    @State private var animationTimer: Timer?
    
    private struct SparkleParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
        var rotation: Double
        var color: Color
        var velocity: CGPoint
    }
    
    var body: some View {
        ZStack {
            ForEach(sparkles) { sparkle in
                Image(systemName: Bool.random() ? "sparkles" : "star.fill")
                    .font(.system(size: 12 + sparkle.scale * 8, weight: .medium))
                    .foregroundColor(sparkle.color)
                    .opacity(sparkle.opacity)
                    .scaleEffect(sparkle.scale)
                    .rotationEffect(.degrees(sparkle.rotation))
                    .position(x: sparkle.x, y: sparkle.y)
            }
        }
        .onAppear {
            startSparkleAnimation()
        }
        .onDisappear {
            stopSparkleAnimation()
        }
    }
    
    private func startSparkleAnimation() {
        // Create initial sparkles
        createSparkles()
        
        // Start animation timer
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateSparkles()
        }
    }
    
    private func stopSparkleAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        sparkles.removeAll()
    }
    
    private func createSparkles() {
        for _ in 0..<20 {
            let sparkle = SparkleParticle(
                x: CGFloat.random(in: 50...300),
                y: CGFloat.random(in: 100...600),
                scale: CGFloat.random(in: 0.5...1.5),
                opacity: Double.random(in: 0.6...1.0),
                rotation: Double.random(in: 0...360),
                color: [Color.yellow, Color.orange, Color.white, Color.cyan].randomElement()!,
                velocity: CGPoint(
                    x: CGFloat.random(in: -2...2),
                    y: CGFloat.random(in: -4...1)
                )
            )
            sparkles.append(sparkle)
        }
    }
    
    private func updateSparkles() {
        withAnimation(.easeInOut(duration: 0.1)) {
            for i in 0..<sparkles.count {
                sparkles[i].x += sparkles[i].velocity.x
                sparkles[i].y += sparkles[i].velocity.y
                sparkles[i].rotation += Double.random(in: -5...5)
                sparkles[i].opacity *= 0.98
                sparkles[i].scale *= 0.99
                
                // Remove faded sparkles and add new ones
                if sparkles[i].opacity < 0.1 || sparkles[i].y > 700 {
                    sparkles[i] = SparkleParticle(
                        x: CGFloat.random(in: 50...300),
                        y: CGFloat.random(in: -50...100),
                        scale: CGFloat.random(in: 0.5...1.5),
                        opacity: Double.random(in: 0.6...1.0),
                        rotation: Double.random(in: 0...360),
                        color: [Color.yellow, Color.orange, Color.white, Color.cyan].randomElement()!,
                        velocity: CGPoint(
                            x: CGFloat.random(in: -2...2),
                            y: CGFloat.random(in: -4...1)
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            HabitTheme.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App icon with animation
                Image("SplashIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: HabitTheme.primary.opacity(0.3), radius: 12, x: 0, y: 6)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                
                VStack(spacing: 8) {
                    Text("Loading your habits...")
                        .font(.headline)
                        .foregroundColor(HabitTheme.primaryText)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: HabitTheme.primary))
                        .scaleEffect(1.2)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Ladder Switcher Card Components
struct LadderSwitcherCard: View {
    let emoji: String
    let name: String
    let isActive: Bool
    let isPlaceholder: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.title2)
                
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isPlaceholder ? HabitTheme.secondaryText : (isActive ? .white : HabitTheme.primaryText))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColorForCard())
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(borderColorForCard(), lineWidth: isActive ? 2 : 1)
                    )
            )
            .shadow(
                color: shadowColorForCard(),
                radius: isActive ? 8 : 4,
                x: 0,
                y: 2
            )
            .scaleEffect(isActive ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isActive)
        }
        .buttonStyle(.plain)
    }
    
    private func backgroundColorForCard() -> Color {
        if isPlaceholder {
            return HabitTheme.cardBackground.opacity(0.7)
        } else if isActive {
            return HabitTheme.primary
        } else {
            return HabitTheme.cardBackground
        }
    }
    
    private func borderColorForCard() -> Color {
        if isPlaceholder {
            return HabitTheme.inactive.opacity(0.5)
        } else if isActive {
            return HabitTheme.primary
        } else {
            return HabitTheme.inactive.opacity(0.3)
        }
    }
    
    private func shadowColorForCard() -> Color {
        if isActive {
            return HabitTheme.primary.opacity(0.3)
        } else {
            return .black.opacity(0.1)
        }
    }
}

struct AddLadderCard: View {
    let action: () -> Void
    let isLocked: Bool
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: isLocked ? "lock.fill" : "plus")
                    .font(.title2)
                    .foregroundColor(isLocked ? .orange : HabitTheme.primary)
                
                Text(isLocked ? "Locked" : "Add")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isLocked ? .orange : HabitTheme.primary)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isLocked ? Color.orange.opacity(0.1) : HabitTheme.primary.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isLocked ? Color.orange.opacity(0.4) : HabitTheme.primary.opacity(0.4),
                                lineWidth: 1.5
                            )
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                    )
            )
            .shadow(
                color: isLocked ? Color.orange.opacity(0.2) : HabitTheme.primary.opacity(0.2),
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }
}
