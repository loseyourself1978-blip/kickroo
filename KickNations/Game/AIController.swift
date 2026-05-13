import CoreGraphics
import Foundation

struct AIController {
    let profile: AIProfile

    func reactionDelay(using generator: inout SeededRandomGenerator) -> TimeInterval {
        let base = 0.78 - (profile.aggression * 0.22)
        return max(0.42, base + Double(generator.nextUnit()) * 0.16)
    }

    func launchImpulse(
        opponentPosition: CGPoint,
        ballPosition: CGPoint,
        ownGoalX: CGFloat,
        targetGoalX: CGFloat,
        fieldRect: CGRect,
        isMirageActive: Bool,
        using generator: inout SeededRandomGenerator
    ) -> CGVector {
        let nearOwnGoal = abs(ballPosition.x - ownGoalX) < fieldRect.width * 0.30
        let target: CGPoint

        if nearOwnGoal || profile.defense > profile.aggression + 0.25 {
            target = CGPoint(x: ballPosition.x, y: fieldRect.midY)
        } else {
            let goalY = fieldRect.midY + generator.nextSignedUnit() * fieldRect.height * 0.16
            target = CGPoint(x: targetGoalX, y: goalY)
        }

        var vector = CGVector(dx: target.x - opponentPosition.x, dy: target.y - opponentPosition.y)
        if vector.length < 12 {
            vector = CGVector(dx: ballPosition.x - opponentPosition.x, dy: ballPosition.y - opponentPosition.y)
        }

        let errorScale: CGFloat = isMirageActive ? 0.42 : 0.18
        let angleError = generator.nextSignedUnit() * errorScale * CGFloat(1.1 - profile.controlProxy)
        let rotated = vector.normalized().rotated(by: angleError)
        let strength = CGFloat(42 + profile.aggression * 30)
        return CGVector(dx: rotated.dx * strength, dy: rotated.dy * strength)
    }
}

private extension AIProfile {
    var controlProxy: Double {
        max(0.25, min(1, (defense + curveBias) / 2))
    }
}
