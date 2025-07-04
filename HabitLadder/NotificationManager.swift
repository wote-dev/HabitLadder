import Foundation
import UserNotifications
import SwiftUI

// MARK: - Notification Manager
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isNotificationsEnabled = false
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    
    private let userDefaults = UserDefaults.standard
    private let notificationsEnabledKey = "notificationsEnabled"
    private let defaultReminderTimeKey = "defaultReminderTime"
    
    // Default reminder time: 8:00 AM
    var defaultReminderTime: Date {
        get {
            if let data = userDefaults.data(forKey: defaultReminderTimeKey),
               let date = try? JSONDecoder().decode(Date.self, from: data) {
                return date
            } else {
                // Default to 8:00 AM today
                let calendar = Calendar.current
                let components = DateComponents(hour: 8, minute: 0)
                return calendar.date(from: components) ?? Date()
            }
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                userDefaults.set(encoded, forKey: defaultReminderTimeKey)
            }
        }
    }
    
    override init() {
        super.init()
        loadSettings()
        requestPermission()
        setupAutoSaving()
        
        // Set up delegate to handle notifications
        UNUserNotificationCenter.current().delegate = self
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
                print("📱 NotificationManager: Auto-saved settings due to app backgrounding")
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
                print("📱 NotificationManager: Auto-saved settings due to app termination")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func loadSettings() {
        isNotificationsEnabled = userDefaults.bool(forKey: notificationsEnabledKey)
    }
    
    func saveSettings() {
        userDefaults.set(isNotificationsEnabled, forKey: notificationsEnabledKey)
    }
    
    // MARK: - Permission Management
    func requestPermission() {
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                await MainActor.run {
                    Task {
                        await self.checkPermissionStatus()
                    }
                }
            } catch {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func checkPermissionStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            self.notificationPermissionStatus = settings.authorizationStatus
            
            // If permission was denied, disable notifications
            if settings.authorizationStatus == .denied {
                self.isNotificationsEnabled = false
                self.saveSettings()
            }
        }
    }
    
    // MARK: - Notification Scheduling
    func scheduleNotifications(for habits: [Habit], isPremiumUser: Bool) {
        guard isNotificationsEnabled && isPremiumUser else {
            cancelAllNotifications()
            return
        }
        
        // Find the next unlocked habit that isn't completed today
        guard let nextHabit = habits.first(where: { $0.isUnlocked && !$0.isCompletedToday }) else {
            // No habits to remind about
            cancelAllNotifications()
            return
        }
        
        // Cancel existing notifications
        cancelAllNotifications()
        
        // Get reminder time for this habit (or use default)
        let reminderTime = getReminderTime(for: nextHabit.id)
        
        // Schedule notification for tomorrow if it's past today's reminder time
        let calendar = Calendar.current
        let now = Date()
        var scheduleDate = calendar.dateBySettingTime(reminderTime, to: now)
        
        // If the time has already passed today, schedule for tomorrow
        if scheduleDate <= now {
            scheduleDate = calendar.date(byAdding: .day, value: 1, to: scheduleDate) ?? scheduleDate
        }
        
        scheduleNotification(for: nextHabit, at: scheduleDate)
    }
    
    private func scheduleNotification(for habit: Habit, at date: Date) {
        Task {
            let content = UNMutableNotificationContent()
            content.title = "Time for your next habit! 🎯"
            content.body = "Ready to complete: \(habit.name)"
            content.sound = .default
            content.badge = 1
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: "habit_reminder_\(habit.id.uuidString)",
                content: content,
                trigger: trigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        // Reset badge count using iOS 17+ API
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().setBadgeCount(0) { error in
                if let error = error {
                    print("Failed to reset badge count: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Individual Habit Reminder Times
    func getReminderTime(for habitId: UUID) -> Date {
        let key = "reminderTime_\(habitId.uuidString)"
        if let data = userDefaults.data(forKey: key),
           let date = try? JSONDecoder().decode(Date.self, from: data) {
            return date
        }
        return defaultReminderTime
    }
    
    func setReminderTime(_ time: Date, for habitId: UUID) {
        let key = "reminderTime_\(habitId.uuidString)"
        if let encoded = try? JSONEncoder().encode(time) {
            userDefaults.set(encoded, forKey: key)
        }
    }
    
    func removeReminderTime(for habitId: UUID) {
        let key = "reminderTime_\(habitId.uuidString)"
        userDefaults.removeObject(forKey: key)
    }
    
    // MARK: - Premium Status Management
    func handlePremiumStatusChange(isPremium: Bool, habits: [Habit]) {
        if !isPremium {
            // User lost premium access - cancel all notifications
            isNotificationsEnabled = false
            saveSettings()
            cancelAllNotifications()
        } else {
            // User gained premium access - reschedule if enabled
            if isNotificationsEnabled {
                scheduleNotifications(for: habits, isPremiumUser: true)
            }
        }
    }
    
    // MARK: - Settings Management
    func toggleNotifications(for habits: [Habit], isPremiumUser: Bool) {
        isNotificationsEnabled.toggle()
        saveSettings()
        
        if isNotificationsEnabled && isPremiumUser {
            scheduleNotifications(for: habits, isPremiumUser: true)
        } else {
            cancelAllNotifications()
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .badge, .sound])
    }
}

// MARK: - Calendar Extension
extension Calendar {
    func dateBySettingTime(_ time: Date, to date: Date) -> Date {
        let timeComponents = dateComponents([.hour, .minute], from: time)
        let dateComponents = dateComponents([.year, .month, .day], from: date)
        
        var newComponents = DateComponents()
        newComponents.year = dateComponents.year
        newComponents.month = dateComponents.month
        newComponents.day = dateComponents.day
        newComponents.hour = timeComponents.hour
        newComponents.minute = timeComponents.minute
        
        return self.date(from: newComponents) ?? date
    }
}