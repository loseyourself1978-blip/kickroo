import Foundation

enum CupStage: String, Codable, Equatable, CaseIterable {
    case groupStage
    case roundOf32
    case roundOf16
    case quarterFinal
    case semiFinal
    case final
    case champion
    case eliminated

    var displayName: String {
        switch self {
        case .groupStage: "Group Stage"
        case .roundOf32: "Round of 32"
        case .roundOf16: "Round of 16"
        case .quarterFinal: "Quarter Final"
        case .semiFinal: "Semi Final"
        case .final: "Final"
        case .champion: "Champion"
        case .eliminated: "Eliminated"
        }
    }

    var isKnockout: Bool {
        switch self {
        case .roundOf32, .roundOf16, .quarterFinal, .semiFinal, .final:
            true
        case .groupStage, .champion, .eliminated:
            false
        }
    }

    var nextKnockoutStage: CupStage? {
        switch self {
        case .roundOf32: .roundOf16
        case .roundOf16: .quarterFinal
        case .quarterFinal: .semiFinal
        case .semiFinal: .final
        case .final: .champion
        case .groupStage, .champion, .eliminated: nil
        }
    }

    static let knockoutOrder: [CupStage] = [.roundOf32, .roundOf16, .quarterFinal, .semiFinal, .final]
}

struct GlobalCupContext: Codable, Equatable {
    let stage: CupStage
    let groupID: String?
    let matchNumber: Int
    let standingSummary: String

    var hudTitle: String {
        stage == .groupStage ? "Global Cup 48" : stage.displayName
    }

    var hudDetail: String {
        if stage == .groupStage, let groupID {
            return "Group \(groupID)  Match \(matchNumber)/3"
        }
        return stage.isKnockout ? "Win or go home" : standingSummary
    }

    var difficultyStep: Int {
        switch stage {
        case .groupStage:
            return max(0, min(2, matchNumber - 1))
        case .roundOf32:
            return 3
        case .roundOf16:
            return 4
        case .quarterFinal:
            return 5
        case .semiFinal:
            return 6
        case .final:
            return 7
        case .champion, .eliminated:
            return 7
        }
    }
}

struct CupStanding: Codable, Equatable, Identifiable {
    let nationID: NationID
    var played: Int
    var wins: Int
    var draws: Int
    var losses: Int
    var goalsFor: Int
    var goalsAgainst: Int
    var points: Int

    var id: NationID { nationID }
    var goalDifference: Int { goalsFor - goalsAgainst }

    init(nationID: NationID) {
        self.nationID = nationID
        self.played = 0
        self.wins = 0
        self.draws = 0
        self.losses = 0
        self.goalsFor = 0
        self.goalsAgainst = 0
        self.points = 0
    }

    mutating func record(goalsFor: Int, goalsAgainst: Int) {
        played += 1
        self.goalsFor += goalsFor
        self.goalsAgainst += goalsAgainst

        if goalsFor > goalsAgainst {
            wins += 1
            points += 3
        } else if goalsFor == goalsAgainst {
            draws += 1
            points += 1
        } else {
            losses += 1
        }
    }
}

enum GlobalCupRules {
    static let groupLabels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"]

    static func makeGroups(seed: UInt64 = 0x20260514, teams: [NationID] = NationID.allCases) -> [[NationID]] {
        var pool = Array(teams.prefix(48))
        var generator = SeededRandomGenerator(seed: seed)

        if pool.count > 1 {
            for index in stride(from: pool.count - 1, through: 1, by: -1) {
                let swapIndex = Int(generator.next() % UInt64(index + 1))
                pool.swapAt(index, swapIndex)
            }
        }

        return stride(from: 0, to: pool.count, by: 4).map { start in
            Array(pool[start..<min(start + 4, pool.count)])
        }
    }

    static func rankedStandings(_ standings: [CupStanding]) -> [CupStanding] {
        standings.sorted { lhs, rhs in
            if lhs.points != rhs.points { return lhs.points > rhs.points }
            if lhs.goalDifference != rhs.goalDifference { return lhs.goalDifference > rhs.goalDifference }
            if lhs.goalsFor != rhs.goalsFor { return lhs.goalsFor > rhs.goalsFor }
            return NationLibrary.nation(for: lhs.nationID).shortCode < NationLibrary.nation(for: rhs.nationID).shortCode
        }
    }

    static func standingSummary(_ standings: [CupStanding]) -> String {
        rankedStandings(standings)
            .prefix(4)
            .map { standing in
                "\(NationLibrary.nation(for: standing.nationID).shortCode) \(standing.points)pt \(standing.goalDifference >= 0 ? "+" : "")\(standing.goalDifference)"
            }
            .joined(separator: "  ")
    }

    static func knockoutOpponents(playerNationID: NationID, seed: UInt64) -> [NationID] {
        var candidates = NationID.allCases.filter { $0 != playerNationID }
        var generator = SeededRandomGenerator(seed: seed ^ 0xC0FFEE)

        if candidates.count > 1 {
            for index in stride(from: candidates.count - 1, through: 1, by: -1) {
                let swapIndex = Int(generator.next() % UInt64(index + 1))
                candidates.swapAt(index, swapIndex)
            }
        }

        return Array(candidates.prefix(CupStage.knockoutOrder.count))
    }

    static func simulatedScore(seed: UInt64, round: Int) -> (Int, Int) {
        var generator = SeededRandomGenerator(seed: seed ^ UInt64(round + 1) &* 0x9E3779B97F4A7C15)
        let home = Int(generator.next() % 4)
        let away = Int(generator.next() % 4)
        return (home, away)
    }
}

struct GlobalCupCampaign: Codable, Equatable, Identifiable {
    let id: UUID
    let playerNationID: NationID
    let seed: UInt64
    let groupID: String
    let groupTeams: [NationID]
    var standings: [CupStanding]
    var groupMatchIndex: Int
    var stage: CupStage
    var knockoutOpponents: [NationID]
    var lastSummary: String

    var isComplete: Bool {
        stage == .champion || stage == .eliminated
    }

    var canContinue: Bool {
        !isComplete && currentOpponentID != nil
    }

    var currentOpponentID: NationID? {
        switch stage {
        case .groupStage:
            let opponents = groupTeams.filter { $0 != playerNationID }
            guard opponents.indices.contains(groupMatchIndex) else { return nil }
            return opponents[groupMatchIndex]
        case .roundOf32, .roundOf16, .quarterFinal, .semiFinal, .final:
            guard let stageIndex = CupStage.knockoutOrder.firstIndex(of: stage),
                  knockoutOpponents.indices.contains(stageIndex) else { return nil }
            return knockoutOpponents[stageIndex]
        case .champion, .eliminated:
            return nil
        }
    }

    var context: GlobalCupContext {
        GlobalCupContext(
            stage: stage,
            groupID: stage == .groupStage ? groupID : nil,
            matchNumber: min(3, groupMatchIndex + 1),
            standingSummary: GlobalCupRules.standingSummary(standings)
        )
    }

    static func start(playerNationID: NationID, seed: UInt64 = UInt64.random(in: 1...UInt64.max)) -> GlobalCupCampaign {
        let groups = GlobalCupRules.makeGroups(seed: seed)
        let located = groups.enumerated().first { $0.element.contains(playerNationID) }
        let groupIndex = located?.offset ?? 0
        let groupTeams = located?.element ?? Array(NationID.allCases.prefix(4))
        let standings = groupTeams.map(CupStanding.init(nationID:))

        return GlobalCupCampaign(
            id: UUID(),
            playerNationID: playerNationID,
            seed: seed,
            groupID: GlobalCupRules.groupLabels[groupIndex],
            groupTeams: groupTeams,
            standings: standings,
            groupMatchIndex: 0,
            stage: .groupStage,
            knockoutOpponents: GlobalCupRules.knockoutOpponents(playerNationID: playerNationID, seed: seed),
            lastSummary: "Global Cup 48 begins"
        )
    }

    func currentConfiguration() -> MatchConfiguration? {
        guard let opponentID = currentOpponentID else { return nil }
        let context = context
        let arenaID = stage.isKnockout ? NationLibrary.nation(for: opponentID).homeArena : NationLibrary.nation(for: playerNationID).homeArena

        return MatchConfiguration(
            mode: .globalCup,
            playerNationID: playerNationID,
            opponentNationID: opponentID,
            arenaID: arenaID,
            seed: seed ^ UInt64(groupMatchIndex + 31),
            rules: .globalCup(arenaID: arenaID, context: context),
            cupContext: context
        )
    }

    mutating func record(result: MatchResult) {
        guard result.configuration.mode == .globalCup, !isComplete else { return }

        if stage == .groupStage {
            recordGroupMatch(result: result)
            groupMatchIndex += 1

            if groupMatchIndex >= 3 {
                settleGroup()
            } else {
                lastSummary = GlobalCupRules.standingSummary(standings)
            }
            return
        }

        switch result.outcome {
        case .win:
            if let next = stage.nextKnockoutStage {
                stage = next
                lastSummary = next == .champion ? "Global Cup complete" : "Advanced to \(next.displayName)"
            }
        case .draw, .loss:
            stage = .eliminated
            lastSummary = "Cup run ended in \(stage.displayName)"
        }
    }

    private mutating func recordGroupMatch(result: MatchResult) {
        updateStanding(for: playerNationID, goalsFor: result.playerScore, goalsAgainst: result.opponentScore)
        updateStanding(for: result.configuration.opponentNationID, goalsFor: result.opponentScore, goalsAgainst: result.playerScore)
        simulateOtherGroupMatch(excluding: result.configuration.opponentNationID)
    }

    private mutating func simulateOtherGroupMatch(excluding opponentID: NationID) {
        let cpuTeams = groupTeams.filter { $0 != playerNationID && $0 != opponentID }
        guard cpuTeams.count == 2 else { return }
        let score = GlobalCupRules.simulatedScore(seed: seed, round: groupMatchIndex)
        updateStanding(for: cpuTeams[0], goalsFor: score.0, goalsAgainst: score.1)
        updateStanding(for: cpuTeams[1], goalsFor: score.1, goalsAgainst: score.0)
    }

    private mutating func settleGroup() {
        standings = GlobalCupRules.rankedStandings(standings)
        guard let rank = standings.firstIndex(where: { $0.nationID == playerNationID }) else {
            stage = .eliminated
            lastSummary = "Cup run ended"
            return
        }

        let playerStanding = standings[rank]
        if rank <= 1 || (rank == 2 && playerStanding.points >= 4) {
            stage = .roundOf32
            lastSummary = "Qualified from Group \(groupID)"
        } else {
            stage = .eliminated
            lastSummary = "Finished Group \(groupID) rank \(rank + 1)"
        }
    }

    private mutating func updateStanding(for nationID: NationID, goalsFor: Int, goalsAgainst: Int) {
        guard let index = standings.firstIndex(where: { $0.nationID == nationID }) else { return }
        standings[index].record(goalsFor: goalsFor, goalsAgainst: goalsAgainst)
    }
}
