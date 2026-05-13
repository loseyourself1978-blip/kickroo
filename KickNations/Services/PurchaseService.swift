import Combine
import Foundation
import StoreKit

struct StoreProduct: Identifiable, Equatable {
    let id: String
    let displayName: String
    let summary: String
    let price: String
    let symbolName: String
}

@MainActor
final class PurchaseService: ObservableObject {
    static let removeAdsID = "com.kicknations.removeads"
    static let starterPackID = "com.kicknations.starternationpack"
    static let replayStudioID = "com.kicknations.replaystudio"
    static let tournamentBundleID = "com.kicknations.tournamentbundle"

    @Published private(set) var products: [StoreProduct] = [
        StoreProduct(id: removeAdsID, displayName: "Remove Ads", summary: "Interstitials off, rewarded ads optional", price: "$4.99", symbolName: "nosign"),
        StoreProduct(id: starterPackID, displayName: "Starter Nation Pack", summary: "Launch skins, trails, and expressions", price: "$2.99", symbolName: "sparkles"),
        StoreProduct(id: replayStudioID, displayName: "Replay Studio", summary: "Premium frames and headlines", price: "$2.99", symbolName: "film"),
        StoreProduct(id: tournamentBundleID, displayName: "Tournament Bundle", summary: "Ads, nation pack, replay studio", price: "$9.99", symbolName: "shippingbox.fill")
    ]

    @Published private(set) var purchasedProductIDs = Set<String>()

    func refreshProducts() async {
        _ = try? await Product.products(for: products.map(\.id))
    }
}

