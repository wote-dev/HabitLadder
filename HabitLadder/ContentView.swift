//
//  ContentView.swift
//  HabitLadder
//
//  Created by Daniel Zverev on 1/7/2025.
//

import SwiftUI
import Foundation

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
    
    private let userDefaults = UserDefaults.standard
    private let habitsKey = "SavedHabits"
    private let customLaddersKey = "CustomHabitLadders"
    private let activeCustomLadderKey = "ActiveCustomLadder"
    
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
        // First habit is always unlocked
        if !habits.isEmpty {
            habits[0].isUnlocked = true
        }
        
        // Unlock subsequent habits based on previous completions
        for i in 1..<habits.count {
            habits[i].isUnlocked = habits[i-1].isEligibleToUnlockNext
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
                        .textFieldStyle(.roundedBorder)
                    
                    Text("Create 3-7 habits in the order you want to build them")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemGray6))
                
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
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Habit")
                                }
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
                
                // Save button
                Button(action: saveCustomLadder) {
                    Text("Create Ladder")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSave ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!canSave)
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
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
            VStack(spacing: 20) {
                TextField("Habit Name", text: $habitName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Description", text: $habitDescription, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: onSave)
                        .disabled(!canSave)
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
            VStack(spacing: 20) {
                TextField("Habit Name", text: $habitName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Description", text: $habitDescription, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        var updatedHabit = habit
                        updatedHabit.name = habitName
                        updatedHabit.description = habitDescription
                        onSave(updatedHabit)
                    }
                    .disabled(!canSave)
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(habitManager.activeCustomLadder?.name ?? "HabitLadder")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(habitManager.activeCustomLadder != nil ? "Custom ladder" : "Build habits step by step")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
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
                            Image(systemName: "ellipsis.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Habits List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(habitManager.habits.enumerated()), id: \.element.id) { index, habit in
                            HabitRow(
                                habit: habit,
                                index: index,
                                onToggle: { habitManager.toggleHabitCompletion(for: habit.id) },
                                habits: habitManager.habits
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
                    .background(Color.red)
                    .cornerRadius(12)
                }
                .padding()
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
                habitManager.resetAllHabits()
            }
        } message: {
            Text("This will reset all habit progress. Are you sure?")
        }
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
    
    private var cardBackgroundColor: Color {
        if habit.isUnlocked {
            return habit.isCompletedToday ? 
                Color.green.opacity(0.08) : 
                Color.blue.opacity(0.05)
        } else {
            return Color.gray.opacity(0.03)
        }
    }
    
    private var cardBorderColor: Color {
        if habit.isUnlocked {
            return habit.isCompletedToday ? 
                Color.green.opacity(0.3) : 
                Color.blue.opacity(0.2)
        } else {
            return Color.gray.opacity(0.2)
        }
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
                        .foregroundColor(habit.isUnlocked ? .primary : .secondary)
                        .multilineTextAlignment(.leading)
                    
                    // Description
                    Text(habit.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Lock icon for locked habits
                if !habit.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            
            // Progress indicator section
            VStack(spacing: 12) {
                // Progress circles
                HStack(spacing: 12) {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(
                                    habit.isUnlocked && i < habit.consecutiveStreakCount ? 
                                    Color.green : 
                                    Color.gray.opacity(0.3)
                                )
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            habit.isUnlocked && i < habit.consecutiveStreakCount ? 
                                            Color.green.opacity(0.3) : 
                                            Color.gray.opacity(0.5), 
                                            lineWidth: 1
                                        )
                                )
                                .scaleEffect(habit.isUnlocked && i < habit.consecutiveStreakCount ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: habit.consecutiveStreakCount)
                        }
                    }
                    
                    Text("\(habit.isUnlocked ? habit.consecutiveStreakCount : 0)/3")
                        .font(.caption)
                        .foregroundColor(habit.hasThreeConsecutiveCompletions ? .green : .secondary)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
                
                // Status and unlock information
                HStack {
                    if habit.isUnlocked {
                        if habit.isCompletedToday {
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
                        
                        Text("Total: \(habit.totalCompletionDays)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    } else {
                        VStack(alignment: .leading, spacing: 2) {
                            if index > 0 {
                                let previousHabit = habits[index - 1]
                                Text("Complete '\(previousHabit.name)' 3 days in a row")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .italic()
                                Text("(\(previousHabit.consecutiveStreakCount)/3 days completed)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .italic()
                            } else {
                                Text("Complete previous habit to unlock")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
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
                    Button(action: onToggle) {
                        HStack(spacing: 8) {
                            Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundColor(habit.isCompletedToday ? .green : .blue)
                            
                            Text(habit.isCompletedToday ? "Completed" : "Mark Complete")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(habit.isCompletedToday ? .green : .blue)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    habit.isCompletedToday ? 
                                    Color.green.opacity(0.1) : 
                                    Color.blue.opacity(0.1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            habit.isCompletedToday ? 
                                            Color.green.opacity(0.3) : 
                                            Color.blue.opacity(0.3), 
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .disabled(habit.isCompletedToday)
                    .scaleEffect(habit.isCompletedToday ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: habit.isCompletedToday)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.circle")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Locked")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(cardBorderColor, lineWidth: 1)
                )
                .shadow(
                    color: habit.isUnlocked ? 
                        Color.black.opacity(0.08) : 
                        Color.black.opacity(0.04), 
                    radius: habit.isUnlocked ? 8 : 4, 
                    x: 0, 
                    y: habit.isUnlocked ? 4 : 2
                )
        )
        .scaleEffect(habit.isUnlocked ? 1.0 : 0.98)
        .animation(.easeInOut(duration: 0.3), value: habit.isUnlocked)
    }
}

#Preview {
    ContentView()
}
