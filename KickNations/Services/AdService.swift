import Foundation

struct AdReward {
    let coins: Int
}

final class AdService {
    func loadRewardedAd() async {
    }

    func grantMockReward() -> AdReward {
        AdReward(coins: 100)
    }
}

