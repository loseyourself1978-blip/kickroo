import SpriteKit
import UIKit

struct PinballArenaController {
    let arenaID: ArenaID

    func build(in scene: SKScene, fieldRect: CGRect) {
        buildPostBumpers(in: scene, fieldRect: fieldRect)
        buildAdBoards(in: scene, fieldRect: fieldRect)
        buildCornerSprings(in: scene, fieldRect: fieldRect)
        buildMagnetZones(in: scene, fieldRect: fieldRect)
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

