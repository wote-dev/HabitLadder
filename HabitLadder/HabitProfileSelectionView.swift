import SwiftUI

struct HabitProfileSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var habitManager: HabitManager
    @State private var selectedProfile: HabitProfile?
    @State private var showingPaywall = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingLimitAlert = false
    @State private var limitAlertMessage = ""
    
    let onProfileSelected: (HabitProfile) -> Void
    let onDismiss: (() -> Void)?
    
    init(onProfileSelected: @escaping (HabitProfile) -> Void, onDismiss: (() -> Void)? = nil) {
        self.onProfileSelected = onProfileSelected
        self.onDismiss = onDismiss
    }
    
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
    
    private let premiumProfiles: [HabitProfile] = [
        HabitProfile(type: .advancedProductivity, habits: [
            Habit(name: "Review weekly goals", description: "Align daily actions with bigger picture"),
            Habit(name: "Time-block your calendar", description: "Protect your most important work"),
            Habit(name: "Batch similar tasks", description: "Maximize efficiency"),
            Habit(name: "Practice saying no", description: "Protect your priorities"),
            Habit(name: "Conduct weekly review", description: "Continuous improvement mindset")
        ]),
        HabitProfile(type: .mentalResilience, habits: [
            Habit(name: "Practice mindfulness meditation", description: "Build present-moment awareness"),
            Habit(name: "Journal your emotions", description: "Process and understand feelings"),
            Habit(name: "Challenge negative thoughts", description: "Develop cognitive flexibility"),
            Habit(name: "Practice loving-kindness", description: "Cultivate compassion"),
            Habit(name: "Reflect on growth", description: "Acknowledge your progress")
        ]),
        HabitProfile(type: .physicalOptimization, habits: [
            Habit(name: "Track your heart rate variability", description: "Monitor recovery"),
            Habit(name: "Do mobility work", description: "Maintain joint health"),
            Habit(name: "Optimize your nutrition timing", description: "Fuel performance"),
            Habit(name: "Practice breath work", description: "Enhance oxygen delivery"),
            Habit(name: "Plan active recovery", description: "Smart rest and regeneration")
        ]),
        HabitProfile(type: .creativeMastery, habits: [
            Habit(name: "Morning pages", description: "Stream-of-consciousness writing"),
            Habit(name: "Collect inspiration", description: "Gather ideas from the world"),
            Habit(name: "Practice your craft", description: "Deliberate skill development"),
            Habit(name: "Seek feedback", description: "Accelerate improvement"),
            Habit(name: "Share your work", description: "Build courage and connection")
        ]),
        HabitProfile(type: .leadershipExcellence, habits: [
            Habit(name: "Listen actively in conversations", description: "Develop others"),
            Habit(name: "Give meaningful recognition", description: "Appreciate contributions"),
            Habit(name: "Reflect on decisions", description: "Improve judgment"),
            Habit(name: "Seek diverse perspectives", description: "Expand your worldview"),
            Habit(name: "Practice vulnerability", description: "Build authentic connections")
        ])
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        HabitTheme.backgroundPrimary,
                        HabitTheme.backgroundSecondary
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Text("Choose Your Path")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(HabitTheme.primaryText)
                            
                            Text("Start with a curated set of habits designed for your lifestyle")
                                .font(.body)
                                .foregroundColor(HabitTheme.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Free Profiles Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Free Profiles")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(HabitTheme.primaryText)
                                
                                Spacer()
                                
                                if !habitManager.canAddDefaultProfile(isPremium: storeManager.isPremiumUser) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                        Text("Limit Reached")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.orange)
                                    }
                                } else {
                                    Image(systemName: "gift.fill")
                                        .foregroundColor(.green)
                                        .font(.title3)
                                }
                            }
                            .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 16) {
                                ForEach(freeProfiles) { profile in
                                    ProfileCard(
                                        profile: profile,
                                        isSelected: selectedProfile?.id == profile.id,
                                        isLocked: !habitManager.canAddDefaultProfile(isPremium: storeManager.isPremiumUser),
                                        onTap: {
                                            if habitManager.canAddDefaultProfile(isPremium: storeManager.isPremiumUser) {
                                                selectedProfile = profile
                                            } else {
                                                limitAlertMessage = habitManager.getDefaultProfileLimitMessage()
                                                showingLimitAlert = true
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Premium Profiles Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Premium Profiles")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(HabitTheme.primaryText)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title3)
                                    
                                    if !storeManager.isPremiumUser {
                                        Text("Unlock")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 16) {
                                ForEach(premiumProfiles) { profile in
                                    ProfileCard(
                                        profile: profile,
                                        isSelected: selectedProfile?.id == profile.id,
                                        isPremium: true,
                                        isLocked: !storeManager.isPremiumUser,
                                        onTap: {
                                            if storeManager.isPremiumUser {
                                                selectedProfile = profile
                                            } else {
                                                showingPaywall = true
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Continue Button
                        if let profile = selectedProfile {
                            Button(action: {
                                onProfileSelected(profile)
                            }) {
                                HStack {
                                    Text("Start with \(profile.name)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: profile.gradientColors,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(
                                    color: profile.gradientColors.first?.opacity(0.3) ?? .clear,
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 32)
                        }
                        
                        // Footer at bottom of scrollable content
                        AppFooter()
                    }
                }
            }
            .navigationTitle("Choose Your Path")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        if let onDismiss = onDismiss {
                            onDismiss()
                        } else {
                            dismiss()
                        }
                    }
                }
            }
        }
                    .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Upgrade to Premium", isPresented: $showingLimitAlert) {
            Button("Upgrade") {
                showingPaywall = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(limitAlertMessage)
        }
    }
}

struct ProfileCard: View {
    let profile: HabitProfile
    let isSelected: Bool
    var isPremium: Bool = false
    var isLocked: Bool = false
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Header with emoji and lock icon
                HStack {
                    Text(profile.emoji)
                        .font(.title)
                    
                    Spacer()
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(isPremium ? .yellow : .orange)
                    } else if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.green)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(profile.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(HabitTheme.primaryText)
                        .multilineTextAlignment(.leading)
                    
                    Text(profile.description)
                        .font(.caption)
                        .foregroundColor(HabitTheme.secondaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Habits preview
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(profile.habits.prefix(3).enumerated()), id: \.offset) { index, habit in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(HabitTheme.inactive)
                                .frame(width: 4, height: 4)
                            
                            Text(habit.name)
                                .font(.caption2)
                                .foregroundColor(HabitTheme.secondaryText)
                                .lineLimit(1)
                        }
                    }
                    
                    if profile.habits.count > 3 {
                        Text("+ \(profile.habits.count - 3) more habits")
                            .font(.caption2)
                            .foregroundColor(HabitTheme.accent)
                            .padding(.leading, 10)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(HabitTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? 
                                LinearGradient(colors: profile.gradientColors, startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [HabitTheme.inactive.opacity(0.3)], startPoint: .leading, endPoint: .trailing),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? 
                        (profile.gradientColors.first?.opacity(0.2) ?? .clear) : 
                        .black.opacity(0.05),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
            )
            .opacity(isLocked ? 0.7 : 1.0)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeManager: StoreManager
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Unlock Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Get unlimited access to all premium features and content")
                            .font(.body)
                            .foregroundColor(HabitTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "person.crop.circle.badge.plus", title: "Premium Profiles", description: "Access advanced productivity and wellness profiles")
                        FeatureRow(icon: "ladder", title: "All Curated Ladders", description: "Unlock every expertly designed habit ladder")
                        FeatureRow(icon: "calendar.badge.plus", title: "Calendar Integration", description: "Sync your habits with your calendar")
                        FeatureRow(icon: "bell.badge", title: "Smart Notifications", description: "Personalized reminders to keep you on track")
                        FeatureRow(icon: "infinity", title: "Unlimited Ladders", description: "Create as many custom ladders as you want")
                    }
                    .padding(.horizontal)
                    
                    // Pricing
                    VStack(spacing: 8) {
                        Text("$2.99/month")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Cancel anytime")
                            .font(.subheadline)
                            .foregroundColor(HabitTheme.secondaryText)
                    }
                    
                    Spacer()
                    
                    // Subscribe Button
                    Button(action: subscribeToPremium) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
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
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal)
                    
                    Text("Subscription automatically renews unless cancelled")
                        .font(.caption)
                        .foregroundColor(HabitTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Later") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func subscribeToPremium() {
        guard let premiumProduct = storeManager.getPremiumProduct() else {
            return
        }
        
        Task {
            isLoading = true
            
            do {
                try await storeManager.purchase(premiumProduct)
                dismiss()
            } catch {
                storeManager.errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(HabitTheme.secondaryText)
            }
            
            Spacer()
        }
    }
}

#Preview {
    HabitProfileSelectionView(
        onProfileSelected: { profile in
            print("Selected profile: \(profile.name)")
        },
        onDismiss: {
            print("Dismissed without selection")
        }
    )
    .environmentObject(StoreManager())
    .environmentObject(HabitManager())
}