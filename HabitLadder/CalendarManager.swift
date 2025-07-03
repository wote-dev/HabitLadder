import Foundation
import EventKit
import SwiftUI

// MARK: - Calendar Manager
@MainActor
class CalendarManager: ObservableObject {
    @Published var isCalendarIntegrationEnabled: Bool = false
    @Published var calendarPermissionStatus: EKAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    @Published var lastSyncDate: Date?
    @Published var totalEventsCreated: Int = 0
    
    private let eventStore = EKEventStore()
    private let userDefaults = UserDefaults.standard
    private let calendarIntegrationKey = "CalendarIntegrationEnabled"
    private let lastSyncDateKey = "CalendarLastSyncDate"
    private let totalEventsCreatedKey = "CalendarTotalEventsCreated"
    private let habitLadderCalendarName = "HabitLadder"
    
    static let shared = CalendarManager()
    
    private init() {
        loadSettings()
        updatePermissionStatus()
        setupAutoSaving()
    }
    
    private func setupAutoSaving() {
        // Set up automatic saving when app goes to background
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.saveSettings()
                print("📱 CalendarManager: Auto-saved settings due to app backgrounding")
            }
        }
        
        // Set up automatic saving when app will terminate
        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.saveSettings()
                print("📱 CalendarManager: Auto-saved settings due to app termination")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Settings Management
    private func loadSettings() {
        isCalendarIntegrationEnabled = userDefaults.bool(forKey: calendarIntegrationKey)
        lastSyncDate = userDefaults.object(forKey: lastSyncDateKey) as? Date
        totalEventsCreated = userDefaults.integer(forKey: totalEventsCreatedKey)
    }
    
    private func saveSettings() {
        userDefaults.set(isCalendarIntegrationEnabled, forKey: calendarIntegrationKey)
        if let lastSyncDate = lastSyncDate {
            userDefaults.set(lastSyncDate, forKey: lastSyncDateKey)
        }
        userDefaults.set(totalEventsCreated, forKey: totalEventsCreatedKey)
    }
    
    // MARK: - Permission Management
    func updatePermissionStatus() {
        calendarPermissionStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    func requestCalendarAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            DispatchQueue.main.async {
                self.updatePermissionStatus()
            }
            return granted
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to request calendar access: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    // MARK: - Calendar Integration Toggle
    @MainActor
    func toggleCalendarIntegration(isPremiumUser: Bool, existingHabits: [Habit] = []) async {
        guard isPremiumUser else {
            errorMessage = "Calendar integration is available to Premium users only."
            return
        }
        
        if !isCalendarIntegrationEnabled {
            // User wants to enable integration
            let hasAccess = await requestCalendarAccess()
            if hasAccess {
                isCalendarIntegrationEnabled = true
                saveSettings()
                errorMessage = nil
                
                // Sync existing habit completions to calendar
                await syncExistingHabitsToCalendar(habits: existingHabits)
            } else {
                errorMessage = "Calendar access is required to enable integration."
            }
        } else {
            // User wants to disable integration
            isCalendarIntegrationEnabled = false
            saveSettings()
            errorMessage = nil
        }
    }
    
    // MARK: - Sync Existing Habits
    @MainActor
    private func syncExistingHabitsToCalendar(habits: [Habit]) async {
        guard isCalendarIntegrationEnabled,
              calendarPermissionStatus == .fullAccess else {
            return
        }
        
        var eventsCreated = 0
        for habit in habits {
            for completionDate in habit.completionDates {
                let initialCount = totalEventsCreated
                createHabitCompletionEvent(habitName: habit.name, completionDate: completionDate)
                if totalEventsCreated > initialCount {
                    eventsCreated += 1
                }
            }
        }
        
        if eventsCreated > 0 {
            lastSyncDate = Date()
            saveSettings()
        }
    }
    
    // MARK: - Calendar Management
    private func getOrCreateHabitLadderCalendar() -> EKCalendar? {
        // First, check if HabitLadder calendar already exists
        let calendars = eventStore.calendars(for: .event)
        if let existingCalendar = calendars.first(where: { $0.title == habitLadderCalendarName }) {
            return existingCalendar
        }
        
        // Create new HabitLadder calendar
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = habitLadderCalendarName
        newCalendar.cgColor = UIColor.systemGreen.cgColor
        
        // Set the calendar source (use local source if available)
        if let localSource = eventStore.sources.first(where: { $0.sourceType == .local }) {
            newCalendar.source = localSource
        } else if let defaultSource = eventStore.defaultCalendarForNewEvents?.source {
            newCalendar.source = defaultSource
        } else {
            return nil
        }
        
        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            return newCalendar
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to create HabitLadder calendar: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    // MARK: - Event Creation
    func createHabitCompletionEvent(habitName: String, completionDate: Date) {
        guard isCalendarIntegrationEnabled,
              calendarPermissionStatus == .fullAccess else {
            return
        }
        
        guard let habitLadderCalendar = getOrCreateHabitLadderCalendar() else {
            return
        }
        
        // Create event
        let event = EKEvent(eventStore: eventStore)
        event.title = "Completed: \(habitName)"
        event.notes = "Habit completed via HabitLadder app"
        event.calendar = habitLadderCalendar
        
        // Set the event to be an all-day event on the completion date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: completionDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        event.startDate = startOfDay
        event.endDate = endOfDay
        event.isAllDay = true
        
        // Check if an event with the same title already exists on this date
        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: [habitLadderCalendar]
        )
        
        let existingEvents = eventStore.events(matching: predicate)
        let eventAlreadyExists = existingEvents.contains { existingEvent in
            existingEvent.title == event.title && existingEvent.isAllDay
        }
        
        guard !eventAlreadyExists else {
            // Event already exists, don't create duplicate
            return
        }
        
        // Save the event
        do {
            try eventStore.save(event, span: .thisEvent)
            
            // Update stats
            DispatchQueue.main.async {
                self.totalEventsCreated += 1
                self.lastSyncDate = Date()
                self.saveSettings()
            }
            
            #if DEBUG
            print("✅ Created calendar event: \(event.title ?? "Unknown") on \(completionDate)")
            #endif
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to save habit completion event: \(error.localizedDescription)"
            }
            #if DEBUG
            print("❌ Failed to create calendar event: \(error.localizedDescription)")
            #endif
        }
    }
    
    // MARK: - Batch Event Creation
    func createEventsForHabitCompletions(habitName: String, completionDates: [Date]) {
        guard isCalendarIntegrationEnabled,
              calendarPermissionStatus == .fullAccess else {
            return
        }
        
        for date in completionDates {
            createHabitCompletionEvent(habitName: habitName, completionDate: date)
        }
    }
    
    // MARK: - Bulk Sync for Initial Setup
    @MainActor
    func syncAllHabitsToCalendar(habits: [Habit]) async {
        guard isCalendarIntegrationEnabled,
              calendarPermissionStatus == .fullAccess else {
            return
        }
        
        for habit in habits {
            for completionDate in habit.completionDates {
                createHabitCompletionEvent(habitName: habit.name, completionDate: completionDate)
            }
        }
    }
    
    // MARK: - Cleanup
    func removeAllHabitLadderEvents() {
        guard calendarPermissionStatus == .fullAccess else {
            return
        }
        
        let calendars = eventStore.calendars(for: .event)
        guard let habitLadderCalendar = calendars.first(where: { $0.title == habitLadderCalendarName }) else {
            return
        }
        
        // Get all events from HabitLadder calendar
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let oneYearFromNow = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        
        let predicate = eventStore.predicateForEvents(
            withStart: oneYearAgo,
            end: oneYearFromNow,
            calendars: [habitLadderCalendar]
        )
        
        let events = eventStore.events(matching: predicate)
        
        for event in events {
            do {
                try eventStore.remove(event, span: .thisEvent)
            } catch {
                print("Failed to remove event: \(error.localizedDescription)")
            }
        }
    }
} 