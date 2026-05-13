import Foundation

enum GameMode: String, CaseIterable, Identifiable, Codable {
    case quickKick
    case dailyClash
    case roastReplay
    case partyMode

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .quickKick: "Quick Match"
        case .dailyClash: "Daily Rally"
        case .roastReplay: "Replay Lab"
        case .partyMode: "Pinball Rush"
        }
    }

    var symbolName: String {
        switch self {
        case .quickKick: "bolt.fill"
        case .dailyClash: "calendar"
        case .roastReplay: "film.stack"
        case .partyMode: "person.2.fill"
        }
    }

    var duration: TimeInterval {
        switch self {
        case .roastReplay: 30
        default: 45
        }
    }
}

struct MatchRules: Codable, Equatable {
    let duration: TimeInterval
    let goldenGoalDuration: TimeInterval
    let maxGoals: Int?
    let arenaID: ArenaID

    static func standard(arenaID: ArenaID, duration: TimeInterval = 30, maxGoals: Int? = nil) -> MatchRules {
        MatchRules(duration: duration, goldenGoalDuration: 10, maxGoals: maxGoals, arenaID: arenaID)
    }
}

struct MatchConfiguration: Identifiable, Codable, Equatable {
    let id: UUID
    let mode: GameMode
    let playerNationID: NationID
    let opponentNationID: NationID
    let arenaID: ArenaID
    let seed: UInt64
    let rules: MatchRules

    init(
        id: UUID = UUID(),
        mode: GameMode,
        playerNationID: NationID,
        opponentNationID: NationID,
        arenaID: ArenaID,
        seed: UInt64,
        rules: MatchRules
    ) {
        self.id = id
        self.mode = mode
        self.playerNationID = playerNationID
        self.opponentNationID = opponentNationID
        self.arenaID = arenaID
        self.seed = seed
        self.rules = rules
    }
}

enum MatchOutcome: String, Codable, Equatable {
    case win
    case loss
    case draw
}

struct MatchSnapshot: Equatable {
    var playerScore: Int
    var opponentScore: Int
    var remainingTime: TimeInterval
    var skillEnergy: Double
    var roarEnergy: Double
    var roarHeat: Double
    var combo: Int
    var maxCombo: Int
    var isOvertime: Bool
    var phaseName: String

    static let empty = MatchSnapshot(
        playerScore: 0,
        opponentScore: 0,
        remainingTime: 45,
        skillEnergy: 0,
        roarEnergy: 0,
        roarHeat: 0,
        combo: 0,
        maxCombo: 0,
        isOvertime: false,
        phaseName: "Kickoff"
    )
}

struct MatchResult: Identifiable, Equatable {
    let id = UUID()
    let configuration: MatchConfiguration
    let playerScore: Int
    let opponentScore: Int
    let duration: TimeInterval
    let headline: String
    let chaosScore: Int
    let maxCombo: Int
    let coinsEarned: Int

    var outcome: MatchOutcome {
        if playerScore > opponentScore { return .win }
        if playerScore < opponentScore { return .loss }
        return .draw
    }
}
