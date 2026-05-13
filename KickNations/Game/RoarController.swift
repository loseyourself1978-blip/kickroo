import CoreGraphics
import Foundation

enum RoarLane: String, CaseIterable, Equatable {
    case left
    case center
    case right
}

struct SoundWave: Equatable {
    let lane: RoarLane
    let origin: CGPoint
    let startedAt: TimeInterval
    let duration: TimeInterval
    let maxRadius: CGFloat
    let force: CGFloat
    let curve: CGFloat

    func progress(at time: TimeInterval) -> CGFloat {
        guard duration > 0 else { return 1 }
        return max(0, min(1, CGFloat((time - startedAt) / duration)))
    }

    func radius(at time: TimeInterval) -> CGFloat {
        maxRadius * progress(at: time)
    }

    func isActive(at time: TimeInterval) -> Bool {
        time - startedAt <= duration
    }
}

final class RoarController {
    private(set) var energy: Double = 35
    private(set) var heat: Double = 0
    private(set) var overheatedUntil: TimeInterval = 0
    private(set) var activeWaves: [SoundWave] = []

    let maxEnergy: Double = 100
    let roarCost: Double = 25
    let heatPerRoar: Double = 34
    let heatDecayPerSecond: Double = 18
    let overheatDuration: TimeInterval = 1.5

    func addEnergy(_ amount: Double) {
        energy = min(maxEnergy, energy + max(0, amount))
    }

    func update(currentTime: TimeInterval, deltaTime: TimeInterval) {
        if deltaTime > 0 {
            heat = max(0, heat - heatDecayPerSecond * deltaTime)
        }
        activeWaves.removeAll { !$0.isActive(at: currentTime) }
    }

    func trigger(_ lane: RoarLane, at currentTime: TimeInterval, in fieldRect: CGRect, curveBonus: CGFloat = 0) -> SoundWave? {
        guard currentTime >= overheatedUntil, energy >= roarCost else { return nil }

        energy -= roarCost
        heat = min(100, heat + heatPerRoar)
        if heat >= 100 {
            overheatedUntil = currentTime + overheatDuration
        }

        let origin: CGPoint
        switch lane {
        case .left:
            origin = CGPoint(x: fieldRect.minX, y: fieldRect.midY)
        case .center:
            origin = CGPoint(x: fieldRect.midX, y: fieldRect.midY)
        case .right:
            origin = CGPoint(x: fieldRect.maxX, y: fieldRect.midY)
        }

        let wave = SoundWave(
            lane: lane,
            origin: origin,
            startedAt: currentTime,
            duration: 0.72,
            maxRadius: max(fieldRect.width, fieldRect.height) * 0.86,
            force: lane == .center ? 38 : 52,
            curve: curveBonus
        )
        activeWaves.append(wave)
        return wave
    }
}

