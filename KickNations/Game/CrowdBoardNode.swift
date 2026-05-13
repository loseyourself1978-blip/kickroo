import SpriteKit
import UIKit

enum FanColorID: String, CaseIterable {
    case red
    case blue
    case yellow
    case green
    case white

    var uiColor: UIColor {
        switch self {
        case .red: UIColor(hex: "#F0524F")
        case .blue: UIColor(hex: "#2458E6")
        case .yellow: UIColor(hex: "#F2C14E")
        case .green: UIColor(hex: "#17B978")
        case .white: UIColor(hex: "#F8F5E8")
        }
    }
}

struct CrowdReward: Equatable {
    let roarEnergy: Double
    let powerShotMultiplier: CGFloat
    let shieldDuration: TimeInterval
    let curveBonus: CGFloat
    let cleanBounceDuration: TimeInterval
    let styleScore: Int

    static let none = CrowdReward(
        roarEnergy: 0,
        powerShotMultiplier: 1,
        shieldDuration: 0,
        curveBonus: 0,
        cleanBounceDuration: 0,
        styleScore: 0
    )
}

enum CrowdRules {
    static func reward(for color: FanColorID, length: Int) -> CrowdReward {
        guard length >= 3 else { return .none }

        let baseEnergy = Double(length * 9)
        let longChain = length >= 6

        switch color {
        case .red:
            return CrowdReward(
                roarEnergy: baseEnergy,
                powerShotMultiplier: longChain ? 1.22 : 1.10,
                shieldDuration: 0,
                curveBonus: 0,
                cleanBounceDuration: 0,
                styleScore: length * 14
            )
        case .blue:
            return CrowdReward(
                roarEnergy: baseEnergy,
                powerShotMultiplier: 1,
                shieldDuration: longChain ? 3.0 : 1.4,
                curveBonus: 0,
                cleanBounceDuration: 0,
                styleScore: length * 12
            )
        case .yellow:
            return CrowdReward(
                roarEnergy: baseEnergy + (longChain ? 24 : 10),
                powerShotMultiplier: 1,
                shieldDuration: 0,
                curveBonus: 0,
                cleanBounceDuration: 0,
                styleScore: length * 13
            )
        case .green:
            return CrowdReward(
                roarEnergy: baseEnergy,
                powerShotMultiplier: 1,
                shieldDuration: 0,
                curveBonus: longChain ? 0.32 : 0.16,
                cleanBounceDuration: 0,
                styleScore: length * 13
            )
        case .white:
            return CrowdReward(
                roarEnergy: baseEnergy,
                powerShotMultiplier: 1,
                shieldDuration: 0,
                curveBonus: 0,
                cleanBounceDuration: longChain ? 4.0 : 2.0,
                styleScore: length * 12
            )
        }
    }
}

final class CrowdBoardNode: SKNode {
    var onReward: ((CrowdReward) -> Void)?

    private let rect: CGRect
    private let columns = 6
    private let rows = 4
    private let tileSpacing: CGFloat = 7
    private var generator: SeededRandomGenerator
    private var tiles: [FanTileNode] = []
    private var selectedTiles: [FanTileNode] = []
    private let pathNode = SKShapeNode()

    init(rect: CGRect, seed: UInt64) {
        self.rect = rect
        self.generator = SeededRandomGenerator(seed: seed)
        super.init()
        isUserInteractionEnabled = false
        buildBoard()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func handleTouchBegan(at point: CGPoint) -> Bool {
        guard let tile = tile(at: point) else { return false }
        selectedTiles = [tile]
        tile.isSelectedForChain = true
        updatePath()
        return true
    }

    func handleTouchMoved(to point: CGPoint) {
        guard let tile = tile(at: point), let first = selectedTiles.first else { return }
        guard tile.colorID == first.colorID else { return }
        if selectedTiles.contains(where: { $0 === tile }) { return }
        guard let last = selectedTiles.last, last.isAdjacent(to: tile) else { return }
        selectedTiles.append(tile)
        tile.isSelectedForChain = true
        updatePath()
    }

    func handleTouchEnded() {
        defer {
            selectedTiles.forEach { $0.isSelectedForChain = false }
            selectedTiles.removeAll()
            pathNode.path = nil
        }

        guard let color = selectedTiles.first?.colorID else { return }
        let reward = CrowdRules.reward(for: color, length: selectedTiles.count)
        guard reward != .none else { return }

        for tile in selectedTiles {
            tile.colorID = randomColor()
            tile.run(.sequence([
                .scale(to: 1.16, duration: 0.08),
                .scale(to: 1.0, duration: 0.12)
            ]))
        }
        onReward?(reward)
    }

    private func buildBoard() {
        let panel = SKShapeNode(rect: rect, cornerRadius: 8)
        panel.fillColor = UIColor(hex: "#151922")
        panel.strokeColor = UIColor.white.withAlphaComponent(0.10)
        panel.lineWidth = 2
        panel.zPosition = -2
        addChild(panel)

        let label = SKLabelNode(text: "MATCH THE CROWD COLORS")
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 10
        label.fontColor = UIColor.white.withAlphaComponent(0.48)
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: rect.minX + 12, y: rect.maxY - 13)
        label.zPosition = 1
        addChild(label)

        pathNode.strokeColor = UIColor.white.withAlphaComponent(0.72)
        pathNode.lineWidth = 5
        pathNode.lineCap = .round
        pathNode.lineJoin = .round
        pathNode.zPosition = 4
        addChild(pathNode)

        let availableHeight = rect.height - 34
        let tileSize = min(
            (rect.width - CGFloat(columns + 1) * tileSpacing) / CGFloat(columns),
            (availableHeight - CGFloat(rows + 1) * tileSpacing) / CGFloat(rows)
        )
        let startX = rect.midX - (CGFloat(columns) * tileSize + CGFloat(columns - 1) * tileSpacing) / 2 + tileSize / 2
        let startY = rect.minY + tileSpacing + tileSize / 2

        for row in 0..<rows {
            for column in 0..<columns {
                let tile = FanTileNode(size: tileSize, row: row, column: column, colorID: randomColor())
                tile.position = CGPoint(
                    x: startX + CGFloat(column) * (tileSize + tileSpacing),
                    y: startY + CGFloat(row) * (tileSize + tileSpacing)
                )
                tile.zPosition = 2
                tiles.append(tile)
                addChild(tile)
            }
        }
    }

    private func updatePath() {
        guard let first = selectedTiles.first else {
            pathNode.path = nil
            return
        }

        let path = CGMutablePath()
        path.move(to: first.position)
        for tile in selectedTiles.dropFirst() {
            path.addLine(to: tile.position)
        }
        pathNode.path = path
    }

    private func tile(at point: CGPoint) -> FanTileNode? {
        tiles.first { $0.contains(convert(point, to: $0)) }
    }

    private func randomColor() -> FanColorID {
        let all = FanColorID.allCases
        let index = Int(generator.next() % UInt64(all.count))
        return all[index]
    }
}

private final class FanTileNode: SKShapeNode {
    let row: Int
    let column: Int
    private let tileSize: CGFloat

    var colorID: FanColorID {
        didSet { refreshStyle() }
    }

    var isSelectedForChain: Bool = false {
        didSet { refreshStyle() }
    }

    init(size: CGFloat, row: Int, column: Int, colorID: FanColorID) {
        self.tileSize = size
        self.row = row
        self.column = column
        self.colorID = colorID
        super.init()
        path = CGPath(
            roundedRect: CGRect(x: -size / 2, y: -size / 2, width: size, height: size),
            cornerWidth: 7,
            cornerHeight: 7,
            transform: nil
        )
        lineWidth = 2
        refreshStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func isAdjacent(to other: FanTileNode) -> Bool {
        abs(row - other.row) <= 1 && abs(column - other.column) <= 1
    }

    private func refreshStyle() {
        fillColor = colorID.uiColor
        strokeColor = isSelectedForChain ? UIColor.white : UIColor.black.withAlphaComponent(0.20)
        xScale = isSelectedForChain ? 1.08 : 1
        yScale = isSelectedForChain ? 1.08 : 1
        alpha = isSelectedForChain ? 1 : 0.92

        if children.isEmpty {
            let shine = SKShapeNode(circleOfRadius: tileSize * 0.12)
            shine.position = CGPoint(x: -tileSize * 0.20, y: tileSize * 0.20)
            shine.fillColor = UIColor.white.withAlphaComponent(0.28)
            shine.strokeColor = .clear
            shine.zPosition = 1
            addChild(shine)
        }
    }
}

