import SwiftUI

struct StoreView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var purchaseService: PurchaseService

    var body: some View {
        ZStack {
            Color.knBackground.ignoresSafeArea()

            VStack(spacing: 18) {
                HStack {
                    Button {
                        router.showHome()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.bold))
                            .frame(width: 42, height: 42)
                    }
                    .buttonStyle(.bordered)
                    .tint(.white.opacity(0.25))

                    Text("Store")
                        .font(.title.weight(.black))
                    Spacer()
                }
                .foregroundStyle(.white)

                VStack(spacing: 12) {
                    ForEach(purchaseService.products) { product in
                        StoreProductRow(product: product)
                    }
                }

                Spacer()

                Text("Purchases use StoreKit 2 product ids and are ready for sandbox wiring.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.52))
                    .multilineTextAlignment(.center)
            }
            .padding(20)
        }
    }
}

private struct StoreProductRow: View {
    let product: StoreProduct

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: product.symbolName)
                .font(.title3.weight(.bold))
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(product.displayName)
                    .font(.headline.weight(.black))
                Text(product.summary)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.58))
            }

            Spacer()

            Text(product.price)
                .font(.headline.weight(.black))
                .foregroundStyle(Color.knGold)
        }
        .foregroundStyle(.white)
        .padding(14)
        .background(Color.knPanel, in: RoundedRectangle(cornerRadius: 8))
    }
}
