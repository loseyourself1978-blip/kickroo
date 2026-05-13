import SpriteKit
import UIKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    var onSnapshot: ((MatchSnapshot) -> Void)?
    var onMatchEnd: ((MatchResult) -> Void)?

    private enum TouchMode {
        case aiming
        case crowd
    }

    private let configuration: MatchConfiguration
    private let playerNation: Nation
    private let opponentNation: Nation
    private let comboController = ComboController()
    private let roarController = RoarController()
    private var generator: SeededRandomGenerator

    private var fieldRect = CGRect.zero
    private var crowdRect = CGRect.zero
    private var configuredSize = CGSize.zero

    private let strikerRadius: CGFloat = 24
    private let opponentRadius: CGFloat = 22
    private let ballRadius: CGFloat = 14

    private var strikerNode = SKShapeNode()
    private var opponentNode = SKShapeNode()
    private var ballNode = SKShapeNode()
    private var aimArrowNode = SKShapeNode()
    private var guideLineNode = SKShapeNode()
    private var shieldNode: SKShapeNode?
    private var crowdBoard: CrowdBoardNode?
    private var roarButtonNodes: [RoarLane: SKShapeNode] = [:]

    private var absoluteStartTime: TimeInterval?
    private var phaseStartTime: TimeInterval?
    private var lastUpdateTime: TimeInterval = 0
    private var sceneTime: TimeInterval = 0
    private var isOvertime = false
    private var isMatchFinished = false
    private var isResettingAfterGoal = false

    private var playerScore = 0
    private var opponentScore = 0
    private var skillEnergy: Double = 35
    private var lastPlayerLaunchTime: TimeInterval = -10
    private var nextOpponentKickTime: TimeInterval = 0
    private var lastBallActiveTime: TimeInterval = 0
    private var lastSkillImpactTime: TimeInterval = -100

    private var touchMode: TouchMode?
    private var currentTouchLocation = CGPoint.zero
    private var pendingPowerMultiplier: CGFloat = 1
    private var curveBonusUntil: TimeInterval = 0
    private var cleanBounceUntil: TimeInterval = 0
    private var shieldUntil: TimeInterval = 0
    private var turboUntil: TimeInterval = 0

    init(size: CGSize, configuration: MatchConfiguration) {
        self.configuration = configuration
        self.playerNation = NationLibrary.nation(for: configuration.playerNationID)
        self.opponentNation = NationLibrary.nation(for: configuration.opponentNationID)
        self.generator = SeededRandomGenerator(seed: configuration.seed)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: "#0B1019")
        physicsWorld.gravity = .zero
        physicsWorld.speed = 1.0
        physicsWorld.contactDelegate = self
        configureIfNeeded()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        configureIfNeeded()
    }

    override func update(_ currentTime: TimeInterval) {
        sceneTime = currentTime
        if absoluteStartTime == nil {
            absoluteStartTime = currentTime
            phaseStartTime = currentTime
            nextOpponentKickTime = currentTime + 0.9
            lastBallActiveTime = currentTime
        }

        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        guard !isMatchFinished else { return }

        updateClock(currentTime: currentTime)
        roarController.update(currentTime: currentTime, deltaTime: deltaTime)
        updateRoarWaves(deltaTime: deltaTime, currentTime: currentTime)
        updateOpponent(currentTime: currentTime)
        updateShield(currentTime: currentTime)
        updateBallSafety(currentTime: currentTime)
        updateGuide()
        emitSnapshot()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard configuration.mode != .roastReplay, !isMatchFinished, let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let lane = roarLane(at: location) {
            triggerRoar(lane)
            return
        }

        if crowdBoard?.handleTouchBegan(at: location) == true {
            touchMode = .crowd
            return
        }

        guard canPlayerLaunch, location.distance(to: strikerNode.position) <= strikerRadius * 2.5 else { return }
        touchMode = .aiming
        currentTouchLocation = location
        updateAimArrow(to: location)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        switch touchMode {
        case .aiming:
            currentTouchLocation = location
            updateAimArrow(to: location)
        case .crowd:
            crowdBoard?.handleTouchMoved(to: location)
        case nil:
            break
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch touchMode {
        case .aiming:
            launchStriker(from: currentTouchLocation)
            aimArrowNode.path = nil
        case .crowd:
            crowdBoard?.handleTouchEnded()
        case nil:
            break
        }
        touchMode = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchMode == .crowd {
            crowdBoard?.handleTouchEnded()
        }
        touchMode = nil
        aimArrowNode.path = nil
    }

    func activatePlayerSkill() {
        guard skillEnergy >= 100, !isMatchFinished else { return }
        skillEnergy = 0
        lastSkillImpactTime = sceneTime

        switch playerNation.skill {
        case .overtimeBoost:
            turboUntil = sceneTime + 3
            roarController.addEnergy(35)
            addBurst(at: strikerNode.position, color: UIColor(hex: "#F2C14E"))

        case .cactusBounce:
            createTemporaryBumper()

        case .spinShot:
            curveBonusUntil = sceneTime + 4
            triggerRoar(.center)

        case .perfectAngle:
            cleanBounceUntil = sceneTime + 4
            guideLineNode.strokeColor = UIColor(hex: "#F2C14E")

        case .icePatch:
            ballNode.physicsBody?.linearDamping = 0.18
            addBurst(at: ballNode.position, color: UIColor(hex: "#9DE7FF"))
            run(.sequence([
                .wait(forDuration: 3.0),
                .run { [weak self] in self?.ballNode.physicsBody?.linearDamping = self?.baseBallDamping ?? 0.35 }
            ]))

        case .mirageScreen:
            applyShield(duration: 3.2)
        }

        emitSnapshot()
    }

    func triggerRoar(_ lane: RoarLane) {
        let curveBonus: CGFloat = sceneTime < curveBonusUntil ? 0.22 : 0
        guard let wave = roarController.trigger(lane, at: sceneTime, in: fieldRect, curveBonus: curveBonus) else { return }
        drawWave(wave)
        addBurst(at: wave.origin, color: UIColor(hex: "#F2C14E"))
        lastSkillImpactTime = sceneTime
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard !isMatchFinished, !isResettingAfterGoal else { return }

        let a = contact.bodyA.categoryBitMask
        let b = contact.bodyB.categoryBitMask
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node

        if has(a, b, PhysicsCategory.ball, PhysicsCategory.goal) {
            let goalNode = a == PhysicsCategory.goal ? nodeA : nodeB
            handleGoal(named: goalNode?.name)
            return
        }

        if has(a, b, PhysicsCategory.ball, PhysicsCategory.striker) {
            awardSkillEnergy(18)
            if pendingPowerMultiplier > 1 {
                applyBallVelocityMultiplier(pendingPowerMultiplier, curve: 0)
                pendingPowerMultiplier = 1
            }
        }

        if has(a, b, PhysicsCategory.ball, PhysicsCategory.opponent) {
            comboController.resetSoftly()
        }

        if has(a, b, PhysicsCategory.ball, PhysicsCategory.wall) {
            comboController.registerHit(named: "wall")
        }

        if has(a, b, PhysicsCategory.ball, PhysicsCategory.arenaEffect) {
            let effectNode = a == PhysicsCategory.arenaEffect ? nodeA : nodeB
            handleArenaEffectContact(effectNode)
        }

        if has(a, b, PhysicsCategory.ball, PhysicsCategory.shield) {
            applyBallVelocityMultiplier(1.12, curve: 0)
            comboController.registerHit(named: "shield")
        }
    }

    private func configureIfNeeded() {
        guard size.width > 100, size.height > 200, configuredSize != size else { return }
        configuredSize = size
        removeAllChildren()
        roarButtonNodes.removeAll()
        shieldNode = nil

        crowdRect = CGRect(
            x: 16,
            y: 22,
            width: size.width - 32,
            height: max(156, size.height * 0.25)
        )
        fieldRect = CGRect(
            x: 16,
            y: crowdRect.maxY + 16,
            width: size.width - 32,
            height: size.height - crowdRect.maxY - 116
        )

        drawBackground()
        drawField()
        createPhysicsBounds()
        PinballArenaController(arenaID: configuration.arenaID).build(in: self, fieldRect: fieldRect)
        createActors()
        createCrowdBoard()
        createRoarButtons()
        resetPositions()
        emitSnapshot()
    }

    private func drawBackground() {
        let glow = SKShapeNode(circleOfRadius: max(size.width, size.height) * 0.45)
        glow.position = CGPoint(x: size.width * 0.78, y: size.height * 0.88)
        glow.fillColor = UIColor(hex: "#2458E6").withAlphaComponent(0.10)
        glow.strokeColor = .clear
        glow.zPosition = -50
        addChild(glow)

        let crowdBand = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: crowdRect.maxY + 8))
        crowdBand.fillColor = UIColor(hex: "#101622")
        crowdBand.strokeColor = .clear
        crowdBand.zPosition = -40
        addChild(crowdBand)
    }

    private func drawField() {
        let field = SKShapeNode(rect: fieldRect, cornerRadius: 8)
        field.fillColor = UIColor(hex: "#0F5B43")
        field.strokeColor = UIColor.white.withAlphaComponent(0.18)
        field.lineWidth = 3
        field.zPosition = -20
        addChild(field)

        let stripeCount = 8
        for index in 0..<stripeCount {
            let stripeWidth = fieldRect.width / CGFloat(stripeCount)
            let stripe = SKShapeNode(rect: CGRect(
                x: fieldRect.minX + CGFloat(index) * stripeWidth,
                y: fieldRect.minY,
                width: stripeWidth,
                height: fieldRect.height
            ))
            stripe.fillColor = UIColor.white.withAlphaComponent(index.isMultiple(of: 2) ? 0.025 : 0.0)
            stripe.strokeColor = .clear
            stripe.zPosition = -19
            addChild(stripe)
        }

        let centerPath = CGMutablePath()
        centerPath.move(to: CGPoint(x: fieldRect.midX, y: fieldRect.minY))
        centerPath.addLine(to: CGPoint(x: fieldRect.midX, y: fieldRect.maxY))
        let centerLine = SKShapeNode(path: centerPath)
        centerLine.strokeColor = UIColor.white.withAlphaComponent(0.18)
        centerLine.lineWidth = 2
        centerLine.zPosition = -18
        addChild(centerLine)

        let centerCircle = SKShapeNode(circleOfRadius: min(58, fieldRect.width * 0.18))
        centerCircle.position = CGPoint(x: fieldRect.midX, y: fieldRect.midY)
        centerCircle.strokeColor = UIColor.white.withAlphaComponent(0.18)
        centerCircle.lineWidth = 2
        centerCircle.zPosition = -18
        addChild(centerCircle)

        addChild(goalNode(name: "leftGoal", x: fieldRect.minX + 4))
        addChild(goalNode(name: "rightGoal", x: fieldRect.maxX - 4))
    }

    private func goalNode(name: String, x: CGFloat) -> SKShapeNode {
        let goalSize = CGSize(width: 14, height: min(144, fieldRect.height * 0.29))
        let node = SKShapeNode(rectOf: goalSize, cornerRadius: 4)
        node.name = name
        node.position = CGPoint(x: x, y: fieldRect.midY)
        node.fillColor = UIColor.white.withAlphaComponent(0.08)
        node.strokeColor = UIColor.white.withAlphaComponent(0.25)
        node.lineWidth = 2
        node.physicsBody = SKPhysicsBody(rectangleOf: goalSize)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.goal
        node.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        node.physicsBody?.collisionBitMask = 0
        node.zPosition = -10
        return node
    }

    private func createPhysicsBounds() {
        let wallThickness: CGFloat = 10
        let goalGap = min(150, fieldRect.height * 0.30)
        let segment = (fieldRect.height - goalGap) / 2

        addWall(center: CGPoint(x: fieldRect.midX, y: fieldRect.minY), size: CGSize(width: fieldRect.width, height: wallThickness))
        addWall(center: CGPoint(x: fieldRect.midX, y: fieldRect.maxY), size: CGSize(width: fieldRect.width, height: wallThickness))
        addWall(center: CGPoint(x: fieldRect.minX, y: fieldRect.minY + segment / 2), size: CGSize(width: wallThickness, height: segment))
        addWall(center: CGPoint(x: fieldRect.minX, y: fieldRect.maxY - segment / 2), size: CGSize(width: wallThickness, height: segment))
        addWall(center: CGPoint(x: fieldRect.maxX, y: fieldRect.minY + segment / 2), size: CGSize(width: wallThickness, height: segment))
        addWall(center: CGPoint(x: fieldRect.maxX, y: fieldRect.maxY - segment / 2), size: CGSize(width: wallThickness, height: segment))
    }

    private func addWall(center: CGPoint, size: CGSize) {
        let wall = SKNode()
        wall.position = center
        wall.physicsBody = SKPhysicsBody(rectangleOf: size)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.restitution = 0.90
        wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        wall.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        wall.physicsBody?.collisionBitMask = PhysicsCategory.striker | PhysicsCategory.opponent | PhysicsCategory.ball
        addChild(wall)
    }

    private func createActors() {
        strikerNode = characterNode(for: playerNation, radius: strikerRadius, category: PhysicsCategory.striker, label: "YOU")
        opponentNode = characterNode(for: opponentNation, radius: opponentRadius, category: PhysicsCategory.opponent, label: "CPU")
        ballNode = ball()

        aimArrowNode.strokeColor = UIColor(hex: "#F2C14E")
        aimArrowNode.lineWidth = 5
        aimArrowNode.lineCap = .round
        aimArrowNode.zPosition = 30

        guideLineNode.strokeColor = UIColor.white.withAlphaComponent(0.24)
        guideLineNode.lineWidth = 2
        guideLineNode.zPosition = 29

        addChild(strikerNode)
        addChild(opponentNode)
        addChild(ballNode)
        addChild(guideLineNode)
        addChild(aimArrowNode)
    }

    private func characterNode(for nation: Nation, radius: CGFloat, category: UInt32, label: String) -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: radius)
        node.name = category == PhysicsCategory.striker ? "striker" : "opponent"
        node.fillColor = UIColor(hex: nation.palette.primaryHex)
        node.strokeColor = UIColor(hex: nation.palette.secondaryHex)
        node.lineWidth = 4
        node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        node.physicsBody?.mass = category == PhysicsCategory.striker ? 0.86 : 1.0
        node.physicsBody?.linearDamping = 1.55
        node.physicsBody?.angularDamping = 1.6
        node.physicsBody?.restitution = 0.58
        node.physicsBody?.allowsRotation = true
        node.physicsBody?.categoryBitMask = category
        node.physicsBody?.contactTestBitMask = PhysicsCategory.ball | PhysicsCategory.arenaEffect
        node.physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.ball | PhysicsCategory.striker | PhysicsCategory.opponent | PhysicsCategory.arenaEffect
        node.zPosition = 8

        let scarf = SKShapeNode(rectOf: CGSize(width: radius * 1.15, height: radius * 0.24), cornerRadius: radius * 0.08)
        scarf.position = CGPoint(x: 0, y: -radius * 0.18)
        scarf.fillColor = UIColor(hex: nation.palette.secondaryHex)
        scarf.strokeColor = .clear
        scarf.zRotation = -0.12
        scarf.zPosition = 9
        node.addChild(scarf)

        let code = SKLabelNode(text: nation.shortCode)
        code.fontName = "AvenirNext-Heavy"
        code.fontSize = radius * 0.38
        code.fontColor = UIColor(hex: nation.palette.accentHex)
        code.verticalAlignmentMode = .center
        code.horizontalAlignmentMode = .center
        code.position = CGPoint(x: 0, y: radius * 0.13)
        code.zPosition = 10
        node.addChild(code)

        let tag = SKLabelNode(text: label)
        tag.fontName = "AvenirNext-Bold"
        tag.fontSize = 7
        tag.fontColor = UIColor.white.withAlphaComponent(0.82)
        tag.verticalAlignmentMode = .center
        tag.position = CGPoint(x: 0, y: -radius - 9)
        tag.zPosition = 10
        node.addChild(tag)

        return node
    }

    private func ball() -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: ballRadius)
        node.name = "ball"
        node.fillColor = UIColor(hex: "#F8F5E8")
        node.strokeColor = UIColor(hex: "#1B202B")
        node.lineWidth = 2
        node.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        node.physicsBody?.mass = 0.38
        node.physicsBody?.linearDamping = baseBallDamping
        node.physicsBody?.angularDamping = 0.45
        node.physicsBody?.restitution = 0.86
        node.physicsBody?.categoryBitMask = PhysicsCategory.ball
        node.physicsBody?.contactTestBitMask = PhysicsCategory.striker | PhysicsCategory.opponent | PhysicsCategory.wall | PhysicsCategory.goal | PhysicsCategory.arenaEffect | PhysicsCategory.shield
        node.physicsBody?.collisionBitMask = PhysicsCategory.striker | PhysicsCategory.opponent | PhysicsCategory.wall | PhysicsCategory.arenaEffect | PhysicsCategory.shield
        node.zPosition = 12

        let seam = SKShapeNode(circleOfRadius: ballRadius * 0.48)
        seam.strokeColor = UIColor(hex: "#1B202B").withAlphaComponent(0.45)
        seam.lineWidth = 1.4
        seam.zPosition = 13
        node.addChild(seam)
        return node
    }

    private func createCrowdBoard() {
        let board = CrowdBoardNode(rect: crowdRect, seed: configuration.seed ^ 0xA11CE)
        board.onReward = { [weak self] reward in
            self?.applyCrowdReward(reward)
        }
        crowdBoard = board
        addChild(board)
    }

    private func createRoarButtons() {
        let buttonSize = CGSize(width: 62, height: 32)
        let y = fieldRect.minY + 25
        let buttons: [(RoarLane, CGFloat, String)] = [
            (.left, fieldRect.minX + 48, "LEFT"),
            (.center, fieldRect.midX, "ROAR"),
            (.right, fieldRect.maxX - 48, "RIGHT")
        ]

        for (lane, x, title) in buttons {
            let button = SKShapeNode(rectOf: buttonSize, cornerRadius: 8)
            button.name = "roarButton.\(lane.rawValue)"
            button.position = CGPoint(x: x, y: y)
            button.fillColor = UIColor(hex: "#F2C14E").withAlphaComponent(0.92)
            button.strokeColor = UIColor.white.withAlphaComponent(0.45)
            button.lineWidth = 2
            button.zPosition = 24
            roarButtonNodes[lane] = button

            let label = SKLabelNode(text: title)
            label.fontName = "AvenirNext-Heavy"
            label.fontSize = 10
            label.fontColor = UIColor(hex: "#111722")
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.zPosition = 25
            button.addChild(label)
            addChild(button)
        }
    }

    private func resetPositions() {
        strikerNode.position = CGPoint(x: fieldRect.minX + fieldRect.width * 0.24, y: fieldRect.midY)
        opponentNode.position = CGPoint(x: fieldRect.maxX - fieldRect.width * 0.20, y: fieldRect.midY)
        ballNode.position = CGPoint(x: fieldRect.midX, y: fieldRect.midY)
        [strikerNode, opponentNode, ballNode].forEach { node in
            node.physicsBody?.velocity = .zero
            node.physicsBody?.angularVelocity = 0
        }
        isResettingAfterGoal = false
        lastBallActiveTime = sceneTime
    }

    private func applyCrowdReward(_ reward: CrowdReward) {
        roarController.addEnergy(reward.roarEnergy)
        pendingPowerMultiplier = max(pendingPowerMultiplier, reward.powerShotMultiplier)
        if reward.shieldDuration > 0 {
            applyShield(duration: reward.shieldDuration)
        }
        if reward.curveBonus > 0 {
            curveBonusUntil = sceneTime + 4
        }
        if reward.cleanBounceDuration > 0 {
            cleanBounceUntil = sceneTime + reward.cleanBounceDuration
            guideLineNode.strokeColor = UIColor(hex: "#F8F5E8")
        }
        comboController.addStyleScore(reward.styleScore)
        addBurst(at: CGPoint(x: crowdRect.midX, y: crowdRect.maxY - 24), color: UIColor(hex: "#F2C14E"))
        awardSkillEnergy(Double(reward.styleScore) / 8)
    }

    private func applyShield(duration: TimeInterval) {
        shieldUntil = max(shieldUntil, sceneTime + duration)
        shieldNode?.removeFromParent()

        let shield = SKShapeNode(rectOf: CGSize(width: 14, height: min(132, fieldRect.height * 0.26)), cornerRadius: 6)
        shield.name = "goalShield"
        shield.position = CGPoint(x: fieldRect.minX + 38, y: fieldRect.midY)
        shield.fillColor = UIColor(hex: "#2458E6").withAlphaComponent(0.42)
        shield.strokeColor = UIColor(hex: "#F8F5E8").withAlphaComponent(0.62)
        shield.lineWidth = 2
        shield.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 14, height: min(132, fieldRect.height * 0.26)))
        shield.physicsBody?.isDynamic = false
        shield.physicsBody?.restitution = 1.08
        shield.physicsBody?.categoryBitMask = PhysicsCategory.shield
        shield.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        shield.physicsBody?.collisionBitMask = PhysicsCategory.ball
        shield.zPosition = 6
        shieldNode = shield
        addChild(shield)
    }

    private func updateShield(currentTime: TimeInterval) {
        if currentTime > shieldUntil {
            shieldNode?.run(.sequence([.fadeOut(withDuration: 0.15), .removeFromParent()]))
            shieldNode = nil
        }
    }

    private func updateClock(currentTime: TimeInterval) {
        guard let phaseStartTime else { return }
        let phaseDuration = isOvertime ? configuration.rules.goldenGoalDuration : configuration.rules.duration
        let elapsed = currentTime - phaseStartTime

        if elapsed >= phaseDuration {
            if !isOvertime && playerScore == opponentScore {
                isOvertime = true
                self.phaseStartTime = currentTime
                addBurst(at: ballNode.position, color: UIColor(hex: "#F2C14E"))
            } else {
                endMatch()
            }
        }
    }

    private func updateRoarWaves(deltaTime: TimeInterval, currentTime: TimeInterval) {
        guard deltaTime >= 0 else { return }

        for wave in roarController.activeWaves {
            let distance = ballNode.position.distance(to: wave.origin)
            let radius = wave.radius(at: currentTime)
            guard abs(distance - radius) < 44 else { continue }

            let direction: CGVector
            switch wave.lane {
            case .left:
                direction = CGVector(dx: 1, dy: wave.curve)
            case .center:
                direction = CGVector(dx: ballNode.position.x - wave.origin.x, dy: ballNode.position.y - wave.origin.y + wave.curve * 120).normalized()
            case .right:
                direction = CGVector(dx: -1, dy: -wave.curve)
            }

            let multiplier: CGFloat = sceneTime < turboUntil ? 1.25 : 1
            ballNode.physicsBody?.applyImpulse(direction.normalized() * (wave.force * 0.022 * multiplier))
        }

        if sceneTime > cleanBounceUntil {
            guideLineNode.strokeColor = UIColor.white.withAlphaComponent(0.24)
        }
    }

    private func updateOpponent(currentTime: TimeInterval) {
        guard currentTime >= nextOpponentKickTime, !isResettingAfterGoal else { return }

        let target = ballNode.position
        let vector = CGVector(dx: target.x - opponentNode.position.x, dy: target.y - opponentNode.position.y)
        if vector.length > 4 {
            let defenseBias = opponentNation.aiProfile.defense
            let force = CGFloat(19 + defenseBias * 16)
            opponentNode.physicsBody?.applyImpulse(vector.normalized() * force)
        }

        if target.distance(to: opponentNode.position) < 62 {
            let shot = CGVector(dx: fieldRect.minX - target.x, dy: fieldRect.midY - target.y + generator.nextSignedUnit() * 58)
            ballNode.physicsBody?.applyImpulse(shot.normalized() * CGFloat(12 + opponentNation.baseStats.power * 10))
        }

        nextOpponentKickTime = currentTime + 0.9 + Double(generator.nextUnit()) * 0.55
    }

    private func updateBallSafety(currentTime: TimeInterval) {
        let velocity = ballNode.physicsBody?.velocity ?? .zero
        if velocity.length > 18 {
            lastBallActiveTime = currentTime
        }

        guard currentTime - lastBallActiveTime > 2.0, !isResettingAfterGoal else { return }
        let nudge = CGVector(dx: generator.nextSignedUnit() * 22, dy: generator.nextSignedUnit() * 22)
        ballNode.physicsBody?.applyImpulse(nudge)
        comboController.resetSoftly()
        lastBallActiveTime = currentTime
    }

    private func updateGuide() {
        guard touchMode == .aiming || sceneTime < cleanBounceUntil || configuration.arenaID == .precisionGrid else {
            guideLineNode.path = nil
            return
        }

        let origin = strikerNode.position
        let vector = touchMode == .aiming
            ? CGVector(dx: origin.x - currentTouchLocation.x, dy: origin.y - currentTouchLocation.y)
            : CGVector(dx: ballNode.position.x - origin.x, dy: ballNode.position.y - origin.y)
        let length = min(sceneTime < cleanBounceUntil ? 220 : 130, max(20, vector.length * 1.2))
        let end = origin + vector.normalized() * length
        let path = CGMutablePath()
        path.move(to: origin)
        path.addLine(to: end)
        guideLineNode.path = path
    }

    private func updateAimArrow(to touchLocation: CGPoint) {
        let vector = CGVector(dx: strikerNode.position.x - touchLocation.x, dy: strikerNode.position.y - touchLocation.y)
        let length = min(120, vector.length)
        let direction = vector.normalized()
        let end = strikerNode.position + direction * length

        let path = CGMutablePath()
        path.move(to: strikerNode.position)
        path.addLine(to: end)
        path.move(to: end)
        path.addLine(to: end + direction.rotated(by: 2.55) * 15)
        path.move(to: end)
        path.addLine(to: end + direction.rotated(by: -2.55) * 15)
        aimArrowNode.path = path
        updateGuide()
    }

    private func launchStriker(from touchLocation: CGPoint) {
        guard canPlayerLaunch else { return }
        let pull = CGVector(dx: strikerNode.position.x - touchLocation.x, dy: strikerNode.position.y - touchLocation.y)
        let clampedLength = min(124, pull.length)
        guard clampedLength > 12 else { return }

        let statMultiplier = CGFloat(0.92 + playerNation.baseStats.power * 0.30)
        let turboMultiplier: CGFloat = sceneTime < turboUntil ? 1.32 : 1
        let impulse = pull.normalized() * (clampedLength * 0.78 * statMultiplier * turboMultiplier)
        strikerNode.physicsBody?.applyImpulse(impulse)
        lastPlayerLaunchTime = sceneTime
    }

    private func handleArenaEffectContact(_ effectNode: SKNode?) {
        let name = effectNode?.name
        comboController.registerHit(named: name)

        switch name {
        case "postBumper":
            let multiplier: CGFloat = sceneTime < cleanBounceUntil ? 1.10 : 1.18
            applyBallVelocityMultiplier(multiplier, curve: 0)
            addBurst(at: ballNode.position, color: UIColor(hex: "#F2C14E"))
        case "adBoard":
            effectNode?.run(.sequence([.rotate(byAngle: 0.22, duration: 0.06), .rotate(byAngle: -0.22, duration: 0.10)]))
            applyBallVelocityMultiplier(1.08, curve: 0.08)
        case "cornerSpring":
            applyBallVelocityMultiplier(1.26, curve: 0.12)
            addBurst(at: ballNode.position, color: UIColor(hex: "#17B978"))
        case "temporaryBumper":
            applyBallVelocityMultiplier(1.28, curve: 0.20)
        default:
            applyBallVelocityMultiplier(1.04, curve: 0)
        }
    }

    private func handleGoal(named goalName: String?) {
        guard let goalName else { return }
        isResettingAfterGoal = true

        let playerScored = goalName == "rightGoal"
        if playerScored {
            playerScore += 1
            awardSkillEnergy(24)
            roarController.addEnergy(18)
        } else {
            opponentScore += 1
            awardSkillEnergy(30)
            roarController.addEnergy(24)
        }

        let finishedCombo = comboController.registerGoal(playerScored: playerScored)
        if finishedCombo >= 5 || currentRemainingTime <= 4 {
            addSlowMotionPulse()
        }

        addBurst(at: ballNode.position, color: UIColor(hex: "#F2C14E"))

        if isOvertime || configuration.rules.maxGoals.map({ max(playerScore, opponentScore) >= $0 }) == true {
            endMatch(delay: 0.45)
        } else {
            run(.sequence([
                .wait(forDuration: 0.8),
                .run { [weak self] in self?.resetPositions() }
            ]))
        }
    }

    private func endMatch(delay: TimeInterval = 0) {
        guard !isMatchFinished else { return }
        isMatchFinished = true

        let finish = { [weak self] in
            guard let self else { return }
            let elapsed = self.absoluteStartTime.map { self.sceneTime - $0 } ?? self.configuration.rules.duration
            let combo = self.comboController.snapshot
            let result = MatchResult(
                configuration: self.configuration,
                playerScore: self.playerScore,
                opponentScore: self.opponentScore,
                duration: elapsed,
                headline: self.makeHeadline(maxCombo: combo.max, styleScore: combo.styleScore),
                chaosScore: combo.styleScore,
                maxCombo: combo.max,
                coinsEarned: self.coinsEarned(maxCombo: combo.max, styleScore: combo.styleScore)
            )
            self.onMatchEnd?(result)
        }

        if delay > 0 {
            run(.sequence([.wait(forDuration: delay), .run(finish)]))
        } else {
            finish()
        }
    }

    private func drawWave(_ wave: SoundWave) {
        let ring = SKShapeNode(circleOfRadius: 12)
        ring.position = wave.origin
        ring.strokeColor = UIColor(hex: "#F2C14E").withAlphaComponent(0.72)
        ring.lineWidth = 4
        ring.zPosition = 20
        addChild(ring)
        ring.run(.sequence([
            .group([
                .scale(to: wave.maxRadius / 12, duration: wave.duration),
                .fadeOut(withDuration: wave.duration)
            ]),
            .removeFromParent()
        ]))
    }

    private func createTemporaryBumper() {
        let bumper = SKShapeNode(circleOfRadius: 22)
        bumper.name = "temporaryBumper"
        bumper.position = clamp(midpoint(strikerNode.position, ballNode.position), inset: 40)
        bumper.fillColor = UIColor(hex: "#F0524F")
        bumper.strokeColor = UIColor(hex: "#FFF4D6")
        bumper.lineWidth = 3
        bumper.physicsBody = SKPhysicsBody(circleOfRadius: 22)
        bumper.physicsBody?.isDynamic = false
        bumper.physicsBody?.restitution = 1.22
        bumper.physicsBody?.categoryBitMask = PhysicsCategory.arenaEffect
        bumper.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        bumper.physicsBody?.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.striker | PhysicsCategory.opponent
        bumper.zPosition = 5
        addChild(bumper)
        addBurst(at: bumper.position, color: UIColor(hex: "#F0524F"))
        bumper.run(.sequence([.wait(forDuration: 4.0), .fadeOut(withDuration: 0.18), .removeFromParent()]))
    }

    private func addSlowMotionPulse() {
        physicsWorld.speed = 0.68
        run(.sequence([
            .wait(forDuration: 0.25),
            .run { [weak self] in self?.physicsWorld.speed = 1.0 }
        ]))
    }

    private func addBurst(at position: CGPoint, color: UIColor) {
        let ring = SKShapeNode(circleOfRadius: 10)
        ring.position = position
        ring.strokeColor = color.withAlphaComponent(0.90)
        ring.lineWidth = 4
        ring.zPosition = 40
        addChild(ring)
        ring.run(.sequence([
            .group([.scale(to: 3.4, duration: 0.30), .fadeOut(withDuration: 0.30)]),
            .removeFromParent()
        ]))
    }

    private func emitSnapshot() {
        let combo = comboController.snapshot
        onSnapshot?(MatchSnapshot(
            playerScore: playerScore,
            opponentScore: opponentScore,
            remainingTime: currentRemainingTime,
            skillEnergy: skillEnergy,
            roarEnergy: roarController.energy,
            roarHeat: roarController.heat,
            combo: combo.current,
            maxCombo: combo.max,
            isOvertime: isOvertime,
            phaseName: isOvertime ? "Golden Goal" : configuration.mode.displayName
        ))
    }

    private func makeHeadline(maxCombo: Int, styleScore: Int) -> String {
        if maxCombo >= 8 { return "\(maxCombo)-hit post riot. Totally intended." }
        if playerScore > opponentScore && styleScore > 120 { return "The crowd pushed that one in." }
        if playerScore > opponentScore { return playerNation.replayPhrases.randomElement() ?? "The posts did the paperwork." }
        if playerScore == opponentScore { return "No winner, plenty of noise." }
        return "One more bounce and it was history."
    }

    private func awardSkillEnergy(_ amount: Double) {
        skillEnergy = min(100, skillEnergy + max(0, amount))
    }

    private func applyBallVelocityMultiplier(_ multiplier: CGFloat, curve: CGFloat) {
        guard var velocity = ballNode.physicsBody?.velocity else { return }
        velocity.dx *= multiplier
        velocity.dy *= multiplier
        if curve != 0 {
            let perpendicular = CGVector(dx: -velocity.dy, dy: velocity.dx).normalized() * (velocity.length * curve)
            velocity.dx += perpendicular.dx
            velocity.dy += perpendicular.dy
        }
        ballNode.physicsBody?.velocity = velocity
    }

    private func roarLane(at point: CGPoint) -> RoarLane? {
        roarButtonNodes.first { _, node in node.frame.insetBy(dx: -8, dy: -8).contains(point) }?.key
    }

    private var currentRemainingTime: TimeInterval {
        guard let phaseStartTime else { return configuration.rules.duration }
        let duration = isOvertime ? configuration.rules.goldenGoalDuration : configuration.rules.duration
        return max(0, duration - (sceneTime - phaseStartTime))
    }

    private var canPlayerLaunch: Bool {
        !isMatchFinished && !isResettingAfterGoal && sceneTime - lastPlayerLaunchTime >= 0.42
    }

    private var baseBallDamping: CGFloat {
        configuration.arenaID == .iceRink ? 0.25 : 0.35
    }

    private func coinsEarned(maxCombo: Int, styleScore: Int) -> Int {
        var coins = 18 + min(60, maxCombo * 4) + min(50, styleScore / 18)
        if playerScore > opponentScore { coins += 28 }
        if configuration.mode == .dailyClash { coins += 18 }
        return coins
    }

    private func has(_ a: UInt32, _ b: UInt32, _ x: UInt32, _ y: UInt32) -> Bool {
        (a == x && b == y) || (a == y && b == x)
    }

    private func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    }

    private func clamp(_ point: CGPoint, inset: CGFloat) -> CGPoint {
        CGPoint(
            x: min(fieldRect.maxX - inset, max(fieldRect.minX + inset, point.x)),
            y: min(fieldRect.maxY - inset, max(fieldRect.minY + inset, point.y))
        )
    }
}

extension CGVector {
    var length: CGFloat {
        sqrt(dx * dx + dy * dy)
    }

    func normalized() -> CGVector {
        let length = self.length
        guard length > 0.0001 else { return .zero }
        return CGVector(dx: dx / length, dy: dy / length)
    }

    func rotated(by radians: CGFloat) -> CGVector {
        CGVector(
            dx: dx * cos(radians) - dy * sin(radians),
            dy: dx * sin(radians) + dy * cos(radians)
        )
    }

    static func * (vector: CGVector, scalar: CGFloat) -> CGVector {
        CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        hypot(x - point.x, y - point.y)
    }

    static func + (point: CGPoint, vector: CGVector) -> CGPoint {
        CGPoint(x: point.x + vector.dx, y: point.y + vector.dy)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let sanitized = hex.replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        if sanitized.count == 6 {
            self.init(
                red: CGFloat((value & 0xFF0000) >> 16) / 255,
                green: CGFloat((value & 0x00FF00) >> 8) / 255,
                blue: CGFloat(value & 0x0000FF) / 255,
                alpha: 1
            )
        } else {
            self.init(white: 1, alpha: 1)
        }
    }
}

