import SwiftUI
import UserNotifications

struct SettingsView: View {
    @ObservedObject var storeManager: StoreManager
    @ObservedObject var habitManager: HabitManager
    @ObservedObject var notificationManager = NotificationManager.shared
    @ObservedObject var calendarManager = CalendarManager.shared
    
    @State private var showingNotificationPermissionAlert = false
    @State private var showingPremiumUpgradeAlert = false
    @State private var showingPremiumUpgradeSheet = false
    @State private var selectedHabitForCustomTime: Habit?
    @State private var showingCalendarPermissionAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Premium Status Section
                    premiumStatusSection
                    
                    // Notifications Section
                    if storeManager.isPremiumUser {
                        notificationsSection
                        
                        // Individual Habit Reminders Section
                        if notificationManager.isNotificationsEnabled {
                            habitRemindersSection
                        }
                    } else {
                        // Non-premium notification section
                        premiumNotificationSection
                    }
                    
                    // Calendar Integration Section
                    if storeManager.isPremiumUser {
                        calendarIntegrationSection
                    } else {
                        premiumCalendarSection
                    }
                    
                    // General Settings Section
                    generalSettingsSection
                    
                    // About Section
                    aboutSection
                }
                .padding()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            notificationManager.checkPermissionStatus()
            calendarManager.updatePermissionStatus()
        }
        .alert("Notification Permission Required", isPresented: $showingNotificationPermissionAlert) {
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To enable reminders, please allow notifications in your device settings.")
        }
        .alert("Premium Feature", isPresented: $showingPremiumUpgradeAlert) {
            Button("Upgrade to Premium") {
                showingPremiumUpgradeSheet = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Daily reminders are available to Premium users only. Upgrade to unlock this feature and get personalized habit notifications.")
        }
        .alert("Calendar Permission Required", isPresented: $showingCalendarPermissionAlert) {
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To enable calendar integration, please allow calendar access in your device settings.")
        }
        .sheet(isPresented: $showingPremiumUpgradeSheet) {
            PremiumUpgradeView(storeManager: storeManager)
        }
        .sheet(item: $selectedHabitForCustomTime) { habit in
            HabitReminderTimeView(
                habit: habit,
                notificationManager: notificationManager,
                onTimeChanged: {
                    notificationManager.scheduleNotifications(for: habitManager.habits, isPremiumUser: storeManager.isPremiumUser)
                }
            )
        }
    }
    
    private var premiumStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Account", icon: "person.circle.fill")
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Premium Status")
                            .font(.headline)
                            .foregroundColor(HabitTheme.primaryText)
                        
                        Text(storeManager.isPremiumUser ? "Premium Active" : "Free Plan")
                            .font(.subheadline)
                            .foregroundColor(storeManager.isPremiumUser ? .green : HabitTheme.secondaryText)
                    }
                    
                    Spacer()
                    
                    if storeManager.isPremiumUser {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    } else {
                        Button("Upgrade") {
                            showingPremiumUpgradeSheet = true
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue)
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(HabitTheme.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Daily Reminders", icon: "bell.fill")
            
            VStack(spacing: 16) {
                // Main notification toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enable Reminders")
                            .font(.headline)
                            .foregroundColor(HabitTheme.primaryText)
                        
                        Text("Get notified to complete your next unlocked habit")
                            .font(.caption)
                            .foregroundColor(HabitTheme.secondaryText)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { notificationManager.isNotificationsEnabled },
                        set: { newValue in
                            handleNotificationToggle(newValue)
                        }
                    ))
                    .labelsHidden()
                }
                
                // Default reminder time
                if notificationManager.isNotificationsEnabled {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Default Reminder Time")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(HabitTheme.primaryText)
                            Spacer()
                        }
                        
                        DatePicker(
                            "Default Time",
                            selection: Binding(
                                get: { notificationManager.defaultReminderTime },
                                set: { newTime in
                                    notificationManager.defaultReminderTime = newTime
                                    notificationManager.scheduleNotifications(for: habitManager.habits, isPremiumUser: storeManager.isPremiumUser)
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }
                    .padding(.top, 8)
                }
                
                // Permission status indicator
                if notificationManager.notificationPermissionStatus == .denied {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        
                        Text("Notification permission denied. Tap to open Settings.")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Spacer()
                    }
                    .onTapGesture {
                        showingNotificationPermissionAlert = true
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(HabitTheme.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
    
    private var habitRemindersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Custom Reminder Times", icon: "clock.fill")
            
            VStack(spacing: 12) {
                Text("Set different reminder times for each habit")
                    .font(.caption)
                    .foregroundColor(HabitTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(habitManager.habits.filter { $0.isUnlocked }) { habit in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(habit.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(HabitTheme.primaryText)
                                .lineLimit(1)
                            
                            let reminderTime = notificationManager.getReminderTime(for: habit.id)
                            Text(timeFormatter.string(from: reminderTime))
                                .font(.caption)
                                .foregroundColor(HabitTheme.secondaryText)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            selectedHabitForCustomTime = habit
                        }) {
                            Text("Change")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    if habit.id != habitManager.habits.filter({ $0.isUnlocked }).last?.id {
                        Divider()
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(HabitTheme.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
    
    private var calendarIntegrationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Calendar Integration", icon: "calendar.badge.plus")
            
            VStack(spacing: 16) {
                // Main calendar integration toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calendar Sync")
                            .font(.headline)
                            .foregroundColor(HabitTheme.primaryText)
                        
                        Text("Add completed habits to your calendar")
                            .font(.caption)
                            .foregroundColor(HabitTheme.secondaryText)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { calendarManager.isCalendarIntegrationEnabled },
                        set: { newValue in
                            Task {
                                await calendarManager.toggleCalendarIntegration(
                                    isPremiumUser: storeManager.isPremiumUser,
                                    existingHabits: habitManager.habits
                                )
                            }
                        }
                    ))
                    .labelsHidden()
                }
                
                // Permission status and explanation
                if calendarManager.isCalendarIntegrationEnabled {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            Text("Creates events in \"HabitLadder\" calendar")
                                .font(.caption)
                                .foregroundColor(HabitTheme.secondaryText)
                        }
                        
                        // Sync status information
                        if calendarManager.totalEventsCreated > 0 {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                
                                Text("\(calendarManager.totalEventsCreated) events created")
                                    .font(.caption)
                                    .foregroundColor(HabitTheme.secondaryText)
                                
                                if let lastSync = calendarManager.lastSyncDate {
                                    Text("• Last: \(timeFormatter.string(from: lastSync))")
                                        .font(.caption2)
                                        .foregroundColor(HabitTheme.tertiaryText)
                                }
                            }
                        }
                        
                        // Manual sync button for existing completions
                        Button(action: {
                            Task {
                                await calendarManager.syncAllHabitsToCalendar(habits: habitManager.habits)
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(.caption)
                                Text("Sync Past Completions")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        if calendarManager.calendarPermissionStatus == .denied {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                
                                Text("Calendar permission denied. Tap to open Settings.")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                
                                Spacer()
                            }
                            .onTapGesture {
                                showingCalendarPermissionAlert = true
                            }
                        }
                    }
                }
                
                // Error message display
                if let errorMessage = calendarManager.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(HabitTheme.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
    
    private var premiumCalendarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Calendar Integration", icon: "calendar.badge.plus")
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Premium Feature")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(HabitTheme.primaryText)
                        
                        Text("Automatically add completed habits to your calendar. Creates events in a dedicated \"HabitLadder\" calendar for easy tracking.")
                            .font(.subheadline)
                            .foregroundColor(HabitTheme.secondaryText)
                    }
                    
                    Spacer()
                }
                
                Button("Upgrade to Premium") {
                    showingPremiumUpgradeSheet = true
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(HabitTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.orange.opacity(0.3), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
    
    private var generalSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "General", icon: "gear.circle.fill")
            
            VStack(spacing: 0) {
                SettingsRow(
                    title: "Reset All Habits",
                    subtitle: "Clear all progress and start over",
                    icon: "arrow.clockwise.circle.fill",
                    iconColor: .red,
                    action: {
                        habitManager.resetAllHabits()
                        notificationManager.scheduleNotifications(for: habitManager.habits, isPremiumUser: storeManager.isPremiumUser)
                    }
                )
                
                Divider()
                    .padding(.horizontal)
                
                SettingsRow(
                    title: "Privacy Policy",
                    subtitle: "View our privacy policy",
                    icon: "lock.shield.fill",
                    iconColor: .blue,
                    action: {
                        // TODO: Open privacy policy
                    }
                )
                
                Divider()
                    .padding(.horizontal)
                
                SettingsRow(
                    title: "Terms of Service",
                    subtitle: "View terms and conditions",
                    icon: "doc.text.fill",
                    iconColor: .blue,
                    action: {
                        // TODO: Open terms of service
                    }
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(HabitTheme.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
    
    private var premiumNotificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Daily Reminders", icon: "bell.fill")
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Premium Feature")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(HabitTheme.primaryText)
                        
                        Text("Get daily reminders to complete your next unlocked habit. Customize reminder times for each habit individually.")
                            .font(.subheadline)
                            .foregroundColor(HabitTheme.secondaryText)
                    }
                    
                    Spacer()
                }
                
                Button("Upgrade to Premium") {
                    showingPremiumUpgradeSheet = true
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(HabitTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.orange.opacity(0.3), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "About", icon: "info.circle.fill")
            
            VStack(spacing: 16) {
                HStack {
                    Text("Version")
                        .font(.subheadline)
                        .foregroundColor(HabitTheme.primaryText)
                    
                    Spacer()
                    
                    Text("1.0.0")
                        .font(.subheadline)
                        .foregroundColor(HabitTheme.secondaryText)
                }
                
                HStack {
                    Text("Build your habits, one step at a time")
                        .font(.caption)
                        .foregroundColor(HabitTheme.secondaryText)
                    
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(HabitTheme.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
    
    private func handleNotificationToggle(_ newValue: Bool) {
        if newValue && !storeManager.isPremiumUser {
            showingPremiumUpgradeAlert = true
            return
        }
        
        if newValue && notificationManager.notificationPermissionStatus == .denied {
            showingNotificationPermissionAlert = true
            return
        }
        
        if newValue && notificationManager.notificationPermissionStatus == .notDetermined {
            notificationManager.requestPermission()
        }
        
        notificationManager.toggleNotifications(for: habitManager.habits, isPremiumUser: storeManager.isPremiumUser)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(HabitTheme.primaryText)
            
            Spacer()
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title3)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(HabitTheme.primaryText)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(HabitTheme.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(HabitTheme.tertiaryText)
                    .font(.caption)
            }
            .padding()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Habit Reminder Time View
struct HabitReminderTimeView: View {
    let habit: Habit
    let notificationManager: NotificationManager
    let onTimeChanged: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTime: Date
    @State private var useCustomTime: Bool
    
    init(habit: Habit, notificationManager: NotificationManager, onTimeChanged: @escaping () -> Void) {
        self.habit = habit
        self.notificationManager = notificationManager
        self.onTimeChanged = onTimeChanged
        
        let savedTime = notificationManager.getReminderTime(for: habit.id)
        let defaultTime = notificationManager.defaultReminderTime
        
        self._selectedTime = State(initialValue: savedTime)
        self._useCustomTime = State(initialValue: !Calendar.current.isDate(savedTime, equalTo: defaultTime, toGranularity: .minute))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Top navigation
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("Set Reminder")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveReminderTime()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
                .padding()
                
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reminder Time")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(HabitTheme.primaryText)
                            
                            Text(habit.name)
                                .font(.subheadline)
                                .foregroundColor(HabitTheme.secondaryText)
                        }
                        
                        Spacer()
                    }
                    
                    Toggle("Use custom time for this habit", isOn: $useCustomTime)
                        .font(.subheadline)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(HabitTheme.cardBackground)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
                
                if useCustomTime {
                    VStack(spacing: 16) {
                        Text("Choose reminder time")
                            .font(.headline)
                            .foregroundColor(HabitTheme.primaryText)
                        
                        DatePicker(
                            "Reminder Time",
                            selection: $selectedTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(HabitTheme.cardBackground)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                } else {
                    VStack(spacing: 8) {
                        Text("Using default reminder time")
                            .font(.headline)
                            .foregroundColor(HabitTheme.primaryText)
                        
                        Text(timeFormatter.string(from: notificationManager.defaultReminderTime))
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(HabitTheme.cardBackground)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private func saveReminderTime() {
        if useCustomTime {
            notificationManager.setReminderTime(selectedTime, for: habit.id)
        } else {
            notificationManager.removeReminderTime(for: habit.id)
        }
        onTimeChanged()
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - Premium Upgrade View
struct PremiumUpgradeView: View {
    @ObservedObject var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var selectedPlan: PremiumPlan = .monthly
    
    enum PremiumPlan: CaseIterable {
        case monthly
        case yearly
        
        var title: String {
            switch self {
            case .monthly: return "Monthly"
            case .yearly: return "Yearly"
            }
        }
        
        var price: String {
            switch self {
            case .monthly: return "$4.99/month"
            case .yearly: return "$39.99/year"
            }
        }
        
        var savings: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "Save 33%"
            }
        }
        
        var productID: String {
            switch self {
            case .monthly: return "YOUR_BUNDLE_ID.premium.monthly"
            case .yearly: return "YOUR_BUNDLE_ID.premium.yearly"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Features List
                    featuresSection
                    
                    // Pricing Plans
                    pricingSection
                    
                    // Subscribe Button
                    subscribeSection
                    
                    // Footer
                    footerSection
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Premium Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Upgrade to Premium")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(HabitTheme.primaryText)
                
                Text("Unlock the full potential of HabitLadder")
                    .font(.subheadline)
                    .foregroundColor(HabitTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 30)
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    private var featuresSection: some View {
        VStack(spacing: 20) {
            Text("Premium Features")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(HabitTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                                 PremiumFeatureRow(
                     icon: "bell.fill",
                     iconColor: .orange,
                     title: "Smart Daily Reminders",
                     description: "Get personalized notifications to complete your next unlocked habit at the perfect time."
                 )
                 
                 PremiumFeatureRow(
                     icon: "clock.fill",
                     iconColor: .blue,
                     title: "Custom Reminder Times",
                     description: "Set different reminder times for each habit to fit your unique schedule."
                 )
                 
                 PremiumFeatureRow(
                     icon: "star.fill",
                     iconColor: .yellow,
                     title: "Premium Habit Profiles",
                     description: "Access Advanced Productivity, Mental Resilience, Physical Optimization, Creative Mastery, and Leadership Excellence profiles."
                 )
                 
                 PremiumFeatureRow(
                     icon: "chart.line.uptrend.xyaxis",
                     iconColor: .green,
                     title: "Advanced Analytics",
                     description: "Get detailed insights into your habit completion patterns and streak statistics."
                 )
                 
                 PremiumFeatureRow(
                     icon: "paintbrush.fill",
                     iconColor: .purple,
                     title: "Custom Ladder Emojis",
                     description: "Personalize your custom habit ladders with unique emojis and themes."
                 )
                 
                 PremiumFeatureRow(
                     icon: "icloud.fill",
                     iconColor: .cyan,
                     title: "Cloud Sync",
                     description: "Sync your habits and progress across all your devices seamlessly."
                 )
                 
                 PremiumFeatureRow(
                     icon: "infinity",
                     iconColor: .pink,
                     title: "Unlimited Custom Ladders",
                     description: "Create as many custom habit ladders as you want without any limits."
                 )
                 
                 PremiumFeatureRow(
                     icon: "heart.fill",
                     iconColor: .red,
                     title: "Priority Support",
                     description: "Get faster customer support and direct access to new features."
                 )
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 40)
    }
    
    private var pricingSection: some View {
        VStack(spacing: 20) {
            Text("Choose Your Plan")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(HabitTheme.primaryText)
            
            VStack(spacing: 12) {
                ForEach(PremiumPlan.allCases, id: \.self) { plan in
                    PricingCard(
                        plan: plan,
                        isSelected: selectedPlan == plan,
                        onTap: { selectedPlan = plan }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 30)
    }
    
    private var subscribeSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task {
                    await subscribeToPremium()
                }
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: "crown.fill")
                            .font(.headline)
                    }
                    
                    Text(isLoading ? "Processing..." : "Start Premium")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .disabled(isLoading)
            .padding(.horizontal, 20)
            
            Text("Cancel anytime. No commitment.")
                .font(.caption)
                .foregroundColor(HabitTheme.secondaryText)
        }
        .padding(.bottom, 20)
    }
    
    private var footerSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 20) {
                Button("Terms of Service") {
                    // TODO: Open terms
                }
                .font(.caption)
                .foregroundColor(.blue)
                
                Button("Privacy Policy") {
                    // TODO: Open privacy
                }
                .font(.caption)
                .foregroundColor(.blue)
                
                Button("Restore Purchases") {
                    Task {
                        await restorePurchases()
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            Text("Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.")
                .font(.caption2)
                .foregroundColor(HabitTheme.tertiaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .padding(.bottom, 30)
    }
    
    private func subscribeToPremium() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let product = storeManager.products.first(where: { $0.id == selectedPlan.productID }) {
                try await storeManager.purchase(product)
                dismiss()
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }
    
    private func restorePurchases() async {
        await storeManager.updatePurchaseStatus()
    }
}

// MARK: - Premium Feature Row
struct PremiumFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(HabitTheme.primaryText)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(HabitTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(HabitTheme.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Pricing Card
struct PricingCard: View {
    let plan: PremiumUpgradeView.PremiumPlan
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(HabitTheme.primaryText)
                        
                        if let savings = plan.savings {
                            Text(savings)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                    
                    Text(plan.price)
                        .font(.subheadline)
                        .foregroundColor(HabitTheme.secondaryText)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(HabitTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView(
        storeManager: StoreManager(),
        habitManager: HabitManager()
    )
} 