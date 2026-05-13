import SwiftUI

@main
struct KickNationsApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var persistence = PersistenceService()
    @StateObject private var purchaseService = PurchaseService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environmentObject(persistence)
                .environmentObject(purchaseService)
                .preferredColorScheme(.dark)
        }
    }
}

