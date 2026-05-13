import Foundation

@MainActor
final class AppRouter: ObservableObject {
    enum Screen {
        case home
        case nationSelect(GameMode)
        case game(MatchConfiguration)
        case results(MatchResult)
        case store
    }

    @Published var screen: Screen = .home
    @Published var selectedNationID: NationID = .usa

    init() {
        if ProcessInfo.processInfo.arguments.contains("-smokeQuickKick") {
            screen = .game(makeConfiguration(mode: .quickKick, nationID: selectedNationID))
        }
    }

    func showHome() {
        screen = .home
    }

    func showStore() {
        screen = .store
    }

    func chooseNation(for mode: GameMode) {
        screen = .nationSelect(mode)
    }

    func startMatch(mode: GameMode, nationID: NationID) {
        selectedNationID = nationID
        screen = .game(makeConfiguration(mode: mode, nationID: nationID))
    }

    func showResults(_ result: MatchResult) {
        screen = .results(result)
    }

    private func makeConfiguration(mode: GameMode, nationID: NationID) -> MatchConfiguration {
        switch mode {
        case .quickKick:
            let opponent = randomOpponent(excluding: nationID)
            let arenaID = ArenaID.allCases.randomElement() ?? NationLibrary.nation(for: nationID).homeArena
            return MatchConfiguration(
                mode: mode,
                playerNationID: nationID,
                opponentNationID: opponent,
                arenaID: arenaID,
                seed: UInt64.random(in: 1...UInt64.max),
                rules: .standard(arenaID: arenaID, duration: mode.duration)
            )

        case .dailyClash:
            let daily = DailyChallenge.today()
            return MatchConfiguration(
                mode: mode,
                playerNationID: daily.playerNationID,
                opponentNationID: daily.opponentNationID,
                arenaID: daily.arenaID,
                seed: daily.seed,
                rules: .standard(arenaID: daily.arenaID, duration: mode.duration)
            )

        case .roastReplay:
            let opponent = randomOpponent(excluding: nationID)
            let arenaID = NationLibrary.nation(for: opponent).homeArena
            return MatchConfiguration(
                mode: mode,
                playerNationID: nationID,
                opponentNationID: opponent,
                arenaID: arenaID,
                seed: UInt64.random(in: 1...UInt64.max),
                rules: .standard(arenaID: arenaID, duration: mode.duration)
            )

        case .partyMode:
            let opponent = randomOpponent(excluding: nationID)
            let arenaID = NationLibrary.nation(for: nationID).homeArena
            return MatchConfiguration(
                mode: mode,
                playerNationID: nationID,
                opponentNationID: opponent,
                arenaID: arenaID,
                seed: UInt64.random(in: 1...UInt64.max),
                rules: .standard(arenaID: arenaID, duration: mode.duration, maxGoals: 3)
            )
        }
    }

    private func randomOpponent(excluding nationID: NationID) -> NationID {
        NationID.allCases.filter { $0 != nationID }.randomElement() ?? .mexico
    }
}
