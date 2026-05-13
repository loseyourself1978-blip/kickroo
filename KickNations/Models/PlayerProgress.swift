import Foundation

struct PlayerProgress: Codable, Equatable {
    var coins: Int
    var selectedNationID: NationID
    var unlockedNationIDs: Set<NationID>
    var matchesCompleted: Int
    var lastDailyRewardDate: Date?

    static let fresh = PlayerProgress(
        coins: 0,
        selectedNationID: .usa,
        unlockedNationIDs: Set(NationID.allCases),
        matchesCompleted: 0,
        lastDailyRewardDate: nil
    )
}

