//
//  HabitLadderApp.swift
//  HabitLadder
//
//  Created by Daniel Zverev on 1/7/2025.
//

import SwiftUI

@main
struct HabitLadderApp: App {
    @StateObject private var storeManager = StoreManager()
    @StateObject private var habitManager = HabitManager()
    @State private var showSplash = true
    @State private var isContentReady = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content - pre-initialized but conditionally visible
                ContentView()
                    .environmentObject(storeManager)
                    .environmentObject(habitManager)
                    .opacity(showSplash ? 0 : 1)
                    .scaleEffect(showSplash ? 0.95 : 1.0)
                    .onAppear {
                        // Mark content as ready once ContentView has appeared
                        isContentReady = true
                    }
                
                // Optimized splash screen overlay
                if showSplash {
                    OptimizedSplashView()
                        .transition(.asymmetric(
                            insertion: .identity,
                            removal: .opacity.combined(with: .scale(scale: 1.05))
                        ))
                        .zIndex(1)
                }
            }
            .animation(.easeOut(duration: 0.35), value: showSplash)
            .onAppear {
                // Start splash sequence
                Task {
                    // Minimal delay to ensure smooth transition from launch screen
                    try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
                    
                    // Allow ContentView to initialize
                    await preloadCriticalResources()
                    
                    // Wait for ContentView to be ready
                    await waitForContentReady()
                    
                    // Short additional delay for smooth UX
                    try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                    
                    // Hide splash screen
                    await MainActor.run {
                        showSplash = false
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                // Save data when app goes to background
                saveAppData()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                // Save data when app is about to terminate
                saveAppData()
            }
            .preferredColorScheme(.none)
        }
    }
    
    @MainActor
    private func preloadCriticalResources() async {
        // Wait for HabitManager to finish loading data
        let startTime = Date()
        let timeout: TimeInterval = 2.0 // 2 second timeout
        
        while !habitManager.isDataLoaded && Date().timeIntervalSince(startTime) < timeout {
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        }
        
        // If data still isn't loaded after timeout, force reload
        if !habitManager.isDataLoaded {
            print("⚠️ HabitManager data loading timed out, forcing reload...")
            habitManager.loadData()
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        print("✅ HabitManager data loaded successfully")
    }
    
    private func waitForContentReady() async {
        // Wait until ContentView has appeared and is ready
        while !isContentReady {
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        }
    }
    
    private func saveAppData() {
        // This will be called when the app goes to background or terminates
        // The actual saving is handled by the individual managers through notifications
        print("📱 App saving data...")
    }
}

struct OptimizedSplashView: View {
    @State private var logoScale: CGFloat = 1.0
    @State private var logoOpacity: Double = 1.0
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background matching native launch screen exactly
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Logo - carefully sized to match launch screen expectations
                    Image("SplashIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: min(120, geometry.size.width * 0.3), 
                               height: min(120, geometry.size.width * 0.3))
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: min(24, geometry.size.width * 0.06)))
                        .overlay(
                            RoundedRectangle(cornerRadius: min(24, geometry.size.width * 0.06))
                                .stroke(Color("PrimaryColor").opacity(0.1), lineWidth: 1)
                        )
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .background(
                            // Subtle shadow for depth
                            RoundedRectangle(cornerRadius: min(24, geometry.size.width * 0.06))
                                .fill(Color.black.opacity(0.05))
                                .blur(radius: 8)
                                .offset(y: 4)
                        )
                    
                    Spacer()
                    
                    // Minimal progress indicator
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("PrimaryColor")))
                        .scaleEffect(0.8)
                        .padding(.bottom, max(60, geometry.safeAreaInsets.bottom + 40))
                }
            }
        }
        .onAppear {
            // Subtle breathing animation for engagement
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                logoScale = 1.02
            }
        }
    }
}
