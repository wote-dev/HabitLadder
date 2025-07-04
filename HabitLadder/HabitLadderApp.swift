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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeManager)
                .environmentObject(habitManager)
                .onAppear {
                    // Ensure HabitManager loads data on app start
                    if !habitManager.isDataLoaded {
                        habitManager.loadData()
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .windowResizability(.contentSize)
    }
    
    private func saveAppData() {
        // This will be called when the app goes to background or terminates
        // The actual saving is handled by the individual managers through notifications
        print("📱 App saving data...")
    }
}
