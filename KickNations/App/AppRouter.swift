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
    @Published var cupCampaign: GlobalCupCampaign?
    private var previousScreenBeforeGame: Screen = .home

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-smokePractice") || arguments.contains("-smokeQuickKick") {
            previousScreenBeforeGame = .home
            screen = .game(makePracticeConfiguration(nationID: selectedNationID))
        } else if arguments.contains("-smokeCup") || arguments.contains("-smokeGlobalCup") || arguments.contains("-smokePinballRush") {
            cupCampaign = GlobalCupCampaign.start(playerNationID: selectedNationID, seed: 0x20260514)
            if let configuration = cupCampaign?.currentConfiguration() {
                previousScreenBeforeGame = .home
                screen = .game(configuration)
            }
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
        cupCampaign = GlobalCupCampaign.start(playerNationID: nationID)
        if let configuration = cupCampaign?.currentConfiguration() {
            showGame(configuration)
        }
    }

    func startCupPractice(nationID: NationID) {
        selectedNationID = nationID
        showGame(makePracticeConfiguration(nationID: nationID))
    }

    func showResults(_ result: MatchResult) {
        screen = .results(result)
    }

    func finishMatch(_ result: MatchResult) {
        if !result.configuration.isPractice {
            if cupCampaign == nil {
                cupCampaign = GlobalCupCampaign.start(playerNationID: result.configuration.playerNationID, seed: result.configuration.seed)
            }
            cupCampaign?.record(result: result)
        }
        showResults(result)
    }

    func continueGlobalCup() {
        guard let configuration = cupCampaign?.currentConfiguration() else {
            showHome()
            return
        }
        showGame(configuration)
    }

    func exitCurrentMatch() {
        screen = previousScreenBeforeGame
    }

    private func makePracticeConfiguration(nationID: NationID) -> MatchConfiguration {
        let opponent = randomOpponent(excluding: nationID)
        let arenaID = NationLibrary.nation(for: nationID).homeArena

        return MatchConfiguration(
            mode: .globalCup,
            playerNationID: nationID,
            opponentNationID: opponent,
            arenaID: arenaID,
            seed: UInt64.random(in: 1...UInt64.max),
            rules: .cupPractice(arenaID: arenaID),
            cupContext: GlobalCupContext(
                stage: .groupStage,
                groupID: "Practice",
                matchNumber: 0,
                standingSummary: "Learn, retry, then start the official cup"
            ),
            isPractice: true
        )
    }

    private func randomOpponent(excluding nationID: NationID) -> NationID {
        NationID.allCases.filter { $0 != nationID }.randomElement() ?? .mexico
    }

    private func showGame(_ configuration: MatchConfiguration) {
        previousScreenBeforeGame = screen
        screen = .game(configuration)
    }
}
