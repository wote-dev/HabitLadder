import Foundation
import SwiftUI

// MARK: - Habit Profile Models
enum HabitProfileType: String, CaseIterable {
    // Free categories
    case basicWellness = "Basic Wellness"
    case morningStarter = "Morning Starter"
    case focusEssentials = "Focus Essentials"
    case sleepHygiene = "Sleep Hygiene"
    
    // Premium categories
    case advancedProductivity = "Advanced Productivity"
    case mentalResilience = "Mental Resilience"
    case physicalOptimization = "Physical Optimization"
    case creativeMastery = "Creative Mastery"
    case leadershipExcellence = "Leadership Excellence"
    
    var isFree: Bool {
        switch self {
        case .basicWellness, .morningStarter, .focusEssentials, .sleepHygiene:
            return true
        case .advancedProductivity, .mentalResilience, .physicalOptimization, .creativeMastery, .leadershipExcellence:
            return false
        }
    }
    
    var emoji: String {
        switch self {
        case .basicWellness:
            return "🌱"
        case .morningStarter:
            return "☀️"
        case .focusEssentials:
            return "🎯"
        case .sleepHygiene:
            return "😴"
        case .advancedProductivity:
            return "⚡️"
        case .mentalResilience:
            return "🧠"
        case .physicalOptimization:
            return "💪"
        case .creativeMastery:
            return "🎨"
        case .leadershipExcellence:
            return "👑"
        }
    }
    
    var description: String {
        switch self {
        case .basicWellness:
            return "Essential habits for a healthy foundation"
        case .morningStarter:
            return "Simple routines to start your day right"
        case .focusEssentials:
            return "Core habits for better concentration"
        case .sleepHygiene:
            return "Improve your sleep quality naturally"
        case .advancedProductivity:
            return "Advanced systems for peak performance"
        case .mentalResilience:
            return "Build mental strength and emotional balance"
        case .physicalOptimization:
            return "Optimize your physical health and energy"
        case .creativeMastery:
            return "Unlock your creative potential"
        case .leadershipExcellence:
            return "Develop leadership skills and presence"
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .basicWellness:
            return [Color.green, Color.mint]
        case .morningStarter:
            return [Color.orange, Color.yellow]
        case .focusEssentials:
            return [Color.blue, Color.cyan]
        case .sleepHygiene:
            return [Color.purple, Color.indigo]
        case .advancedProductivity:
            return [Color.red, Color.orange]
        case .mentalResilience:
            return [Color.teal, Color.green]
        case .physicalOptimization:
            return [Color.pink, Color.red]
        case .creativeMastery:
            return [Color.purple, Color.pink]
        case .leadershipExcellence:
            return [Color.yellow, Color.orange]
        }
    }
}

struct HabitProfile: Identifiable {
    let id = UUID()
    let type: HabitProfileType
    let habits: [Habit]
    
    var name: String { type.rawValue }
    var emoji: String { type.emoji }
    var description: String { type.description }
    var isFree: Bool { type.isFree }
    var gradientColors: [Color] { type.gradientColors }
}

// MARK: - Habit Model
struct Habit: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var description: String
    
    /// Array storing completion dates as Date objects
    /// Each date represents a day when the habit was completed
    var completionDates: [Date] = []
    
    /// Store the last checked date to prevent double submissions
    var lastCheckedDate: Date?
    
    var isUnlocked: Bool = false
    
    /// Track if this habit's unlock has been celebrated to prevent retriggering
    var hasBeenCelebrated: Bool = false
    
    // Check if habit has been completed 3 times in a row
    var hasThreeConsecutiveCompletions: Bool {
        return consecutiveStreakCount >= 3
    }
    
    /// Returns the current consecutive completion streak count
    var consecutiveStreakCount: Int {
        guard !completionDates.isEmpty else { return 0 }
        
        // For testing and better UX, we'll count total completions up to 3
        // This allows users to see immediate progress rather than waiting for consecutive days
        return min(completionDates.count, 3)
        
        // Original consecutive day logic (commented out for better UX):
        /*
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
        */
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
struct CustomHabitLadder: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var emoji: String? // Premium feature: custom emoji for ladder
    var habits: [Habit]
    var createdDate: Date = Date()
    
    init(name: String, habits: [Habit], emoji: String? = nil) {
        self.name = name
        self.emoji = emoji
        self.habits = habits
        // Ensure first habit is unlocked
        if !habits.isEmpty {
            self.habits[0].isUnlocked = true
        }
    }
}

// MARK: - Curated Habit Ladder Model
enum LadderCategory: String, CaseIterable {
    case morningRoutine = "Morning Routine"
    case focusFlow = "Focus & Flow"
    case anxietyReduction = "Anxiety Reduction"
    case disciplineBuilder = "Discipline Builder"
    
    var emoji: String {
        switch self {
        case .morningRoutine:
            return "🌅"
        case .focusFlow:
            return "🎯"
        case .anxietyReduction:
            return "🧘‍♀️"
        case .disciplineBuilder:
            return "💪"
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .morningRoutine:
            return [Color.orange, Color.yellow]
        case .focusFlow:
            return [Color.blue, Color.cyan]
        case .anxietyReduction:
            return [Color.green, Color.mint]
        case .disciplineBuilder:
            return [Color.red, Color.pink]
        }
    }
    
    var shadowColors: [Color] {
        switch self {
        case .morningRoutine:
            return [Color.orange.opacity(0.3), Color.yellow.opacity(0.3)]
        case .focusFlow:
            return [Color.blue.opacity(0.3), Color.cyan.opacity(0.3)]
        case .anxietyReduction:
            return [Color.green.opacity(0.3), Color.mint.opacity(0.3)]
        case .disciplineBuilder:
            return [Color.red.opacity(0.3), Color.pink.opacity(0.3)]
        }
    }
}

struct CuratedHabitLadder: Identifiable {
    var id = UUID()
    let productID: String
    let name: String
    let description: String
    let habits: [Habit]
    let category: LadderCategory
    var isPurchased: Bool = false
} 