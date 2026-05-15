import CoreGraphics
import XCTest
@testable import Kick_Nations

final class GameplayLogicTests: XCTestCase {
    func testRoarControllerSpendsEnergyAndTracksHeat() {
        let controller = RoarController()
        let field = CGRect(x: 0, y: 0, width: 320, height: 520)

        let wave = controller.trigger(.left, at: 1, in: field)

        XCTAssertNotNil(wave)
        XCTAssertEqual(controller.energy, 10)
        XCTAssertEqual(controller.heat, 34)
        XCTAssertEqual(controller.activeWaves.count, 1)
    }

    func testComboControllerTracksMaxComboAndStyleScore() {
        let combo = ComboController()

        combo.registerHit(named: "postBumper")
        combo.registerHit(named: "adBoard")
        combo.registerHit(named: "cornerSpring")
        let finished = combo.registerGoal(playerScored: true)

        XCTAssertEqual(finished, 3)
        XCTAssertEqual(combo.snapshot.max, 3)
        XCTAssertGreaterThan(combo.snapshot.styleScore, 60)
        XCTAssertEqual(combo.snapshot.current, 0)
    }

    func testGlobalCupUsesFortyEightTeamsAcrossTwelveGroups() {
        let groups = GlobalCupRules.makeGroups(seed: 20260514)

        XCTAssertEqual(NationID.allCases.count, 48)
        XCTAssertEqual(groups.count, 12)
        XCTAssertTrue(groups.allSatisfy { $0.count == 4 })
        XCTAssertEqual(Set(groups.flatMap { $0 }).count, 48)
    }

    func testGlobalCupRankingUsesPointsGoalDifferenceThenGoalsFor() {
        var usa = CupStanding(nationID: .usa)
        usa.record(goalsFor: 2, goalsAgainst: 0)

        var brazil = CupStanding(nationID: .brazil)
        brazil.record(goalsFor: 3, goalsAgainst: 1)

        var japan = CupStanding(nationID: .japan)
        japan.record(goalsFor: 1, goalsAgainst: 1)

        let ranked = GlobalCupRules.rankedStandings([japan, usa, brazil])

        XCTAssertEqual(ranked.map(\.nationID), [.brazil, .usa, .japan])
    }

    func testOnlyGlobalCupModeIsExposed() {
        XCTAssertEqual(GameMode.allCases, [.globalCup])
    }

    func testCupRulesAreFastAndBouncy() {
        let cupContext = GlobalCupContext(stage: .roundOf32, groupID: nil, matchNumber: 1, standingSummary: "")
        let cup = MatchRules.globalCup(arenaID: .turboField, context: cupContext)
        let practice = MatchRules.cupPractice(arenaID: .turboField)

        XCTAssertTrue(cup.requiresWinner)
        XCTAssertGreaterThan(cup.launchPowerMultiplier, 2.5)
        XCTAssertGreaterThan(cup.reboundMultiplier, 1.45)
        XCTAssertTrue(practice.allowsDraw)
    }

    func testGlobalCupCampaignAdvancesFromGroupToKnockout() {
        var campaign = GlobalCupCampaign.start(playerNationID: .usa, seed: 20260514)

        for _ in 0..<3 {
            let configuration = campaign.currentConfiguration()!
            let result = MatchResult(
                configuration: configuration,
                playerScore: 3,
                opponentScore: 0,
                duration: 45,
                headline: "Test win",
                chaosScore: 0,
                maxCombo: 0,
                coinsEarned: 0
            )
            campaign.record(result: result)
        }

        XCTAssertEqual(campaign.stage, .roundOf32)
        XCTAssertTrue(campaign.currentConfiguration()?.rules.requiresWinner == true)
    }
}
