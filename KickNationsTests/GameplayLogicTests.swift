import CoreGraphics
import XCTest
@testable import Kick_Nations

final class GameplayLogicTests: XCTestCase {
    func testLongYellowCrowdChainGrantsBonusRoarEnergy() {
        let reward = CrowdRules.reward(for: .yellow, length: 6)

        XCTAssertGreaterThanOrEqual(reward.roarEnergy, 78)
        XCTAssertEqual(reward.powerShotMultiplier, 1)
        XCTAssertEqual(reward.shieldDuration, 0)
    }

    func testShortRedCrowdChainStillPowersNextShot() {
        let reward = CrowdRules.reward(for: .red, length: 3)

        XCTAssertEqual(reward.roarEnergy, 27)
        XCTAssertGreaterThan(reward.powerShotMultiplier, 1)
        XCTAssertEqual(reward.curveBonus, 0)
    }

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

    func testDailyChallengeIsDeterministicForSameDate() {
        var components = DateComponents()
        components.year = 2026
        components.month = 5
        components.day = 13
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: components)!

        XCTAssertEqual(
            DailyChallenge.today(now: date, calendar: calendar),
            DailyChallenge.today(now: date, calendar: calendar)
        )
    }
}

