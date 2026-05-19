import SpriteKit
import UIKit

struct PinballArenaController {
    let arenaID: ArenaID
    let rules: MatchRules
    let seed: UInt64

    func build(in scene: SKScene, fieldRect: CGRect) {
        buildRandomBlockers(in: scene, fieldRect: fieldRect)
        buildArenaAccent(in: scene, fieldRect: fieldRect)
    }

    private func buildPostBumpers(in scene: SKScene, fieldRect: CGRect) {
        let gap = min(150, fieldRect.height * 0.29) / 2
        let points = [
            CGPoint(x: fieldRect.minX + 18, y: fieldRect.midY - gap),
            CGPoint(x: fieldRect.minX + 18, y: fieldRect.midY + gap),
            CGPoint(x: fieldRect.maxX - 18, y: fieldRect.midY - gap),
            CGPoint(x: fieldRect.maxX - 18, y: fieldRect.midY + gap)
        ]

        for point in points {
            let bumper = SKShapeNode(circleOfRadius: 17)
            bumper.name = "postBumper"
            bumper.position = point
            bumper.fillColor = UIColor(hex: "#F8F5E8")
            bumper.strokeColor = UIColor(hex: "#F2C14E")
            bumper.lineWidth = 4
            bumper.physicsBody = SKPhysicsBody(circleOfRadius: 17)
            bumper.physicsBody?.isDynamic = false
            bumper.physicsBody?.restitution = 1.22
            bumper.physicsBody?.categoryBitMask = PhysicsCategory.arenaEffect
            bumper.physicsBody?.contactTestBitMask = PhysicsCategory.ball
            bumper.physicsBody?.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.striker | PhysicsCategory.opponent
            bumper.zPosition = 4
            scene.addChild(bumper)
        }
    }

    private func buildAdBoards(in scene: SKScene, fieldRect: CGRect) {
        let boardWidth = fieldRect.width * 0.26
        let xOffsets: [CGFloat] = [-0.28, 0.28]
        let yOffsets: [CGFloat] = [0.18, 0.82]

        for yFactor in yOffsets {
            for xFactor in xOffsets {
                let board = SKShapeNode(rectOf: CGSize(width: boardWidth, height: 15), cornerRadius: 5)
                board.name = "adBoard"
                board.position = CGPoint(x: fieldRect.midX + fieldRect.width * xFactor, y: fieldRect.minY + fieldRect.height * yFactor)
                board.zRotation = xFactor < 0 ? 0.12 : -0.12
                board.fillColor = UIColor(hex: yFactor < 0.5 ? "#24A0ED" : "#F0524F")
                board.strokeColor = UIColor.white.withAlphaComponent(0.72)
                board.lineWidth = 2
                board.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: boardWidth, height: 15))
                board.physicsBody?.isDynamic = false
                board.physicsBody?.restitution = 1.05
                board.physicsBody?.categoryBitMask = PhysicsCategory.arenaEffect
                board.physicsBody?.contactTestBitMask = PhysicsCategory.ball
                board.physicsBody?.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.striker | PhysicsCategory.opponent
                board.zPosition = 3

                let label = SKLabelNode(text: xFactor < 0 ? "ROAR" : "KICK")
                label.fontName = "AvenirNext-Heavy"
                label.fontSize = 8
                label.fontColor = .white
                label.verticalAlignmentMode = .center
                label.horizontalAlignmentMode = .center
                label.zPosition = 4
                board.addChild(label)
                scene.addChild(board)
            }
        }
    }

    private func buildCornerSprings(in scene: SKScene, fieldRect: CGRect) {
        let positions = [
            CGPoint(x: fieldRect.minX + 35, y: fieldRect.minY + 35),
            CGPoint(x: fieldRect.maxX - 35, y: fieldRect.minY + 35),
            CGPoint(x: fieldRect.minX + 35, y: fieldRect.maxY - 35),
            CGPoint(x: fieldRect.maxX - 35, y: fieldRect.maxY - 35)
        ]

        for position in positions {
            let spring = SKShapeNode(rectOf: CGSize(width: 20, height: 42), cornerRadius: 8)
            spring.name = "cornerSpring"
            spring.position = position
            spring.zRotation = position.x < fieldRect.midX ? -0.72 : 0.72
            spring.fillColor = UIColor(hex: "#17B978")
            spring.strokeColor = UIColor(hex: "#F2C14E")
            spring.lineWidth = 3
            spring.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 42))
            spring.physicsBody?.isDynamic = false
            spring.physicsBody?.restitution = 1.32
            spring.physicsBody?.categoryBitMask = PhysicsCategory.arenaEffect
            spring.physicsBody?.contactTestBitMask = PhysicsCategory.ball
            spring.physicsBody?.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.striker | PhysicsCategory.opponent
            spring.zPosition = 3
            scene.addChild(spring)
        }
    }

    private func buildRandomBlockers(in scene: SKScene, fieldRect: CGRect) {
        var generator = SeededRandomGenerator(seed: seed ^ 0xB10CCADE)
        var kinds = [
            "refereeBlocker",
            "lineJudgeBlocker",
            "keeperBlocker",
            "flagBlocker",
            "miniPost",
            "adBoard",
            "whistleHex",
            "cameraDiamond",
            "coneBlocker",
            "springChevron",
            "scoreboardBar",
            "luckyStar",
            "fanDrum",
            "bootBlocker",
            "confettiRing",
            "captainShield"
        ]

        if kinds.count > 1 {
            for index in stride(from: kinds.count - 1, through: 1, by: -1) {
                let swapIndex = Int(generator.next() % UInt64(index + 1))
                kinds.swapAt(index, swapIndex)
            }
        }

        for index in 0..<min(rules.blockerCount, kinds.count) {
            let kind = kinds[index]
            let blocker = randomBlocker(kind: kind, index: index)
            let xInset: CGFloat = 48
            let yInset: CGFloat = 92
            var position = CGPoint(
                x: fieldRect.minX + xInset + generator.nextUnit() * max(1, fieldRect.width - xInset * 2),
                y: fieldRect.minY + yInset + generator.nextUnit() * max(1, fieldRect.height - yInset * 2)
            )

            if position.distance(to: CGPoint(x: fieldRect.midX, y: fieldRect.midY)) < 72 {
                position.y = position.y < fieldRect.midY ? fieldRect.midY - 88 : fieldRect.midY + 88
            }

            if position.y < fieldRect.minY + fieldRect.height * 0.27 {
                position.y += fieldRect.height * 0.12
            }

            blocker.position = position
            blocker.zRotation = generator.nextSignedUnit() * 0.45
            configure(blocker: blocker)
            scene.addChild(blocker)

            if index < rules.movingBlockerCount {
                let dx = generator.nextSignedUnit() * 30
                let dy = generator.nextSignedUnit() * 38
                let duration = 1.4 + Double(generator.nextUnit()) * 1.2
                blocker.run(.repeatForever(.sequence([
                    .moveBy(x: dx, y: dy, duration: duration),
                    .moveBy(x: -dx, y: -dy, duration: duration)
                ])))
            }
        }
    }

    private func randomBlocker(kind: String, index: Int) -> SKShapeNode {
        let node: SKShapeNode

        switch kind {
        case "refereeBlocker":
            node = SKShapeNode(circleOfRadius: 13)
            node.fillColor = UIColor(hex: "#1B202B")
            node.strokeColor = UIColor(hex: "#F2C14E")
            addLabel("REF", to: node, color: .white)
        case "lineJudgeBlocker":
            node = SKShapeNode(rectOf: CGSize(width: 12, height: 44), cornerRadius: 5)
            node.fillColor = UIColor(hex: "#F0524F")
            node.strokeColor = UIColor(hex: "#F8F5E8")
        case "keeperBlocker":
            node = SKShapeNode(rectOf: CGSize(width: 36, height: 15), cornerRadius: 7)
            node.fillColor = UIColor(hex: "#24A0ED")
            node.strokeColor = UIColor.white.withAlphaComponent(0.80)
            addLabel("GK", to: node, color: UIColor(hex: "#111722"))
        case "flagBlocker":
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -10, y: -15))
            path.addLine(to: CGPoint(x: -10, y: 17))
            path.addLine(to: CGPoint(x: 15, y: 6))
            path.addLine(to: CGPoint(x: -10, y: -15))
            node = SKShapeNode(path: path)
            node.fillColor = UIColor(hex: "#17B978")
            node.strokeColor = UIColor(hex: "#F2C14E")
        case "miniPost":
            node = SKShapeNode(circleOfRadius: 11)
            node.fillColor = UIColor(hex: "#F8F5E8")
            node.strokeColor = UIColor(hex: "#F0524F")
        case "adBoard":
            node = SKShapeNode(rectOf: CGSize(width: 44, height: 11), cornerRadius: 5)
            node.fillColor = index.isMultiple(of: 2) ? UIColor(hex: "#6C4AB6") : UIColor(hex: "#E4572E")
            node.strokeColor = UIColor.white.withAlphaComponent(0.70)
            addLabel("CUP", to: node, color: .white)
        case "whistleHex":
            node = SKShapeNode(path: regularPolygon(sides: 6, radius: 16))
            node.fillColor = UIColor(hex: "#F2C14E")
            node.strokeColor = UIColor(hex: "#101622")
            addLabel("!", to: node, color: UIColor(hex: "#101622"))
        case "cameraDiamond":
            node = SKShapeNode(path: diamond(width: 34, height: 26))
            node.fillColor = UIColor(hex: "#24A0ED")
            node.strokeColor = UIColor.white.withAlphaComponent(0.78)
            addLabel("CAM", to: node, color: .white)
        case "coneBlocker":
            node = SKShapeNode(path: trapezoid(top: 18, bottom: 34, height: 30))
            node.fillColor = UIColor(hex: "#F0524F")
            node.strokeColor = UIColor(hex: "#FFF4D6")
        case "springChevron":
            node = SKShapeNode(path: chevron(width: 42, height: 28))
            node.fillColor = UIColor(hex: "#17B978")
            node.strokeColor = UIColor(hex: "#F2C14E")
        case "scoreboardBar":
            node = SKShapeNode(rectOf: CGSize(width: 52, height: 18), cornerRadius: 3)
            node.fillColor = UIColor(hex: "#101622")
            node.strokeColor = UIColor(hex: "#9DE7FF")
            addLabel("VAR", to: node, color: UIColor(hex: "#9DE7FF"))
        case "fanDrum":
            node = SKShapeNode(circleOfRadius: 15)
            node.fillColor = UIColor(hex: "#E4572E")
            node.strokeColor = UIColor(hex: "#F8F5E8")
            addLabel("DRM", to: node, color: .white)
        case "bootBlocker":
            node = SKShapeNode(path: bootPath(width: 38, height: 24))
            node.fillColor = UIColor(hex: "#29335C")
            node.strokeColor = UIColor(hex: "#F2C14E")
        case "confettiRing":
            node = SKShapeNode(circleOfRadius: 16)
            node.fillColor = UIColor(hex: "#17B978").withAlphaComponent(0.18)
            node.strokeColor = UIColor(hex: "#F0524F")
        case "captainShield":
            node = SKShapeNode(path: shieldPath(width: 34, height: 38))
            node.fillColor = UIColor(hex: "#6C4AB6")
            node.strokeColor = UIColor(hex: "#F8F5E8")
            addLabel("C", to: node, color: UIColor(hex: "#F8F5E8"))
        default:
            node = SKShapeNode(path: starPath(points: 5, outerRadius: 18, innerRadius: 8))
            node.fillColor = UIColor(hex: "#F2C14E")
            node.strokeColor = UIColor(hex: "#F0524F")
        }

        node.name = kind
        node.lineWidth = 2.4
        node.zPosition = 4
        return node
    }

    private func configure(blocker: SKShapeNode) {
        let body: SKPhysicsBody
        switch blocker.name {
        case "refereeBlocker", "miniPost", "fanDrum", "confettiRing":
            let radius: CGFloat
            if blocker.name == "refereeBlocker" {
                radius = 13
            } else if blocker.name == "miniPost" {
                radius = 11
            } else {
                radius = 15
            }
            body = SKPhysicsBody(circleOfRadius: radius)
        case "lineJudgeBlocker":
            body = SKPhysicsBody(rectangleOf: CGSize(width: 12, height: 44))
        case "keeperBlocker":
            body = SKPhysicsBody(rectangleOf: CGSize(width: 36, height: 15))
        case "flagBlocker", "whistleHex", "cameraDiamond", "coneBlocker", "springChevron", "luckyStar", "bootBlocker", "captainShield":
            body = SKPhysicsBody(rectangleOf: CGSize(width: 26, height: 32))
        case "scoreboardBar":
            body = SKPhysicsBody(rectangleOf: CGSize(width: 52, height: 18))
        default:
            body = SKPhysicsBody(rectangleOf: CGSize(width: 44, height: 11))
        }

        body.isDynamic = false
        body.restitution = min(1.82, 1.22 * CGFloat(rules.reboundMultiplier))
        body.categoryBitMask = PhysicsCategory.arenaEffect
        body.contactTestBitMask = PhysicsCategory.ball
        body.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.striker | PhysicsCategory.opponent
        blocker.physicsBody = body
    }

    private func addLabel(_ text: String, to node: SKShapeNode, color: UIColor) {
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 7
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 5
        node.addChild(label)
    }

    private func regularPolygon(sides: Int, radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        for index in 0..<sides {
            let angle = CGFloat(index) * (.pi * 2 / CGFloat(sides)) - .pi / 2
            let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }

    private func diamond(width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -height / 2))
        path.addLine(to: CGPoint(x: -width / 2, y: 0))
        path.closeSubpath()
        return path
    }

    private func trapezoid(top: CGFloat, bottom: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -bottom / 2, y: -height / 2))
        path.addLine(to: CGPoint(x: bottom / 2, y: -height / 2))
        path.addLine(to: CGPoint(x: top / 2, y: height / 2))
        path.addLine(to: CGPoint(x: -top / 2, y: height / 2))
        path.closeSubpath()
        return path
    }

    private func chevron(width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: -height / 2))
        path.addLine(to: CGPoint(x: 0, y: -height * 0.10))
        path.addLine(to: CGPoint(x: width / 2, y: -height / 2))
        path.addLine(to: CGPoint(x: width * 0.18, y: height / 2))
        path.addLine(to: CGPoint(x: 0, y: height * 0.16))
        path.addLine(to: CGPoint(x: -width * 0.18, y: height / 2))
        path.closeSubpath()
        return path
    }

    private func bootPath(width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: -height * 0.22))
        path.addLine(to: CGPoint(x: -width * 0.12, y: -height * 0.22))
        path.addLine(to: CGPoint(x: width * 0.02, y: height * 0.30))
        path.addLine(to: CGPoint(x: width * 0.24, y: height * 0.30))
        path.addLine(to: CGPoint(x: width * 0.24, y: -height * 0.08))
        path.addLine(to: CGPoint(x: width / 2, y: -height * 0.08))
        path.addLine(to: CGPoint(x: width / 2, y: -height * 0.32))
        path.addLine(to: CGPoint(x: -width / 2, y: -height * 0.32))
        path.closeSubpath()
        return path
    }

    private func shieldPath(width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: height * 0.20))
        path.addLine(to: CGPoint(x: width * 0.34, y: -height * 0.34))
        path.addLine(to: CGPoint(x: 0, y: -height / 2))
        path.addLine(to: CGPoint(x: -width * 0.34, y: -height * 0.34))
        path.addLine(to: CGPoint(x: -width / 2, y: height * 0.20))
        path.closeSubpath()
        return path
    }

    private func starPath(points: Int, outerRadius: CGFloat, innerRadius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        for index in 0..<(points * 2) {
            let radius = index.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = CGFloat(index) * (.pi / CGFloat(points)) - .pi / 2
            let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }

    private func buildMagnetZones(in scene: SKScene, fieldRect: CGRect) {
        for x in [fieldRect.minX + 48, fieldRect.maxX - 48] {
            let zone = SKShapeNode(ellipseOf: CGSize(width: 74, height: 168))
            zone.name = "magnetZone"
            zone.position = CGPoint(x: x, y: fieldRect.midY)
            zone.fillColor = UIColor(hex: "#F2C14E").withAlphaComponent(0.08)
            zone.strokeColor = UIColor(hex: "#F2C14E").withAlphaComponent(0.20)
            zone.lineWidth = 2
            zone.zPosition = -4
            scene.addChild(zone)
        }
    }

    private func buildArenaAccent(in scene: SKScene, fieldRect: CGRect) {
        let accent = SKShapeNode(rect: fieldRect.insetBy(dx: 7, dy: 7), cornerRadius: 8)
        accent.lineWidth = 2
        accent.zPosition = -5

        switch arenaID {
        case .turboField:
            accent.strokeColor = UIColor(hex: "#24A0ED").withAlphaComponent(0.42)
            accent.fillColor = UIColor.clear
        case .desertFiesta:
            accent.strokeColor = UIColor(hex: "#F0524F").withAlphaComponent(0.45)
            accent.fillColor = UIColor(hex: "#F2C14E").withAlphaComponent(0.04)
        case .sambaCurve:
            accent.strokeColor = UIColor(hex: "#F5D64E").withAlphaComponent(0.44)
            accent.fillColor = UIColor(hex: "#159A5B").withAlphaComponent(0.05)
        case .precisionGrid:
            accent.strokeColor = UIColor.white.withAlphaComponent(0.26)
            accent.fillColor = UIColor.white.withAlphaComponent(0.04)
            buildGrid(in: scene, fieldRect: fieldRect)
        case .iceRink:
            accent.strokeColor = UIColor(hex: "#9DE7FF").withAlphaComponent(0.45)
            accent.fillColor = UIColor(hex: "#9DE7FF").withAlphaComponent(0.08)
        case .sandShield:
            accent.strokeColor = UIColor(hex: "#E2B85E").withAlphaComponent(0.45)
            accent.fillColor = UIColor(hex: "#C49A54").withAlphaComponent(0.06)
        }

        scene.addChild(accent)
    }

    private func buildGrid(in scene: SKScene, fieldRect: CGRect) {
        let path = CGMutablePath()
        let step: CGFloat = 38
        var x = fieldRect.minX + step
        while x < fieldRect.maxX {
            path.move(to: CGPoint(x: x, y: fieldRect.minY))
            path.addLine(to: CGPoint(x: x, y: fieldRect.maxY))
            x += step
        }
        var y = fieldRect.minY + step
        while y < fieldRect.maxY {
            path.move(to: CGPoint(x: fieldRect.minX, y: y))
            path.addLine(to: CGPoint(x: fieldRect.maxX, y: y))
            y += step
        }
        let grid = SKShapeNode(path: path)
        grid.strokeColor = UIColor.white.withAlphaComponent(0.08)
        grid.lineWidth = 1
        grid.zPosition = -6
        scene.addChild(grid)
    }
}
