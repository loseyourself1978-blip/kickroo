import CoreGraphics
import UIKit
import XCTest
@testable import Kickroo

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

    func testCupRulesEscalateFromPracticeToFinal() {
        let openerContext = GlobalCupContext(stage: .groupStage, groupID: "A", matchNumber: 1, standingSummary: "")
        let finalContext = GlobalCupContext(stage: .final, groupID: nil, matchNumber: 1, standingSummary: "")
        let opener = MatchRules.globalCup(arenaID: .turboField, context: openerContext)
        let final = MatchRules.globalCup(arenaID: .turboField, context: finalContext)
        let practice = MatchRules.cupPractice(arenaID: .turboField)

        XCTAssertFalse(opener.requiresWinner)
        XCTAssertTrue(final.requiresWinner)
        XCTAssertTrue(practice.allowsDraw)
        XCTAssertLessThan(practice.blockerCount, opener.blockerCount)
        XCTAssertLessThan(opener.blockerCount, final.blockerCount)
        XCTAssertLessThan(opener.movingBlockerCount, final.movingBlockerCount)
        XCTAssertLessThan(final.opponentCadence, opener.opponentCadence)
        XCTAssertGreaterThan(final.launchPowerMultiplier, opener.launchPowerMultiplier)
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

    func testSharePosterRendersAllStylesAndUsesPublicLandingPage() {
        var campaign = GlobalCupCampaign.start(playerNationID: .usa, seed: 20260514)
        let configuration = campaign.currentConfiguration()!
        let result = MatchResult(
            configuration: configuration,
            playerScore: 2,
            opponentScore: 1,
            duration: 50,
            headline: "Late rail winner",
            chaosScore: 808,
            maxCombo: 21,
            coinsEarned: 140
        )
        campaign.record(result: result)

        let service = ShareService()
        let message = service.text(for: result, campaign: campaign, content: .cup)

        XCTAssertTrue(message.contains("https://loseyourself1978-blip.github.io/kickroo/"))
        XCTAssertEqual(SharePosterStyle.allCases.count, 4)

        for style in SharePosterStyle.allCases {
            let image = service.makeHighlightPoster(
                for: result,
                campaign: campaign,
                content: .cup,
                style: style,
                size: CGSize(width: 270, height: 480)
            )
            XCTAssertEqual(image.size.width, 270, accuracy: 0.1)
            XCTAssertEqual(image.size.height, 480, accuracy: 0.1)
            XCTAssertNotNil(image.cgImage)
        }
    }
}
