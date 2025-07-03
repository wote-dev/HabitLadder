import SwiftUI
import StoreKit

struct CuratedLaddersView: View {
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var habitManager: HabitManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingLimitAlert = false
    @State private var showingPremiumPaywall = false
    @State private var limitMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Premium status banner
                    if !storeManager.isPremiumUser {
                        PremiumBannerView(showingPremiumPaywall: $showingPremiumPaywall)
                    }
                    
                    ForEach(storeManager.curatedLadders) { ladder in
                        CuratedLadderRow(ladder: ladder, showingPremiumPaywall: $showingPremiumPaywall)
                    }
                    
                    // Footer at bottom of scrollable content
                    AppFooter()
                }
                .padding()
            }
            .navigationTitle("Curated Ladders")
            .background(LinearGradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)], startPoint: .top, endPoint: .bottom))
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .sheet(isPresented: $showingPremiumPaywall) {
                PremiumPaywallView()
            }
        }
    }
}

struct PremiumBannerView: View {
    @Binding var showingPremiumPaywall: Bool
    
    var body: some View {
        Button(action: {
            showingPremiumPaywall = true
        }) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)
                    Text("Unlock All Ladders")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                Text("Get unlimited access to all curated ladders, premium profiles, and features for just $2.99/month")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Spacer()
                    Text("Upgrade to Premium")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .padding(20)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct CuratedLadderRow: View {
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var habitManager: HabitManager
    @Environment(\.dismiss) private var dismiss
    let ladder: CuratedHabitLadder
    @Binding var showingPremiumPaywall: Bool
    @State private var showingLimitAlert = false
    
    private func handleCardTap() {
        if storeManager.isPremiumUser {
            if habitManager.canAddCustomLadder(isPremium: storeManager.isPremiumUser) {
                habitManager.addCuratedLadder(ladder)
                dismiss()
            } else {
                showingLimitAlert = true
            }
        } else {
            // Show premium paywall instead of individual purchase
            showingPremiumPaywall = true
        }
    }
    
    var body: some View {
        Button(action: handleCardTap) {
            VStack {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(ladder.category.emoji)
                            .font(.title)
                        Text(ladder.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                        
                        // Premium badge for non-premium users
                        if !storeManager.isPremiumUser {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)
                        }
                    }
                    
                    Text(ladder.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider().background(Color.gray.opacity(0.3))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(ladder.habits) { habit in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                Text(habit.name)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .padding(20)
                
                Spacer()
                
                HStack {
                    Spacer()
                    if storeManager.isPremiumUser {
                        Text("Use Ladder")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: ladder.category.gradientColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    } else {
                        Text("Premium Required")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
                .padding([.horizontal, .bottom], 20)
            }
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: ladder.category.gradientColors + [ladder.category.gradientColors[0]],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: ladder.category.shadowColors[0], radius: 15, x: -5, y: -5)
        .shadow(color: ladder.category.shadowColors[1], radius: 15, x: 5, y: 5)
        .shadow(color: ladder.category.shadowColors[0].opacity(0.2), radius: 25, x: 0, y: 0)
        .shadow(color: ladder.category.shadowColors[1].opacity(0.2), radius: 25, x: 0, y: 0)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            ladder.category.gradientColors[0].opacity(0.6),
                            ladder.category.gradientColors[1].opacity(0.6),
                            ladder.category.gradientColors[0].opacity(0.4),
                            ladder.category.gradientColors[1].opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .blur(radius: 1)
        )
        .alert("Upgrade to Premium", isPresented: $showingLimitAlert) {
            Button("Upgrade") {
                showingPremiumPaywall = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(habitManager.getCustomLadderLimitMessage())
        }
    }
}

struct PremiumPaywallView: View {
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Unlock Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Get unlimited access to all features")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Features
                    VStack(spacing: 20) {
                        FeatureRow(icon: "ladder", title: "All Curated Ladders", description: "Access every expertly designed habit ladder")
                        FeatureRow(icon: "person.crop.circle.badge.plus", title: "Premium Profiles", description: "Unlock advanced productivity and wellness profiles")
                        FeatureRow(icon: "calendar.badge.plus", title: "Calendar Integration", description: "Sync your habits with your calendar")
                        FeatureRow(icon: "bell.badge", title: "Smart Notifications", description: "Personalized reminders to keep you on track")
                        FeatureRow(icon: "infinity", title: "Unlimited Ladders", description: "Create as many custom ladders as you want")
                    }
                    .padding(.horizontal)
                    
                    // Pricing
                    VStack(spacing: 16) {
                        Text("$2.99/month")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Cancel anytime")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
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
                        .cornerRadius(12)
                        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal)
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Terms of Service • Privacy Policy")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Text("Subscription automatically renews unless cancelled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Close") {
                    dismiss()
                }
            )
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

