import Foundation
import SwiftUI

// MARK: - Habit Storage Manager
class HabitManager: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var customLadders: [CustomHabitLadder] = []
    @Published var activeCustomLadder: CustomHabitLadder?
    @Published var showConfetti: Bool = false
    @Published var showCelebrationPopup: Bool = false
    @Published var celebrationMessage: String = ""
    @Published var lastUnlockedHabitId: UUID?
    @Published var hasUsedDefaultProfile: Bool = false
    @Published var hasUsedCustomLadder: Bool = false
    @Published var showMicroAffirmation: Bool = false
    @Published var microAffirmationMessage: String = ""
    @Published var defaultLadder: CustomHabitLadder? // The user's selected default ladder
    
    // Enhanced unlock animation system
    @Published var showUnlockToast: Bool = false
    @Published var unlockToastMessage: String = ""
    @Published var unlockedHabitForAnimation: UUID?
    @Published var showSparkleAnimation: Bool = false
    @Published var isDataLoaded: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let habitsKey = "SavedHabits"
    private let defaultHabitsKey = "DefaultHabits" // Keep for migration purposes
    private let customLaddersKey = "CustomHabitLadders"
    private let activeCustomLadderKey = "ActiveCustomLadder"
    private let defaultLadderKey = "DefaultLadder" // New key for user's default ladder
    private let hasUsedDefaultProfileKey = "HasUsedDefaultProfile"
    private let hasUsedCustomLadderKey = "HasUsedCustomLadder"
    
    // Check if all habits are unlocked
    var allHabitsUnlocked: Bool {
        !habits.isEmpty && habits.allSatisfy { $0.isUnlocked }
    }
    
    // Micro-affirmation messages for habit completion
    private let microAffirmations = [
        "You're showing up. That's everything.",
        "Small wins become unshakable habits.",
        "Progress over perfection. You're doing it.",
        "Every action builds the person you're becoming.",
        "Consistency is your superpower.",
        "You chose growth today. That matters.",
        "Building habits, building character.",
        "One day at a time. You're getting stronger.",
        "Your future self is proud of this moment.",
        "Momentum is building. Keep going.",
        "This is how transformation happens.",
        "You're proving to yourself what's possible.",
        "Small steps, big impact.",
        "You're creating your best life, one habit at a time.",
        "Discipline is self-love in action.",
        "Another step forward. You're unstoppable.",
        "Habits are the compound interest of self-improvement.",
        "You're building something beautiful.",
        "Every choice is a vote for who you want to become.",
        "Excellence is a habit. You're practicing it now.",
        "The path you're walking leads to greatness.",
        "Today's effort becomes tomorrow's strength.",
        "You're investing in your future self.",
        "This moment matters. You matter."
    ]
    
    init() {
        loadData()
        setupAutoSaving()
    }
    
    private func setupAutoSaving() {
        // Set up automatic saving when app goes to background
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.saveHabits()
            self?.saveCustomLadders()
            self?.saveUsageFlags()
            print("📱 HabitManager: Auto-saved data due to app backgrounding")
        }
        
        // Set up automatic saving when app will terminate
        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.saveHabits()
            self?.saveCustomLadders()
            self?.saveUsageFlags()
            print("📱 HabitManager: Auto-saved data due to app termination")
        }
        
        // Set up periodic auto-save every 30 seconds when app is active
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.saveHabits()
            self?.saveCustomLadders()
            self?.saveUsageFlags()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadData() {
        loadDefaultLadder()
        loadHabits()
        loadCustomLadders()
        loadActiveCustomLadder()
        loadUsageFlags()
        
        // Clean up any profile-based ladders that might be in custom ladders from previous versions
        cleanupProfileBasedCustomLadders()
        
        // Mark data as loaded
        DispatchQueue.main.async {
            self.isDataLoaded = true
        }
    }
    
    func loadDefaultLadder() {
        if let data = userDefaults.data(forKey: defaultLadderKey),
           let decodedLadder = try? JSONDecoder().decode(CustomHabitLadder.self, from: data) {
            self.defaultLadder = decodedLadder
        }
    }
    
    func saveDefaultLadder() {
        if let ladder = defaultLadder,
           let encoded = try? JSONEncoder().encode(ladder) {
            userDefaults.set(encoded, forKey: defaultLadderKey)
        }
    }
    
    func loadHabits() {
        var habitsToLoad: [Habit] = []
        
        if let data = userDefaults.data(forKey: habitsKey),
           let decodedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
            habitsToLoad = decodedHabits
        } else if let defaultLadder = defaultLadder {
            // Use the user's default ladder if no habits are saved
            habitsToLoad = defaultLadder.habits
        } else {
            // If no default ladder is set, user needs to select a profile
            habitsToLoad = []
        }
        
        // Ensure habits are updated on main thread
        DispatchQueue.main.async {
            self.habits = habitsToLoad
            self.updateUnlockedStatus()
        }
    }
    
    // Legacy function for migration - no longer used
    func loadDefaultHabits() {
        if let data = userDefaults.data(forKey: defaultHabitsKey),
           let decodedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
            self.habits = decodedHabits
        } else {
            // No default habits to load - user needs to select a profile
            self.habits = []
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
            // Ensure updates happen on main thread
            DispatchQueue.main.async {
                self.activeCustomLadder = decodedLadder
                // Use custom ladder habits instead of default
                self.habits = decodedLadder.habits
                self.updateUnlockedStatus()
            }
        }
    }
    
    func loadUsageFlags() {
        hasUsedDefaultProfile = userDefaults.bool(forKey: hasUsedDefaultProfileKey)
        hasUsedCustomLadder = userDefaults.bool(forKey: hasUsedCustomLadderKey)
    }
    
    func saveHabits() {
        // If using custom ladder, update it
        if var customLadder = activeCustomLadder {
            customLadder.habits = habits
            activeCustomLadder = customLadder
            saveActiveCustomLadder()
            updateCustomLadder(customLadder)
        } else if var userDefaultLadder = defaultLadder {
            // Save to user's default ladder when not using custom ladder
            userDefaultLadder.habits = habits
            defaultLadder = userDefaultLadder
            saveDefaultLadder()
        } else {
            // Fallback to saving as regular habits (for migration)
            if let encoded = try? JSONEncoder().encode(habits) {
                userDefaults.set(encoded, forKey: habitsKey)
            }
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
    
    func saveUsageFlags() {
        userDefaults.set(hasUsedDefaultProfile, forKey: hasUsedDefaultProfileKey)
        userDefaults.set(hasUsedCustomLadder, forKey: hasUsedCustomLadderKey)
    }
    

    
    func updateUnlockedStatus() {
        // Early return if no habits are loaded
        guard !habits.isEmpty else { return }
        
        let wasAllUnlocked = allHabitsUnlocked
        
        // First habit is always unlocked
        habits[0].isUnlocked = true
        
        // Track newly unlocked habits
        var newlyUnlockedHabits: [UUID] = []
        var habitThatUnlockedNext: Habit?
        
        // Unlock subsequent habits based on previous completions
        for i in 1..<habits.count {
            let wasUnlocked = habits[i].isUnlocked
            let previousHabit = habits[i-1]
            let shouldBeUnlocked = previousHabit.isEligibleToUnlockNext
            
            // Check if this habit should be unlocked based on previous habit progress
            
            habits[i].isUnlocked = shouldBeUnlocked
            
            // Track if this habit was just unlocked and hasn't been celebrated
            if !wasUnlocked && habits[i].isUnlocked && !habits[i].hasBeenCelebrated {
                newlyUnlockedHabits.append(habits[i].id)
                habitThatUnlockedNext = previousHabit
                // Mark as celebrated to prevent retriggering
                habits[i].hasBeenCelebrated = true
                // Mark this habit as newly unlocked for celebration
            }
        }
        
        // Set the last unlocked habit for animation
        if let lastUnlocked = newlyUnlockedHabits.last {
            lastUnlockedHabitId = lastUnlocked
            unlockedHabitForAnimation = lastUnlocked
            
            // Trigger enhanced unlock celebration
            if let _ = habitThatUnlockedNext,
               let unlockedHabit = habits.first(where: { $0.id == lastUnlocked }) {
                // Trigger unlock celebration for this habit
                triggerEnhancedUnlockCelebration(unlockedHabit: unlockedHabit)
            }
        }
        
        // Check if all habits are now unlocked and trigger special all-complete confetti
        if !wasAllUnlocked && allHabitsUnlocked {
            // All habits have been unlocked - trigger special celebration
            triggerAllHabitsCompleteConfetti()
        }
    }
    
    private func triggerEnhancedUnlockCelebration(unlockedHabit: Habit) {
        // Set unlock toast message
        unlockToastMessage = "Unlocked: \(unlockedHabit.name)"
        
        // Generate encouraging celebration message for popup
        let messages = [
            "🎉 Amazing! You've unlocked the next habit!",
            "🔥 Incredible streak! The next habit awaits!",
            "⭐ Fantastic! You're building unstoppable momentum!",
            "💪 Way to go! Another habit unlocked!",
            "🚀 Outstanding! Keep climbing that ladder!"
        ]
        
        celebrationMessage = messages.randomElement() ?? "🎉 You've unlocked the next habit!"
        
        // Trigger all unlock animations
        withAnimation(.easeInOut(duration: 0.5)) {
            showConfetti = true
            showCelebrationPopup = true
            showUnlockToast = true
            showSparkleAnimation = true
        }
        
        // Hide confetti after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [self] in
            withAnimation(.easeOut(duration: 0.5)) {
                showConfetti = false
                showSparkleAnimation = false
            }
        }
        
        // Hide popup after user sees it
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [self] in
            withAnimation(.easeOut(duration: 0.3)) {
                showCelebrationPopup = false
            }
        }
        
        // Hide toast after shorter duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [self] in
            withAnimation(.easeOut(duration: 0.4)) {
                showUnlockToast = false
            }
        }
        
        // Clear animation reference after all animations complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [self] in
            unlockedHabitForAnimation = nil
        }
    }
    
    private func triggerHabitUnlockCelebration(unlockerHabit: Habit) {
        // Legacy method for backward compatibility - redirects to enhanced version
        if let unlockedHabit = habits.first(where: { $0.id == unlockedHabitForAnimation }) {
            triggerEnhancedUnlockCelebration(unlockedHabit: unlockedHabit)
        }
    }
    
    private func triggerAllHabitsCompleteConfetti() {
        celebrationMessage = "🏆 Incredible! You've mastered all habits!"
        
        withAnimation(.easeInOut(duration: 0.5)) {
            showConfetti = true
            showCelebrationPopup = true
        }
        
        // Hide confetti after longer animation for all complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [self] in
            withAnimation(.easeOut(duration: 0.5)) {
                showConfetti = false
            }
        }
        
        // Hide popup after user sees it
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) { [self] in
            withAnimation(.easeOut(duration: 0.3)) {
                showCelebrationPopup = false
            }
        }
    }
    
    private func triggerConfetti() {
        // Legacy function - now redirects to all habits complete
        triggerAllHabitsCompleteConfetti()
    }
    
    private func triggerMicroAffirmation() {
        // Select a random micro-affirmation message
        microAffirmationMessage = microAffirmations.randomElement() ?? "You're showing up. That's everything."
        
        // Show the micro-affirmation with animation
        withAnimation(.easeInOut(duration: 0.3)) {
            showMicroAffirmation = true
        }
        
        // Hide the micro-affirmation after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [self] in
            withAnimation(.easeOut(duration: 0.4)) {
                showMicroAffirmation = false
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
            print("📱 HabitManager: Habit '\(habits[index].name)' already completed today")
            return
        }
        
        // Add today's completion and update last checked date
        habits[index].completionDates.append(today)
        habits[index].lastCheckedDate = today
        
        // Update streak progress for immediate feedback
        let streakCount = habits[index].consecutiveStreakCount
        let hasThreeConsecutive = habits[index].hasThreeConsecutiveCompletions
        
        // Create calendar event for habit completion
        Task { @MainActor in
            CalendarManager.shared.createHabitCompletionEvent(
                habitName: habits[index].name,
                completionDate: today
            )
        }
        
        // Show micro-affirmation for completing the habit
        triggerMicroAffirmation()
        
        updateUnlockedStatus()
        
        // Immediate save after any data change
        saveHabits()
        saveUsageFlags()
        
        // Schedule notifications for next unlocked habit
        updateNotifications()
        
        print("📱 HabitManager: Saved habit completion for '\(habits[index].name)'")
    }
    
    func resetAllHabits() {
        guard !habits.isEmpty else { return }
        
        for i in 0..<habits.count {
            habits[i].completionDates.removeAll()
            habits[i].lastCheckedDate = nil
            habits[i].isUnlocked = (i == 0) // Only first habit remains unlocked
            habits[i].hasBeenCelebrated = false // Reset celebration flags
        }
        showConfetti = false
        showCelebrationPopup = false
        celebrationMessage = ""
        showMicroAffirmation = false
        microAffirmationMessage = ""
        lastUnlockedHabitId = nil
        
        // Reset enhanced unlock animation states
        showUnlockToast = false
        unlockToastMessage = ""
        unlockedHabitForAnimation = nil
        showSparkleAnimation = false
        
        // Immediate save after reset
        saveHabits()
        saveUsageFlags()
        
        // Update notifications after reset
        updateNotifications()
        
        print("📱 HabitManager: Reset all habits and saved data")
    }
    
    // MARK: - Premium Restriction Checks
    func canAddDefaultProfile(isPremium: Bool) -> Bool {
        return !hasUsedDefaultProfile || isPremium
    }
    
    func canAddCustomLadder(isPremium: Bool) -> Bool {
        return !hasUsedCustomLadder || isPremium
    }
    
    func getDefaultProfileLimitMessage() -> String {
        return "You can only have one default profile unless you upgrade to Premium. Upgrade to access unlimited default profiles."
    }
    
    func getCustomLadderLimitMessage() -> String {
        return "You can only create one custom ladder unless you upgrade to Premium. Upgrade to create unlimited custom ladders."
    }
    
    func getUserStatusSummary(isPremium: Bool) -> String {
        if isPremium {
            return "Premium: Unlimited profiles and custom ladders"
        } else {
            let profileUsed = hasUsedDefaultProfile ? "✓" : "○"
            let customUsed = hasUsedCustomLadder ? "✓" : "○"
            return "Free: \(profileUsed) Default Profile | \(customUsed) Custom Ladder"
        }
    }
    
    // MARK: - Custom Ladder Management
    func addCustomLadder(_ ladder: CustomHabitLadder) {
        customLadders.append(ladder)
        
        // Mark that user has used custom ladder
        hasUsedCustomLadder = true
        
        // Immediate save after adding custom ladder
        saveCustomLadders()
        saveUsageFlags()
        
        print("📱 HabitManager: Added and saved custom ladder '\(ladder.name)'")
    }
    
    func addCuratedLadder(_ curatedLadder: CuratedHabitLadder) {
        let customLadder = CustomHabitLadder(name: curatedLadder.name, habits: curatedLadder.habits)
        addCustomLadder(customLadder)
        print("📱 HabitManager: Added curated ladder '\(curatedLadder.name)' as custom ladder")
    }
    
    func updateCustomLadder(_ updatedLadder: CustomHabitLadder) {
        if let index = customLadders.firstIndex(where: { $0.id == updatedLadder.id }) {
            customLadders[index] = updatedLadder
            
            // If this is the active ladder, update it as well
            if activeCustomLadder?.id == updatedLadder.id {
                activeCustomLadder = updatedLadder
                saveActiveCustomLadder()
            }
            
            // Immediate save after updating custom ladder
            saveCustomLadders()
            
            print("📱 HabitManager: Updated and saved custom ladder '\(updatedLadder.name)'")
        }
    }
    
    func renameCustomLadder(_ ladder: CustomHabitLadder, to newName: String) {
        var updatedLadder = ladder
        updatedLadder.name = newName
        updateCustomLadder(updatedLadder)
    }
    
    func deleteCustomLadder(_ ladder: CustomHabitLadder) {
        customLadders.removeAll { $0.id == ladder.id }
        
        // If deleted ladder was active, switch back to default ladder
        if activeCustomLadder?.id == ladder.id {
            switchToDefaultLadder()
        }
        
        // Reset usage flags if user has no custom ladders left
        if customLadders.isEmpty {
            hasUsedCustomLadder = false
        }
        
        // Immediate save after deleting custom ladder
        saveCustomLadders()
        saveUsageFlags()
        
        print("📱 HabitManager: Deleted and saved changes for custom ladder '\(ladder.name)'")
    }
    
    func activateCustomLadder(_ ladder: CustomHabitLadder) {
        activeCustomLadder = ladder
        habits = ladder.habits
        updateUnlockedStatus()
        
        // Immediate save after activating custom ladder
        saveActiveCustomLadder()
        saveHabits()
        
        print("📱 HabitManager: Activated and saved custom ladder '\(ladder.name)'")
    }
    
    func switchToDefaultLadder() {
        activeCustomLadder = nil
        
        // Load the user's default ladder habits
        if let userDefaultLadder = defaultLadder {
            habits = userDefaultLadder.habits
            updateUnlockedStatus()
        } else {
            // If no default ladder is set, habits should be empty (user needs to select profile)
            habits = []
        }
        
        // Immediate save after switching to default ladder
        saveActiveCustomLadder()
        saveHabits()
        
        // Update notifications for the default ladder habits
        updateNotifications()
        
        print("📱 HabitManager: Switched to user's default ladder")
    }
    
    // MARK: - Profile Management
    func activateHabitProfile(_ profile: HabitProfile) {
        let profileLadder = CustomHabitLadder(
            name: profile.name,
            habits: profile.habits,
            emoji: profile.emoji
        )
        
        // Ensure all updates happen on main thread for immediate UI updates
        DispatchQueue.main.async {
            // Clean up any old profile-based ladders from custom ladders list
            self.cleanupProfileBasedCustomLadders()
            
            // Set this profile as the user's default ladder
            self.defaultLadder = profileLadder
            self.saveDefaultLadder()
            
            // Use this ladder's habits as current habits
            self.habits = profileLadder.habits
            self.updateUnlockedStatus()
            
            // Clear any active custom ladder since we're using the default now
            self.activeCustomLadder = nil
            self.saveActiveCustomLadder()
            
            // Mark that user has used default profile
            self.hasUsedDefaultProfile = true
            
            // Immediate save after activating profile
            self.saveUsageFlags()
            self.saveHabits()
            
print("📱 HabitManager: Set habit profile '\(profile.name)' as user's default ladder with \(self.habits.count) habits")
        }
        
        // Note: Profile ladders are NOT added to custom ladders - they remain as default only
    }
    
    private func cleanupProfileBasedCustomLadders() {
        // Get list of profile names that shouldn't be in custom ladders
        let profileNames = Set([
            "Basic Wellness", "Morning Starter", "Focus Essentials", "Sleep Hygiene",
            "Advanced Productivity", "Mental Resilience", "Physical Optimization", 
            "Creative Mastery", "Leadership Excellence"
        ])
        
        // Remove any custom ladders that match profile names
        customLadders.removeAll { profileNames.contains($0.name) }
        
        // Reset custom ladder usage flag if no genuine custom ladders remain
        if customLadders.isEmpty {
            hasUsedCustomLadder = false
        }
        
        // Save the cleaned up state
        saveCustomLadders()
        saveUsageFlags()
        
        print("📱 HabitManager: Cleaned up profile-based custom ladders")
    }
    
    // MARK: - Notification Integration
    private var premiumStatusCallback: (() -> Bool)?
    
    func setPremiumStatusCallback(_ callback: @escaping () -> Bool) {
        self.premiumStatusCallback = callback
    }
    
    private func updateNotifications() {
        let isPremium = premiumStatusCallback?() ?? false
        NotificationManager.shared.scheduleNotifications(for: habits, isPremiumUser: isPremium)
    }
    
    func scheduleNotifications(isPremiumUser: Bool) {
        NotificationManager.shared.scheduleNotifications(for: habits, isPremiumUser: isPremiumUser)
    }
    
    // MARK: - Testing Methods
    #if DEBUG
    /// For testing purposes only - manually trigger unlock animation
    func testUnlockAnimation(for habitId: UUID) {
        guard let habitIndex = habits.firstIndex(where: { $0.id == habitId }),
              let habit = habits.first(where: { $0.id == habitId }) else { return }
        
        // Mark as unlocked and not celebrated yet
        habits[habitIndex].isUnlocked = true
        habits[habitIndex].hasBeenCelebrated = false
        
        // Set animation state
        unlockedHabitForAnimation = habitId
        
        // Trigger celebration
        triggerEnhancedUnlockCelebration(unlockedHabit: habit)
    }
    #endif
} 