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
    let onComplete: () -> Void
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to HabitLadder",
            subtitle: "Your Journey to Better Habits Starts Here",
            description: "Build lasting habits step by step with our unique ladder system. Each habit unlocks the next, creating a natural progression toward your goals.",
            icon: "ladder.horizontal",
            primaryColor: HabitTheme.primary,
            features: [
                "Progressive habit building",
                "Streak tracking system",
                "Visual progress indicators"
            ]
        ),
        OnboardingPage(
            title: "The Ladder System",
            subtitle: "One Step at a Time",
            description: "Complete habits 3 days in a row to unlock the next level. This proven approach prevents overwhelm and builds sustainable momentum.",
            icon: "arrow.up.circle.fill",
            primaryColor: HabitTheme.success,
            features: [
                "Complete 3 consecutive days",
                "Unlock the next habit",
                "Build unstoppable momentum"
            ]
        ),
        OnboardingPage(
            title: "Track Your Progress",
            subtitle: "See Your Success",
            description: "Visual streaks, completion badges, and progress indicators keep you motivated. Celebrate every milestone on your journey.",
            icon: "chart.line.uptrend.xyaxis",
            primaryColor: HabitTheme.accent,
            features: [
                "Daily completion tracking",
                "Streak visualization",
                "Achievement celebrations"
            ]
        ),
        OnboardingPage(
            title: "Start Your Journey",
            subtitle: "Ready to Transform Your Life?",
            description: "Create your first habit and begin climbing your personal ladder to success. Small steps lead to big changes.",
            icon: "flag.checkered.circle.fill",
            primaryColor: HabitTheme.primary,
            features: [
                "Add your first habit",
                "Set daily reminders",
                "Watch your progress grow"
            ]
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        HabitTheme.backgroundPrimary,
                        HabitTheme.backgroundSecondary
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Skip button
                    HStack {
                        Spacer()
                        Button("Skip") {
                            onComplete()
                        }
                        .font(.subheadline)
                        .foregroundColor(HabitTheme.secondaryText)
                        .padding()
                    }
                    
                    // Page content
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingPageView(
                                page: pages[index],
                                geometry: geometry,
                                isActive: currentPage == index
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                    
                    // Bottom controls - Fixed at bottom
                    VStack(spacing: 20) {
                        // Page indicators
                        HStack(spacing: 8) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? pages[currentPage].primaryColor : HabitTheme.inactive)
                                    .frame(width: currentPage == index ? 12 : 8, height: currentPage == index ? 12 : 8)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // Action buttons
                        HStack(spacing: 16) {
                            if currentPage > 0 {
                                Button("Previous") {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        currentPage -= 1
                                    }
                                }
                                .font(.headline)
                                .foregroundColor(HabitTheme.secondaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(HabitTheme.inactive, lineWidth: 2)
                                        .fill(.clear)
                                )
                            }
                            
                            Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                                // Trigger animation
                                isAnimating = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isAnimating = false
                                }
                                
                                // Handle navigation
                                if currentPage == pages.count - 1 {
                                    onComplete()
                                } else {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        currentPage += 1
                                    }
                                }
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(pages[currentPage].primaryColor)
                                    .shadow(
                                        color: pages[currentPage].primaryColor.opacity(0.3),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            )
                            .scaleEffect(isAnimating ? 0.95 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, max(32, geometry.safeAreaInsets.bottom + 16))
                }
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let primaryColor: Color
    let features: [String]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let geometry: GeometryProxy
    let isActive: Bool
    
    @State private var iconScale: CGFloat = 0.8
    @State private var contentOffset: CGFloat = 50
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                
                // Icon
                VStack(spacing: 20) {
                    Image(systemName: page.icon)
                        .font(.system(size: 70, weight: .light))
                        .foregroundColor(page.primaryColor)
                        .scaleEffect(iconScale)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: iconScale)
                    
                    VStack(spacing: 8) {
                        Text(page.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(HabitTheme.primaryText)
                            .multilineTextAlignment(.center)
                        
                        Text(page.subtitle)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(page.primaryColor)
                            .multilineTextAlignment(.center)
                    }
                }
                .offset(y: contentOffset)
                .opacity(contentOpacity)
                
                // Description
                Text(page.description)
                    .font(.body)
                    .foregroundColor(HabitTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 24)
                    .offset(y: contentOffset)
                    .opacity(contentOpacity)
                
                // Features
                VStack(spacing: 12) {
                    ForEach(Array(page.features.enumerated()), id: \.offset) { index, feature in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(page.primaryColor)
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(feature)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(HabitTheme.primaryText)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .offset(y: contentOffset)
                        .opacity(contentOpacity)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1),
                            value: contentOpacity
                        )
                    }
                }
                
                Spacer(minLength: 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if isActive {
                animateIn()
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                animateIn()
            } else {
                animateOut()
            }
        }
    }
    
    private func animateIn() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            iconScale = 1.0
            contentOffset = 0
            contentOpacity = 1.0
        }
    }
    
    private func animateOut() {
        withAnimation(.easeOut(duration: 0.3)) {
            iconScale = 0.8
            contentOffset = 50
            contentOpacity = 0
        }
    }
}

// MARK: - Color Theme
struct HabitTheme {
    // Primary colors
    static let primary = Color("PrimaryColor")
    static let secondary = Color("SecondaryColor")
    static let accent = Color("AccentColor")
    
    // Background colors
    static let backgroundPrimary = Color("BackgroundPrimary")
    static let backgroundSecondary = Color("BackgroundSecondary")
    static let cardBackground = Color("CardBackground")
    
    // State colors
    static let success = Color("SuccessColor")
    static let warning = Color("WarningColor")
    static let inactive = Color("InactiveColor")
    
    // Semantic colors with dark mode support
    static let primaryText: Color = Color.primary
    static let secondaryText: Color = Color.secondary
    static let tertiaryText: Color = Color(UIColor.tertiaryLabel)
    
    static let unlockedBackground: Color = Color(UIColor.systemBackground)
    static let lockedBackground: Color = Color(UIColor.secondarySystemBackground)
    static let completedBackground: Color = Color(UIColor.systemGreen).opacity(0.1)
    
    static let unlockedBorder: Color = Color(UIColor.systemBlue).opacity(0.3)
    static let lockedBorder: Color = Color(UIColor.separator)
    static let completedBorder: Color = Color(UIColor.systemGreen).opacity(0.4)
}

// MARK: - Modern Text Field Style
struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.body)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(HabitTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(HabitTheme.unlockedBorder.opacity(0.6), lineWidth: 1.5)
                    )
                    .shadow(
                        color: .black.opacity(0.06),
                        radius: 8,
                        x: 0,
                        y: 4
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
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(HabitTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(HabitTheme.unlockedBorder.opacity(0.6), lineWidth: 2)
                    )
                    .shadow(
                        color: .black.opacity(0.08),
                        radius: 12,
                        x: 0,
                        y: 6
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
        let colors: [Color] = [
            .red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan
        ]
        
        return ConfettiParticle(
            x: CGFloat.random(in: 0...rect.width),
            y: rect.height + 50,
            velocityX: CGFloat.random(in: -3...3),
            velocityY: CGFloat.random(in: -8...(-4)),
            color: colors.randomElement() ?? .blue,
            size: CGFloat.random(in: 4...8),
            rotation: Double.random(in: 0...360),
            rotationSpeed: Double.random(in: -5...5)
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
                    Rectangle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.life)
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
        
        // Initial burst
        for _ in 0..<50 {
            particles.append(ConfettiParticle.createRandom(in: rect))
        }
        
        // Continuous generation
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Add new particles
            for _ in 0..<3 {
                particles.append(ConfettiParticle.createRandom(in: rect))
            }
            
            // Update existing particles
            particles = particles.compactMap { particle in
                var updatedParticle = particle
                updatedParticle.x += particle.velocityX
                updatedParticle.y += particle.velocityY
                updatedParticle.velocityY += 0.2 // gravity
                updatedParticle.rotation += particle.rotationSpeed
                updatedParticle.life -= 0.02
                
                return updatedParticle.life > 0 && updatedParticle.y < size.height + 100 ? updatedParticle : nil
            }
        }
        
        // Stop after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            timer?.invalidate()
            withAnimation(.easeOut(duration: 1.0)) {
                particles.removeAll()
            }
        }
    }
}

// MARK: - Models
struct Habit: Identifiable, Codable {
    var id = UUID()
    var name: String
    var description: String
    
    /// Array storing completion dates as Date objects
    /// Each date represents a day when the habit was completed
    var completionDates: [Date] = []
    
    /// Store the last checked date to prevent double submissions
    var lastCheckedDate: Date?
    
    var isUnlocked: Bool = false
    
    // Check if habit has been completed 3 times in a row
    var hasThreeConsecutiveCompletions: Bool {
        return consecutiveStreakCount >= 3
    }
    
    /// Returns the current consecutive completion streak count
    var consecutiveStreakCount: Int {
        guard !completionDates.isEmpty else { return 0 }
        
        let sortedDates = completionDates.sorted(by: >)  // Most recent first
        let calendar = Calendar.current
        
        // Start from the most recent completion and count backwards
        var streak = 1
        var currentDate = sortedDates[0]
        
        for i in 1..<sortedDates.count {
            let nextDate = sortedDates[i]
            let daysBetween = calendar.dateComponents([.day], from: nextDate, to: currentDate).day ?? 0
            
            if daysBetween == 1 {
                streak += 1
                currentDate = nextDate
            } else {
                break  // Streak is broken
            }
        }
        
        return streak
    }
    
    /// Check if habit has been completed today using Calendar.current.isDateInToday()
    var isCompletedToday: Bool {
        guard let lastCheckedDate = lastCheckedDate else { return false }
        return Calendar.current.isDateInToday(lastCheckedDate)
    }
    
    /// Total number of days this habit has been completed
    var totalCompletionDays: Int {
        return completionDates.count
    }
    
    /// Check if this habit can be completed today (unlocked and not already completed)
    var canCompleteToday: Bool {
        return isUnlocked && !isCompletedToday
    }
    
    /// Check if this habit is eligible to unlock the next habit
    var isEligibleToUnlockNext: Bool {
        return hasThreeConsecutiveCompletions
    }
}

// MARK: - Custom Habit Ladder Model
struct CustomHabitLadder: Identifiable, Codable {
    var id = UUID()
    var name: String
    var habits: [Habit]
    var createdDate: Date = Date()
    
    init(name: String, habits: [Habit]) {
        self.name = name
        self.habits = habits
        // Ensure first habit is unlocked
        if !habits.isEmpty {
            self.habits[0].isUnlocked = true
        }
    }
}

// MARK: - Habit Storage Manager
class HabitManager: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var customLadders: [CustomHabitLadder] = []
    @Published var activeCustomLadder: CustomHabitLadder?
    @Published var showConfetti: Bool = false
    @Published var lastUnlockedHabitId: UUID?
    
    private let userDefaults = UserDefaults.standard
    private let habitsKey = "SavedHabits"
    private let customLaddersKey = "CustomHabitLadders"
    private let activeCustomLadderKey = "ActiveCustomLadder"
    
    // Check if all habits are unlocked
    var allHabitsUnlocked: Bool {
        !habits.isEmpty && habits.allSatisfy { $0.isUnlocked }
    }
    
    init() {
        loadData()
    }
    
    func loadData() {
        loadHabits()
        loadCustomLadders()
        loadActiveCustomLadder()
    }
    
    func loadHabits() {
        if let data = userDefaults.data(forKey: habitsKey),
           let decodedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
            self.habits = decodedHabits
        } else {
            // Initialize with default habits if none exist
            self.habits = createDefaultHabits()
        }
        updateUnlockedStatus()
    }
    
    func loadCustomLadders() {
        if let data = userDefaults.data(forKey: customLaddersKey),
           let decodedLadders = try? JSONDecoder().decode([CustomHabitLadder].self, from: data) {
            self.customLadders = decodedLadders
        }
    }
    
    func loadActiveCustomLadder() {
        if let data = userDefaults.data(forKey: activeCustomLadderKey),
           let decodedLadder = try? JSONDecoder().decode(CustomHabitLadder.self, from: data) {
            self.activeCustomLadder = decodedLadder
            // Use custom ladder habits instead of default
            self.habits = decodedLadder.habits
            updateUnlockedStatus()
        }
    }
    
    func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            userDefaults.set(encoded, forKey: habitsKey)
        }
        
        // If using custom ladder, update it too
        if var customLadder = activeCustomLadder {
            customLadder.habits = habits
            activeCustomLadder = customLadder
            saveActiveCustomLadder()
            updateCustomLadder(customLadder)
        }
    }
    
    func saveCustomLadders() {
        if let encoded = try? JSONEncoder().encode(customLadders) {
            userDefaults.set(encoded, forKey: customLaddersKey)
        }
    }
    
    func saveActiveCustomLadder() {
        if let ladder = activeCustomLadder,
           let encoded = try? JSONEncoder().encode(ladder) {
            userDefaults.set(encoded, forKey: activeCustomLadderKey)
        } else {
            userDefaults.removeObject(forKey: activeCustomLadderKey)
        }
    }
    
    func createDefaultHabits() -> [Habit] {
        return [
            Habit(name: "Drink 8 glasses of water", description: "Stay hydrated throughout the day", isUnlocked: true),
            Habit(name: "Take a 10-minute walk", description: "Get some fresh air and light exercise"),
            Habit(name: "Read for 15 minutes", description: "Expand your knowledge and vocabulary"),
            Habit(name: "Practice gratitude", description: "Write down 3 things you're grateful for"),
            Habit(name: "Meditate for 5 minutes", description: "Focus on mindfulness and breathing"),
            Habit(name: "Exercise for 30 minutes", description: "Complete a workout or active activity"),
            Habit(name: "Learn something new", description: "Spend time on a new skill or hobby"),
            Habit(name: "Connect with a friend", description: "Reach out to someone you care about")
        ]
    }
    
    func updateUnlockedStatus() {
        let wasAllUnlocked = allHabitsUnlocked
        
        // First habit is always unlocked
        if !habits.isEmpty {
            habits[0].isUnlocked = true
        }
        
        // Track newly unlocked habits
        var newlyUnlockedHabits: [UUID] = []
        
        // Unlock subsequent habits based on previous completions
        for i in 1..<habits.count {
            let wasUnlocked = habits[i].isUnlocked
            habits[i].isUnlocked = habits[i-1].isEligibleToUnlockNext
            
            // Track if this habit was just unlocked
            if !wasUnlocked && habits[i].isUnlocked {
                newlyUnlockedHabits.append(habits[i].id)
            }
        }
        
        // Set the last unlocked habit for animation
        if let lastUnlocked = newlyUnlockedHabits.last {
            lastUnlockedHabitId = lastUnlocked
        }
        
        // Check if all habits are now unlocked and trigger confetti
        if !wasAllUnlocked && allHabitsUnlocked {
            triggerConfetti()
        }
    }
    
    private func triggerConfetti() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showConfetti = true
        }
        
        // Hide confetti after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [self] in
            withAnimation(.easeOut(duration: 0.5)) {
                showConfetti = false
            }
        }
    }
    
    func toggleHabitCompletion(for habitId: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == habitId }) else { return }
        
        let today = Date()
        
        // Check if already completed today using Calendar.current.isDateInToday()
        if let lastCheckedDate = habits[index].lastCheckedDate,
           Calendar.current.isDateInToday(lastCheckedDate) {
            // Already completed today, prevent double submission
            return
        }
        
        // Add today's completion and update last checked date
        habits[index].completionDates.append(today)
        habits[index].lastCheckedDate = today
        
        updateUnlockedStatus()
        saveHabits()
    }
    
    func resetAllHabits() {
        for i in 0..<habits.count {
            habits[i].completionDates.removeAll()
            habits[i].lastCheckedDate = nil
            habits[i].isUnlocked = (i == 0) // Only first habit remains unlocked
        }
        showConfetti = false
        lastUnlockedHabitId = nil
        saveHabits()
    }
    
    // MARK: - Custom Ladder Management
    func addCustomLadder(_ ladder: CustomHabitLadder) {
        customLadders.append(ladder)
        saveCustomLadders()
    }
    
    func updateCustomLadder(_ updatedLadder: CustomHabitLadder) {
        if let index = customLadders.firstIndex(where: { $0.id == updatedLadder.id }) {
            customLadders[index] = updatedLadder
            saveCustomLadders()
        }
    }
    
    func deleteCustomLadder(_ ladder: CustomHabitLadder) {
        customLadders.removeAll { $0.id == ladder.id }
        saveCustomLadders()
        
        // If deleted ladder was active, switch back to default
        if activeCustomLadder?.id == ladder.id {
            switchToDefaultHabits()
        }
    }
    
    func activateCustomLadder(_ ladder: CustomHabitLadder) {
        activeCustomLadder = ladder
        habits = ladder.habits
        updateUnlockedStatus()
        saveActiveCustomLadder()
    }
    
    func switchToDefaultHabits() {
        activeCustomLadder = nil
        saveActiveCustomLadder()
        loadHabits() // Reload default habits
    }
}

// MARK: - Custom Habit Ladder Creation View
struct CustomHabitLadderView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var habitManager: HabitManager
    
    @State private var ladderName = ""
    @State private var customHabits: [Habit] = []
    @State private var showingAddHabit = false
    @State private var editingHabit: Habit?
    @State private var newHabitName = ""
    @State private var newHabitDescription = ""
    @State private var showingDeleteAlert = false
    @State private var habitToDelete: Habit?
    
    var canSave: Bool {
        !ladderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        customHabits.count >= 3 &&
        customHabits.count <= 7
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    TextField("Ladder Name", text: $ladderName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .textFieldStyle(ModernLargeTextFieldStyle())
                    
                    Text("Create 3-7 habits in the order you want to build them")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(HabitTheme.lockedBackground)
                
                // Habits List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(customHabits.enumerated()), id: \.element.id) { index, habit in
                            CustomHabitEditRow(
                                habit: habit,
                                index: index,
                                onEdit: { editingHabit = habit },
                                onDelete: { 
                                    habitToDelete = habit
                                    showingDeleteAlert = true
                                },
                                onMoveUp: index > 0 ? { moveHabit(from: index, to: index - 1) } : nil,
                                onMoveDown: index < customHabits.count - 1 ? { moveHabit(from: index, to: index + 1) } : nil
                            )
                        }
                        
                        // Add habit button
                        if customHabits.count < 7 {
                            Button(action: { showingAddHabit = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                    Text("Add Habit")
                                        .fontWeight(.semibold)
                                }
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.blue.opacity(0.12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.blue.opacity(0.4), lineWidth: 1.5)
                                        )
                                        .shadow(
                                            color: Color.blue.opacity(0.15),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                )
                            }
                        }
                    }
                    .padding()
                }
                
                // Save button
                Button(action: saveCustomLadder) {
                    Text("Create Ladder")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(canSave ? Color.blue : Color.gray)
                                .shadow(
                                    color: canSave ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2),
                                    radius: 12,
                                    x: 0,
                                    y: 6
                                )
                        )
                }
                .disabled(!canSave)
                .scaleEffect(canSave ? 1.0 : 0.98)
                .animation(.easeInOut(duration: 0.2), value: canSave)
                .padding()
            }
            .navigationTitle("Custom Ladder")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView(
                habitName: $newHabitName,
                habitDescription: $newHabitDescription,
                onSave: addNewHabit,
                onCancel: { showingAddHabit = false }
            )
        }
        .sheet(item: $editingHabit) { habit in
            EditHabitView(
                habit: habit,
                onSave: { updatedHabit in
                    updateHabit(updatedHabit)
                    editingHabit = nil
                },
                onCancel: { editingHabit = nil }
            )
        }
        .alert("Delete Habit", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let habit = habitToDelete {
                    deleteHabit(habit)
                }
            }
        } message: {
            Text("Are you sure you want to delete this habit?")
        }
    }
    
    private func addNewHabit() {
        let habit = Habit(
            name: newHabitName,
            description: newHabitDescription,
            isUnlocked: customHabits.isEmpty
        )
        customHabits.append(habit)
        newHabitName = ""
        newHabitDescription = ""
        showingAddHabit = false
    }
    
    private func updateHabit(_ updatedHabit: Habit) {
        if let index = customHabits.firstIndex(where: { $0.id == updatedHabit.id }) {
            customHabits[index] = updatedHabit
        }
    }
    
    private func deleteHabit(_ habit: Habit) {
        customHabits.removeAll { $0.id == habit.id }
    }
    
    private func moveHabit(from source: Int, to destination: Int) {
        let habit = customHabits.remove(at: source)
        customHabits.insert(habit, at: destination)
    }
    
    private func saveCustomLadder() {
        let ladder = CustomHabitLadder(
            name: ladderName,
            habits: customHabits
        )
        habitManager.addCustomLadder(ladder)
        dismiss()
    }
}

// MARK: - Custom Habit Edit Row
struct CustomHabitEditRow: View {
    let habit: Habit
    let index: Int
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onMoveUp: (() -> Void)?
    let onMoveDown: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            // Order number
            Text("\(index + 1)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            // Habit info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(habit.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Move buttons
            VStack(spacing: 8) {
                if let onMoveUp = onMoveUp {
                    Button(action: onMoveUp) {
                        Image(systemName: "chevron.up")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                if let onMoveDown = onMoveDown {
                    Button(action: onMoveDown) {
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Edit and delete buttons
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(HabitTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(HabitTheme.unlockedBorder.opacity(0.4), lineWidth: 1.5)
                )
                .shadow(
                    color: .black.opacity(0.06),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
    }
}

// MARK: - Add Habit View
struct AddHabitView: View {
    @Binding var habitName: String
    @Binding var habitDescription: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var canSave: Bool {
        !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !habitDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Habit Name")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(HabitTheme.secondaryText)
                        .padding(.leading, 4)
                    
                    TextField("Enter habit name", text: $habitName)
                        .textFieldStyle(ModernTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(HabitTheme.secondaryText)
                        .padding(.leading, 4)
                    
                    TextField("Describe this habit", text: $habitDescription, axis: .vertical)
                        .textFieldStyle(ModernTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Add Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                        .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: onSave)
                        .disabled(!canSave)
                        .foregroundColor(canSave ? .blue : .gray)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Edit Habit View
struct EditHabitView: View {
    let habit: Habit
    let onSave: (Habit) -> Void
    let onCancel: () -> Void
    
    @State private var habitName: String
    @State private var habitDescription: String
    
    init(habit: Habit, onSave: @escaping (Habit) -> Void, onCancel: @escaping () -> Void) {
        self.habit = habit
        self.onSave = onSave
        self.onCancel = onCancel
        self._habitName = State(initialValue: habit.name)
        self._habitDescription = State(initialValue: habit.description)
    }
    
    var canSave: Bool {
        !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !habitDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Habit Name")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(HabitTheme.secondaryText)
                        .padding(.leading, 4)
                    
                    TextField("Enter habit name", text: $habitName)
                        .textFieldStyle(ModernTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(HabitTheme.secondaryText)
                        .padding(.leading, 4)
                    
                    TextField("Describe this habit", text: $habitDescription, axis: .vertical)
                        .textFieldStyle(ModernTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                        .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        var updatedHabit = habit
                        updatedHabit.name = habitName
                        updatedHabit.description = habitDescription
                        onSave(updatedHabit)
                    }
                    .disabled(!canSave)
                    .foregroundColor(canSave ? .blue : .gray)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var habitManager = HabitManager()
    @State private var showingResetAlert = false
    @State private var showingCustomLadderView = false
    @State private var showingLadderSelection = false
    @State private var showOnboarding = false
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding || showOnboarding {
                OnboardingView {
                    completeOnboarding()
                }
            } else {
                mainAppContent
            }
        }
        .onAppear {
            if !hasCompletedOnboarding {
                showOnboarding = true
            }
        }
    }
    
    private var mainAppContent: some View {
        NavigationView {
            ZStack {
                // Background
                HabitTheme.unlockedBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(habitManager.activeCustomLadder?.name ?? "HabitLadder")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(HabitTheme.primaryText)
                                
                                Text(habitManager.activeCustomLadder != nil ? "Custom ladder" : "Build habits step by step")
                                    .font(.subheadline)
                                    .foregroundColor(HabitTheme.secondaryText)
                            }
                            
                            Spacer()
                            
                            // All habits unlocked indicator
                            if habitManager.allHabitsUnlocked {
                                HStack(spacing: 6) {
                                    Image(systemName: "star.circle.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title2)
                                    Text("Complete!")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(HabitTheme.primaryText)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(.yellow.opacity(0.15))
                                        .overlay(
                                            Capsule()
                                                .stroke(.yellow.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .scaleEffect(habitManager.allHabitsUnlocked ? 1.0 : 0.8)
                                .opacity(habitManager.allHabitsUnlocked ? 1.0 : 0.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: habitManager.allHabitsUnlocked)
                            }
                            
                            // Menu button
                            Menu {
                                Button(action: { showingCustomLadderView = true }) {
                                    Label("Create Custom Ladder", systemImage: "plus")
                                }
                                
                                if !habitManager.customLadders.isEmpty {
                                    Button(action: { showingLadderSelection = true }) {
                                        Label("Switch Ladder", systemImage: "arrow.left.arrow.right")
                                    }
                                }
                                
                                if habitManager.activeCustomLadder != nil {
                                    Button(action: { habitManager.switchToDefaultHabits() }) {
                                        Label("Use Default Ladder", systemImage: "house")
                                    }
                                }
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(HabitTheme.lockedBackground)
                    
                    // Habits List
                    ScrollView {
                        LazyVStack(spacing: 16) {
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
                                    isNewlyUnlocked: habitManager.lastUnlockedHabitId == habit.id
                                )
                            }
                        }
                        .padding()
                    }
                    
                    // Reset Button
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
                    .padding()
                    .scaleEffect(showingResetAlert ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: showingResetAlert)
                }
                
                // Confetti overlay
                if habitManager.showConfetti {
                    ConfettiView(duration: 3.0)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCustomLadderView) {
            CustomHabitLadderView(habitManager: habitManager)
        }
        .sheet(isPresented: $showingLadderSelection) {
            LadderSelectionView(habitManager: habitManager)
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
        .onChange(of: habitManager.lastUnlockedHabitId) { _, _ in
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
    }
}

// MARK: - Ladder Selection View
struct LadderSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var habitManager: HabitManager
    @State private var showingDeleteAlert = false
    @State private var ladderToDelete: CustomHabitLadder?
    
    var body: some View {
        NavigationView {
            List {
                // Default ladder option
                Button(action: {
                    habitManager.switchToDefaultHabits()
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Default Ladder")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("8 built-in habits")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if habitManager.activeCustomLadder == nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Custom ladders
                ForEach(habitManager.customLadders) { ladder in
                    HStack {
                        Button(action: {
                            habitManager.activateCustomLadder(ladder)
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(ladder.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("\(ladder.habits.count) habits")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if habitManager.activeCustomLadder?.id == ladder.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        Button(action: {
                            ladderToDelete = ladder
                            showingDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Select Ladder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
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
    
    private var cardBackgroundColor: Color {
        if habit.isUnlocked {
            return habit.isCompletedToday ? 
                HabitTheme.completedBackground : 
                HabitTheme.unlockedBackground
        } else {
            return HabitTheme.lockedBackground
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
                    
                    // Description
                    Text(habit.description)
                        .font(.subheadline)
                        .foregroundColor(HabitTheme.secondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Unlock animation or lock icon
                if habit.isUnlocked {
                    if isNewlyUnlocked {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundColor(.yellow)
                            .scaleEffect(1.2)
                            .rotationEffect(.degrees(360))
                            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isNewlyUnlocked)
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
                // Progress circles
                HStack(spacing: 12) {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(HabitTheme.secondaryText)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(
                                    habit.isUnlocked && i < habit.consecutiveStreakCount ? 
                                    Color.green : 
                                    HabitTheme.tertiaryText.opacity(0.3)
                                )
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            habit.isUnlocked && i < habit.consecutiveStreakCount ? 
                                            Color.green.opacity(0.4) : 
                                            HabitTheme.tertiaryText.opacity(0.5), 
                                            lineWidth: 1
                                        )
                                )
                                .scaleEffect(habit.isUnlocked && i < habit.consecutiveStreakCount ? 1.2 : 1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: habit.consecutiveStreakCount)
                                .shadow(
                                    color: habit.isUnlocked && i < habit.consecutiveStreakCount ? Color.green.opacity(0.3) : .clear,
                                    radius: 4,
                                    x: 0,
                                    y: 2
                                )
                        }
                    }
                    
                    Text("\(habit.isUnlocked ? habit.consecutiveStreakCount : 0)/3")
                        .font(.caption)
                        .foregroundColor(habit.hasThreeConsecutiveCompletions ? .green : HabitTheme.secondaryText)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .scaleEffect(habit.hasThreeConsecutiveCompletions ? 1.1 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: habit.hasThreeConsecutiveCompletions)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    habit.isCompletedToday ? 
                                    Color.green.opacity(0.12) : 
                                    Color.blue.opacity(0.12)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            habit.isCompletedToday ? 
                                            Color.green.opacity(0.4) : 
                                            Color.blue.opacity(0.4), 
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(
                                    color: habit.isCompletedToday ? 
                                        Color.green.opacity(0.2) : 
                                        Color.blue.opacity(0.15),
                                    radius: 6,
                                    x: 0,
                                    y: 3
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(HabitTheme.tertiaryText.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(HabitTheme.tertiaryText.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(cardBorderColor, lineWidth: 1.5)
                )
                .shadow(
                    color: shadowColor,
                    radius: shadowRadius,
                    x: 0,
                    y: habit.isUnlocked ? 6 : 2
                )
        )
        .scaleEffect(habit.isUnlocked ? (isNewlyUnlocked ? 1.05 : 1.0) : 0.96)
        .opacity(habit.isUnlocked ? 1.0 : 0.7)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: habit.isUnlocked)
        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: isNewlyUnlocked)
    }
}

#Preview {
    ContentView()
}
