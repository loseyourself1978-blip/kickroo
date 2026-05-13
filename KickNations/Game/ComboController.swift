import Foundation

struct ComboState: Equatable {
    let current: Int
    let max: Int
    let styleScore: Int
}

final class ComboController {
    private(set) var current: Int = 0
    private(set) var maxCombo: Int = 0
    private(set) var styleScore: Int = 0

    func registerHit(named effectName: String?) {
        current += 1
        maxCombo = max(maxCombo, current)

        switch effectName {
        case "postBumper":
            styleScore += 16
        case "adBoard":
            styleScore += 12
        case "cornerSpring":
            styleScore += 18
        case "magnetZone":
            styleScore += 10
        default:
            styleScore += 6
        }
    }

    func registerGoal(playerScored: Bool) -> Int {
        let bonus = current * (playerScored ? 22 : 14)
        styleScore += bonus
        let finishedCombo = current
        current = 0
        return finishedCombo
    }

    func resetSoftly() {
        current = max(0, current / 2)
    }

    func addStyleScore(_ amount: Int) {
        styleScore += max(0, amount)
    }

    var snapshot: ComboState {
        ComboState(current: current, max: maxCombo, styleScore: styleScore)
    }
}
