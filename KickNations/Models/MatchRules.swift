import Foundation

enum GameMode: String, CaseIterable, Identifiable, Codable {
    case globalCup

    var id: String { rawValue }

    var displayName: String {
        "Global Cup 48"
    }

    var symbolName: String {
        "globe.americas.fill"
    }

    var duration: TimeInterval {
        50
    }

    var shortRule: String {
        "12 groups, 32-team bracket"
    }
}

struct MatchRules: Codable, Equatable {
    let duration: TimeInterval
    let goldenGoalDuration: TimeInterval
    let maxGoals: Int?
    let arenaID: ArenaID
    let allowsDraw: Bool
    let requiresWinner: Bool
    let blockerCount: Int
    let movingBlockerCount: Int
    let reboundMultiplier: Double
    let launchPowerMultiplier: Double
    let opponentCadence: TimeInterval
    let phaseLabel: String?

    static func standard(
        arenaID: ArenaID,
        duration: TimeInterval = 30,
        maxGoals: Int? = nil,
        allowsDraw: Bool = false,
        requiresWinner: Bool = false,
        blockerCount: Int = 8,
        movingBlockerCount: Int = 2,
        reboundMultiplier: Double = 1,
        launchPowerMultiplier: Double = 1,
        opponentCadence: TimeInterval = 0.9,
        phaseLabel: String? = nil
    ) -> MatchRules {
        MatchRules(
            duration: duration,
            goldenGoalDuration: requiresWinner ? 60 : 10,
            maxGoals: maxGoals,
            arenaID: arenaID,
            allowsDraw: allowsDraw,
            requiresWinner: requiresWinner,
            blockerCount: blockerCount,
            movingBlockerCount: movingBlockerCount,
            reboundMultiplier: reboundMultiplier,
            launchPowerMultiplier: launchPowerMultiplier,
            opponentCadence: opponentCadence,
            phaseLabel: phaseLabel
        )
    }

    static func globalCup(arenaID: ArenaID, context: GlobalCupContext) -> MatchRules {
        let step: Int = context.difficultyStep
        let blockerCount: Int = min(14, 7 + step)
        let movingBlockerCount: Int = min(blockerCount - 2, 2 + step)
        let reboundMultiplier: Double = 1.28 + Double(step) * 0.035
        let launchPowerMultiplier: Double = 2.02 + Double(step) * 0.075
        let opponentCadence: TimeInterval = max(0.58, 1.12 - Double(step) * 0.065)

        return MatchRules.standard(
            arenaID: arenaID,
            duration: GameMode.globalCup.duration,
            allowsDraw: !context.stage.isKnockout,
            requiresWinner: context.stage.isKnockout,
            blockerCount: blockerCount,
            movingBlockerCount: movingBlockerCount,
            reboundMultiplier: reboundMultiplier,
            launchPowerMultiplier: launchPowerMultiplier,
            opponentCadence: opponentCadence,
            phaseLabel: context.stage.displayName
        )
    }

    static func cupPractice(arenaID: ArenaID) -> MatchRules {
        return MatchRules.standard(
            arenaID: arenaID,
            duration: 60,
            allowsDraw: true,
            blockerCount: 6,
            movingBlockerCount: 2,
            reboundMultiplier: 1.24,
            launchPowerMultiplier: 1.95,
            opponentCadence: 1.18,
            phaseLabel: "Practice First Match"
        )
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
    let cupContext: GlobalCupContext?
    let isPractice: Bool

    init(
        id: UUID = UUID(),
        mode: GameMode,
        playerNationID: NationID,
        opponentNationID: NationID,
        arenaID: ArenaID,
        seed: UInt64,
        rules: MatchRules,
        cupContext: GlobalCupContext? = nil,
        isPractice: Bool = false
    ) {
        self.id = id
        self.mode = mode
        self.playerNationID = playerNationID
        self.opponentNationID = opponentNationID
        self.arenaID = arenaID
        self.seed = seed
        self.rules = rules
        self.cupContext = cupContext
        self.isPractice = isPractice
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
    var phaseDetail: String

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
        phaseName: "Kickoff",
        phaseDetail: "Swipe a player"
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
