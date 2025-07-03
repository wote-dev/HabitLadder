import Foundation
import StoreKit
import ObjectiveC

// MARK: - Store Manager
class StoreManager: ObservableObject {
    @Published var curatedLadders: [CuratedHabitLadder] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isPremiumUser = false

    var products: [Product] = []
    private var taskHandle: Task<Void, Error>?

    // Product IDs - Only monthly premium subscription
    private let premiumSubscriptionID = "YOUR_BUNDLE_ID.premium.monthly"
    private let productIds = [
        "YOUR_BUNDLE_ID.premium.monthly"
    ]

    init() {
        curatedLadders = createCuratedLadders()
        taskHandle = listenForTransactions()
        
        Task {
            await retrieveProducts()
            await updatePurchaseStatus()
            
            #if DEBUG
            print("🔍 Available products: \(products.map { $0.id })")
            print("🔍 Product prices: \(products.map { "\($0.id): \($0.displayPrice)" })")
            #endif
        }
    }
    
    deinit {
        taskHandle?.cancel()
    }

    @MainActor
    func retrieveProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIds)
            self.products = storeProducts
            
            // All curated ladders are now included with premium subscription
            // No individual pricing needed
        } catch {
            print("Failed to retrieve products: \(error)")
        }
    }

    @MainActor
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchaseStatus()
            await transaction.finish()
            print("✅ Purchase successful: \(product.displayName)")
        case .userCancelled:
            print("❌ User cancelled purchase")
            throw PurchaseError.userCancelled
        case .pending:
            print("⏳ Purchase pending")
            throw PurchaseError.pending
        @unknown default:
            throw PurchaseError.unknown
        }
    }

    @MainActor
    func updatePurchaseStatus() async {
        // Check premium subscription status (monthly only)
        if let premiumProduct = products.first(where: { $0.id == premiumSubscriptionID }) {
            isPremiumUser = (try? await isPurchased(premiumProduct)) ?? false
        } else {
            isPremiumUser = false
        }
        
        // If user has premium, all curated ladders are considered "purchased"
        if isPremiumUser {
            for index in curatedLadders.indices {
                curatedLadders[index].isPurchased = true
            }
        } else {
            for index in curatedLadders.indices {
                curatedLadders[index].isPurchased = false
            }
        }
    }
    
    // Function to get premium subscription product
    func getPremiumProduct() -> Product? {
        return products.first(where: { $0.id == premiumSubscriptionID })
    }
    
    func isPurchased(_ product: Product) async throws -> Bool {
        guard let state = await product.currentEntitlement else {
            return false
        }

        switch state {
        case .verified(let transaction):
            return transaction.revocationDate == nil
        case .unverified:
            return false
        }
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchaseStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw VerificationError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Custom Errors
enum VerificationError: Error {
    case failedVerification
}

enum PurchaseError: Error, LocalizedError {
    case userCancelled
    case pending
    case unknown
    case noProductFound
    
    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Purchase was cancelled"
        case .pending:
            return "Purchase is pending approval"
        case .unknown:
            return "An unknown error occurred"
        case .noProductFound:
            return "Product not found"
        }
    }
}

// MARK: - Curated Ladders Definition
extension StoreManager {
    func createCuratedLadders() -> [CuratedHabitLadder] {
        return [
            CuratedHabitLadder(
                productID: "", // No individual product ID needed - all included with premium
                name: "Morning Routine",
                description: "Start your day with purpose and energy.",
                habits: [
                    Habit(name: "Drink a glass of water", description: "Hydrate your body after sleep."),
                    Habit(name: "Stretch for 5 minutes", description: "Wake up your muscles."),
                    Habit(name: "Plan your day", description: "Set your top 3 priorities."),
                    Habit(name: "Eat a healthy breakfast", description: "Fuel your body for the day."),
                    Habit(name: "Avoid phone for 30 mins", description: "Start your day with focus.")
                ],
                category: .morningRoutine
            ),
            CuratedHabitLadder(
                productID: "", // No individual product ID needed - all included with premium
                name: "Focus & Flow",
                description: "Enhance your concentration and productivity.",
                habits: [
                    Habit(name: "Work in 45-min blocks", description: "Use a timer to stay on task."),
                    Habit(name: "Take a 5-min break", description: "Rest your mind between focus blocks."),
                    Habit(name: "Disable notifications", description: "Minimize distractions."),
                    Habit(name: "Listen to focus music", description: "Create a productive environment."),
                    Habit(name: "Review your work", description: "Check your progress at the end.")
                ],
                category: .focusFlow
            ),
            CuratedHabitLadder(
                productID: "", // No individual product ID needed - all included with premium
                name: "Anxiety Reduction",
                description: "Find calm and reduce stress in your daily life.",
                habits: [
                    Habit(name: "Meditate for 10 minutes", description: "Practice mindfulness."),
                    Habit(name: "Journal your thoughts", description: "Write down what's on your mind."),
                    Habit(name: "Practice deep breathing", description: "Take 5 deep breaths."),
                    Habit(name: "Go for a walk in nature", description: "Connect with the outdoors."),
                    Habit(name: "Limit caffeine intake", description: "Avoid overstimulation.")
                ],
                category: .anxietyReduction
            ),
            CuratedHabitLadder(
                productID: "", // No individual product ID needed - all included with premium
                name: "Discipline Builder",
                description: "Strengthen your self-control and willpower.",
                habits: [
                    Habit(name: "Make your bed", description: "Start your day with a small win."),
                    Habit(name: "Do one difficult task first", description: "Tackle your most important work."),
                    Habit(name: "No snoozing", description: "Wake up at your first alarm."),
                    Habit(name: "Track your progress", description: "Review your habits daily."),
                    Habit(name: "Plan tomorrow tonight", description: "Prepare for a successful day.")
                ],
                category: .disciplineBuilder
            )
        ]
    }
}

extension CuratedHabitLadder {
    var price: String? {
        get {
            return _price
        }
        set {
            _price = newValue
        }
    }
    
    private static var _priceKey: UInt8 = 0
    
    private var _price: String? {
        get {
            return objc_getAssociatedObject(self, &Self._priceKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &Self._priceKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
} 