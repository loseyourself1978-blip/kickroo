import SpriteKit
import UIKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    var onSnapshot: ((MatchSnapshot) -> Void)?
    var onMatchEnd: ((MatchResult) -> Void)?

    private enum TouchMode {
        case aiming
    }

    private let configuration: MatchConfiguration
    private let playerNation: Nation
    private let opponentNation: Nation
    private let comboController = ComboController()
    private let roarController = RoarController()
    private let audioService = ProceduralAudioService.shared
    private var generator: SeededRandomGenerator

    private var fieldRect = CGRect.zero
    private var configuredSize = CGSize.zero

    private let strikerRadius: CGFloat = 25
    private let opponentRadius: CGFloat = 24
    private let ballRadius: CGFloat = 15

    private var strikerNode = SKShapeNode()
    private var opponentNode = SKShapeNode()
    private var ballNode = SKShapeNode()
    private var aimArrowNode = SKShapeNode()
    private var guideLineNode = SKShapeNode()
    private var powerBarBackNode = SKShapeNode()
    private var powerBarFillNode = SKShapeNode()
    private var shieldNode: SKShapeNode?
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
    private var aimChargeStartTime: TimeInterval?
    private var pendingPowerMultiplier: CGFloat = 1
    private var curveBonusUntil: TimeInterval = 0
    private var cleanBounceUntil: TimeInterval = 0
    private var shieldUntil: TimeInterval = 0
    private var turboUntil: TimeInterval = 0
    private var lastContactSoundTime: TimeInterval = -10

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
        audioService.play(.crowdLoop)
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
        updateAimCharge()
        updateGuide()
        emitSnapshot()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isMatchFinished, let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let lane = roarLane(at: location) {
            triggerRoar(lane)
            return
        }

        guard canPlayerLaunch, fieldRect.contains(location) else { return }
        touchMode = .aiming
        currentTouchLocation = clamp(location, inset: 24)
        aimChargeStartTime = sceneTime
        updateAimArrow(to: currentTouchLocation)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        switch touchMode {
        case .aiming:
            currentTouchLocation = clamp(location, inset: 24)
            updateAimArrow(to: currentTouchLocation)
        case nil:
            break
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch touchMode {
        case .aiming:
            launchStriker(from: currentTouchLocation)
            aimArrowNode.path = nil
            hidePowerBar()
        case nil:
            break
        }
        touchMode = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchMode = nil
        aimArrowNode.path = nil
        hidePowerBar()
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
        audioService.play(.roar)
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
            playContactSound()
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
            playContactSound()
            comboController.registerHit(named: "wall")
        }

        if has(a, b, PhysicsCategory.ball, PhysicsCategory.arenaEffect) {
            playContactSound()
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

        let bottomInset: CGFloat = 86
        let topInset: CGFloat = 82
        fieldRect = CGRect(
            x: 16,
            y: bottomInset,
            width: size.width - 32,
            height: size.height - bottomInset - topInset
        )

        drawBackground()
        drawField()
        createPhysicsBounds()
        PinballArenaController(arenaID: configuration.arenaID, rules: configuration.rules, seed: configuration.seed).build(in: self, fieldRect: fieldRect)
        createActors()
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

        let cupGlow = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        cupGlow.fillColor = UIColor(hex: "#0A1730").withAlphaComponent(0.30)
        cupGlow.strokeColor = .clear
        cupGlow.zPosition = -45
        addChild(cupGlow)
    }

    private func drawField() {
        let field = SKShapeNode(rect: fieldRect, cornerRadius: 8)
        field.fillColor = UIColor(hex: "#0F5B43")
        field.strokeColor = UIColor.white.withAlphaComponent(0.18)
        field.lineWidth = 3
        field.zPosition = -20
        addChild(field)

        let stripeCount = 9
        for index in 0..<stripeCount {
            let stripeHeight = fieldRect.height / CGFloat(stripeCount)
            let stripe = SKShapeNode(rect: CGRect(
                x: fieldRect.minX,
                y: fieldRect.minY + CGFloat(index) * stripeHeight,
                width: fieldRect.width,
                height: stripeHeight
            ))
            stripe.fillColor = UIColor.white.withAlphaComponent(index.isMultiple(of: 2) ? 0.025 : 0.0)
            stripe.strokeColor = .clear
            stripe.zPosition = -19
            addChild(stripe)
        }

        let centerPath = CGMutablePath()
        centerPath.move(to: CGPoint(x: fieldRect.minX, y: fieldRect.midY))
        centerPath.addLine(to: CGPoint(x: fieldRect.maxX, y: fieldRect.midY))
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

        drawPenaltyBox(isTop: true)
        drawPenaltyBox(isTop: false)
        addChild(goalNode(name: "topGoal", y: fieldRect.maxY - 5, isTop: true))
        addChild(goalNode(name: "bottomGoal", y: fieldRect.minY + 5, isTop: false))
    }

    private func drawPenaltyBox(isTop: Bool) {
        let boxSize = CGSize(width: fieldRect.width * 0.50, height: fieldRect.height * 0.14)
        let y = isTop ? fieldRect.maxY - boxSize.height / 2 : fieldRect.minY + boxSize.height / 2
        let box = SKShapeNode(rectOf: boxSize, cornerRadius: 16)
        box.position = CGPoint(x: fieldRect.midX, y: y)
        box.strokeColor = UIColor.white.withAlphaComponent(0.17)
        box.fillColor = .clear
        box.lineWidth = 2
        box.zPosition = -17
        addChild(box)
    }

    private func goalNode(name: String, y: CGFloat, isTop: Bool) -> SKNode {
        let container = SKNode()
        container.name = name
        container.position = CGPoint(x: fieldRect.midX, y: y)
        container.zPosition = 3

        let mouthWidth = min(170, fieldRect.width * 0.50)
        let netDepth: CGFloat = 38
        let postHeight: CGFloat = 42
        let postWidth: CGFloat = 8
        let direction: CGFloat = isTop ? -1 : 1

        let netRect = CGRect(x: -mouthWidth / 2, y: direction < 0 ? -netDepth : 0, width: mouthWidth, height: netDepth)
        let net = SKShapeNode(rect: netRect, cornerRadius: 4)
        net.fillColor = UIColor.white.withAlphaComponent(0.07)
        net.strokeColor = UIColor.white.withAlphaComponent(0.30)
        net.lineWidth = 2
        net.zPosition = -1
        container.addChild(net)

        let meshPath = CGMutablePath()
        let step: CGFloat = 18
        var x = netRect.minX + step
        while x < netRect.maxX {
            meshPath.move(to: CGPoint(x: x, y: netRect.minY))
            meshPath.addLine(to: CGPoint(x: x, y: netRect.maxY))
            x += step
        }
        var meshY = netRect.minY + step
        while meshY < netRect.maxY {
            meshPath.move(to: CGPoint(x: netRect.minX, y: meshY))
            meshPath.addLine(to: CGPoint(x: netRect.maxX, y: meshY))
            meshY += step
        }
        let mesh = SKShapeNode(path: meshPath)
        mesh.strokeColor = UIColor.white.withAlphaComponent(0.18)
        mesh.lineWidth = 1
        mesh.zPosition = 0
        container.addChild(mesh)

        let crossbar = goalPost(size: CGSize(width: mouthWidth + postWidth, height: postWidth), name: "goalPostBumper")
        crossbar.position = CGPoint(x: 0, y: 0)
        container.addChild(crossbar)

        for x in [-mouthWidth / 2, mouthWidth / 2] {
            let post = goalPost(size: CGSize(width: postWidth, height: postHeight), name: "goalPostBumper")
            post.position = CGPoint(x: x, y: direction * postHeight / 2)
            container.addChild(post)
        }

        let trigger = SKNode()
        trigger.name = name
        trigger.position = CGPoint(x: 0, y: direction * netDepth * 0.46)
        trigger.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: mouthWidth - 20, height: netDepth * 0.74))
        trigger.physicsBody?.isDynamic = false
        trigger.physicsBody?.categoryBitMask = PhysicsCategory.goal
        trigger.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        trigger.physicsBody?.collisionBitMask = 0
        container.addChild(trigger)

        return container
    }

    private func goalPost(size: CGSize, name: String) -> SKShapeNode {
        let post = SKShapeNode(rectOf: size, cornerRadius: min(size.width, size.height) / 2)
        post.name = name
        post.fillColor = UIColor(hex: "#F2C14E")
        post.strokeColor = UIColor.white.withAlphaComponent(0.95)
        post.lineWidth = 2
        post.physicsBody = SKPhysicsBody(rectangleOf: size)
        post.physicsBody?.isDynamic = false
        post.physicsBody?.restitution = 1.78
        post.physicsBody?.categoryBitMask = PhysicsCategory.arenaEffect
        post.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        post.physicsBody?.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.striker | PhysicsCategory.opponent
        post.zPosition = 5
        return post
    }

    private func createPhysicsBounds() {
        let wallThickness: CGFloat = 10
        let goalGap = min(180, fieldRect.width * 0.54)
        let sideSegment = (fieldRect.width - goalGap) / 2

        addWall(center: CGPoint(x: fieldRect.minX, y: fieldRect.midY), size: CGSize(width: wallThickness, height: fieldRect.height))
        addWall(center: CGPoint(x: fieldRect.maxX, y: fieldRect.midY), size: CGSize(width: wallThickness, height: fieldRect.height))
        addWall(center: CGPoint(x: fieldRect.minX + sideSegment / 2, y: fieldRect.minY), size: CGSize(width: sideSegment, height: wallThickness))
        addWall(center: CGPoint(x: fieldRect.maxX - sideSegment / 2, y: fieldRect.minY), size: CGSize(width: sideSegment, height: wallThickness))
        addWall(center: CGPoint(x: fieldRect.minX + sideSegment / 2, y: fieldRect.maxY), size: CGSize(width: sideSegment, height: wallThickness))
        addWall(center: CGPoint(x: fieldRect.maxX - sideSegment / 2, y: fieldRect.maxY), size: CGSize(width: sideSegment, height: wallThickness))
    }

    private func addWall(center: CGPoint, size: CGSize) {
        let wall = SKNode()
        wall.position = center
        wall.physicsBody = SKPhysicsBody(rectangleOf: size)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.restitution = min(1.35, 0.90 * CGFloat(configuration.rules.reboundMultiplier))
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

        powerBarBackNode.zPosition = 31
        powerBarBackNode.fillColor = UIColor.black.withAlphaComponent(0.52)
        powerBarBackNode.strokeColor = UIColor.white.withAlphaComponent(0.20)
        powerBarBackNode.lineWidth = 1.5
        powerBarBackNode.isHidden = true

        powerBarFillNode.zPosition = 32
        powerBarFillNode.fillColor = UIColor(hex: "#F2C14E")
        powerBarFillNode.strokeColor = .clear
        powerBarFillNode.isHidden = true

        addChild(strikerNode)
        addChild(opponentNode)
        addChild(ballNode)
        addChild(guideLineNode)
        addChild(aimArrowNode)
        addChild(powerBarBackNode)
        addChild(powerBarFillNode)
    }

    private func characterNode(for nation: Nation, radius: CGFloat, category: UInt32, label: String) -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: radius)
        node.name = category == PhysicsCategory.striker ? "striker" : "opponent"
        node.fillColor = UIColor(hex: "#F2C79B")
        node.strokeColor = UIColor(hex: nation.palette.secondaryHex)
        node.lineWidth = 4
        node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        node.physicsBody?.mass = category == PhysicsCategory.striker ? 1.05 : 1.0
        node.physicsBody?.linearDamping = 0.90
        node.physicsBody?.angularDamping = 0.85
        node.physicsBody?.restitution = min(1.45, 0.74 * CGFloat(configuration.rules.reboundMultiplier))
        node.physicsBody?.allowsRotation = true
        node.physicsBody?.categoryBitMask = category
        node.physicsBody?.contactTestBitMask = PhysicsCategory.ball | PhysicsCategory.arenaEffect
        node.physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.ball | PhysicsCategory.striker | PhysicsCategory.opponent | PhysicsCategory.arenaEffect
        node.zPosition = 8

        let hair = SKShapeNode(ellipseOf: CGSize(width: radius * 1.55, height: radius * 0.72))
        hair.position = CGPoint(x: 0, y: radius * 0.32)
        hair.fillColor = UIColor(hex: "#1B202B")
        hair.strokeColor = .clear
        hair.zPosition = 9
        node.addChild(hair)

        let face = SKShapeNode(circleOfRadius: radius * 0.64)
        face.position = CGPoint(x: 0, y: radius * 0.18)
        face.fillColor = UIColor(hex: "#F2C79B")
        face.strokeColor = UIColor.white.withAlphaComponent(0.45)
        face.lineWidth = 1.4
        face.zPosition = 10
        node.addChild(face)

        let jersey = SKShapeNode(rectOf: CGSize(width: radius * 1.55, height: radius * 0.86), cornerRadius: radius * 0.24)
        jersey.position = CGPoint(x: 0, y: -radius * 0.58)
        jersey.fillColor = UIColor(hex: nation.palette.primaryHex)
        jersey.strokeColor = UIColor(hex: nation.palette.secondaryHex)
        jersey.lineWidth = 2
        jersey.zPosition = 11
        node.addChild(jersey)

        let sash = SKShapeNode(rectOf: CGSize(width: radius * 1.22, height: radius * 0.18), cornerRadius: radius * 0.07)
        sash.position = CGPoint(x: 0, y: -radius * 0.50)
        sash.fillColor = UIColor(hex: nation.palette.secondaryHex)
        sash.strokeColor = .clear
        sash.zRotation = -0.16
        sash.zPosition = 12
        node.addChild(sash)

        let leftEye = SKShapeNode(circleOfRadius: radius * 0.07)
        leftEye.position = CGPoint(x: -radius * 0.19, y: radius * 0.25)
        leftEye.fillColor = UIColor(hex: "#101622")
        leftEye.strokeColor = .clear
        leftEye.zPosition = 13
        node.addChild(leftEye)

        let rightEye = SKShapeNode(circleOfRadius: radius * 0.07)
        rightEye.position = CGPoint(x: radius * 0.19, y: radius * 0.25)
        rightEye.fillColor = UIColor(hex: "#101622")
        rightEye.strokeColor = .clear
        rightEye.zPosition = 13
        node.addChild(rightEye)

        let nationalTrait = SKLabelNode(text: nationalTraitSymbol(for: nation))
        nationalTrait.fontName = "AvenirNext-Heavy"
        nationalTrait.fontSize = radius * 0.44
        nationalTrait.fontColor = UIColor(hex: nation.palette.accentHex)
        nationalTrait.verticalAlignmentMode = .center
        nationalTrait.horizontalAlignmentMode = .center
        nationalTrait.position = CGPoint(x: 0, y: -radius * 0.58)
        nationalTrait.zPosition = 14
        node.addChild(nationalTrait)

        let code = SKLabelNode(text: nation.shortCode)
        code.fontName = "AvenirNext-Heavy"
        code.fontSize = radius * 0.28
        code.fontColor = UIColor(hex: nation.palette.accentHex)
        code.verticalAlignmentMode = .center
        code.horizontalAlignmentMode = .center
        code.position = CGPoint(x: 0, y: -radius * 0.94)
        code.zPosition = 14
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

    private func nationalTraitSymbol(for nation: Nation) -> String {
        switch nation.id {
        case .usa: "★"
        case .mexico: "◆"
        case .brazil: "◈"
        case .japan: "●"
        case .canada: "✦"
        case .morocco: "◇"
        case .argentina: "☀"
        case .france: "⚜"
        case .germany: "■"
        case .spain: "◎"
        case .england: "✚"
        case .portugal: "◒"
        case .netherlands: "▲"
        case .italy: "▰"
        default: nation.shortCode.prefix(1).uppercased()
        }
    }

    private func ball() -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: ballRadius)
        node.name = "ball"
        node.fillColor = UIColor(hex: "#F8F5E8")
        node.strokeColor = UIColor(hex: "#101622")
        node.lineWidth = 2.8
        node.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        node.physicsBody?.mass = 0.28
        node.physicsBody?.linearDamping = baseBallDamping
        node.physicsBody?.angularDamping = 0.20
        node.physicsBody?.restitution = min(1.70, 1.03 * CGFloat(configuration.rules.reboundMultiplier))
        node.physicsBody?.categoryBitMask = PhysicsCategory.ball
        node.physicsBody?.contactTestBitMask = PhysicsCategory.striker | PhysicsCategory.opponent | PhysicsCategory.wall | PhysicsCategory.goal | PhysicsCategory.arenaEffect | PhysicsCategory.shield
        node.physicsBody?.collisionBitMask = PhysicsCategory.striker | PhysicsCategory.opponent | PhysicsCategory.wall | PhysicsCategory.arenaEffect | PhysicsCategory.shield
        node.zPosition = 12

        let centerPatch = polygonNode(sides: 5, radius: ballRadius * 0.38)
        centerPatch.fillColor = UIColor(hex: "#101622")
        centerPatch.strokeColor = .clear
        centerPatch.zPosition = 13
        node.addChild(centerPatch)

        for index in 0..<5 {
            let angle = CGFloat(index) * (.pi * 2 / 5) - .pi / 2
            let patch = polygonNode(sides: 5, radius: ballRadius * 0.20)
            patch.position = CGPoint(x: cos(angle) * ballRadius * 0.66, y: sin(angle) * ballRadius * 0.66)
            patch.fillColor = UIColor(hex: "#101622")
            patch.strokeColor = .clear
            patch.zRotation = angle
            patch.zPosition = 13
            node.addChild(patch)
        }

        let seam = SKShapeNode(circleOfRadius: ballRadius * 0.74)
        seam.strokeColor = UIColor(hex: "#101622").withAlphaComponent(0.42)
        seam.lineWidth = 1.2
        seam.zPosition = 14
        node.addChild(seam)
        return node
    }

    private func polygonNode(sides: Int, radius: CGFloat) -> SKShapeNode {
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
        return SKShapeNode(path: path)
    }

    private func createRoarButtons() {
        let buttonSize = CGSize(width: 66, height: 34)
        let y = fieldRect.minY + 22
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
        strikerNode.position = CGPoint(x: fieldRect.midX, y: fieldRect.minY + fieldRect.height * 0.18)
        opponentNode.position = CGPoint(x: fieldRect.midX, y: fieldRect.maxY - fieldRect.height * 0.18)
        ballNode.position = CGPoint(x: fieldRect.midX, y: fieldRect.midY)
        [strikerNode, opponentNode, ballNode].forEach { node in
            node.physicsBody?.velocity = .zero
            node.physicsBody?.angularVelocity = 0
        }
        hidePowerBar()
        isResettingAfterGoal = false
        lastBallActiveTime = sceneTime
    }

    private func applyShield(duration: TimeInterval) {
        shieldUntil = max(shieldUntil, sceneTime + duration)
        shieldNode?.removeFromParent()

        let shield = SKShapeNode(rectOf: CGSize(width: min(132, fieldRect.width * 0.38), height: 14), cornerRadius: 6)
        shield.name = "goalShield"
        shield.position = CGPoint(x: fieldRect.midX, y: fieldRect.minY + 44)
        shield.fillColor = UIColor(hex: "#2458E6").withAlphaComponent(0.42)
        shield.strokeColor = UIColor(hex: "#F8F5E8").withAlphaComponent(0.62)
        shield.lineWidth = 2
        shield.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: min(132, fieldRect.width * 0.38), height: 14))
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
            if playerScore == opponentScore && configuration.rules.allowsDraw {
                endMatch()
            } else if !isOvertime && playerScore == opponentScore {
                isOvertime = true
                self.phaseStartTime = currentTime
                addBurst(at: ballNode.position, color: UIColor(hex: "#F2C14E"))
            } else if isOvertime && playerScore == opponentScore && configuration.rules.requiresWinner {
                self.phaseStartTime = currentTime
                addBurst(at: ballNode.position, color: UIColor(hex: "#F0524F"))
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
                direction = CGVector(dx: 0.48 + wave.curve, dy: 1)
            case .center:
                direction = CGVector(dx: ballNode.position.x - wave.origin.x, dy: ballNode.position.y - wave.origin.y + wave.curve * 120).normalized()
            case .right:
                direction = CGVector(dx: -0.48 - wave.curve, dy: 1)
            }

            let multiplier: CGFloat = sceneTime < turboUntil ? 1.42 : 1.18
            ballNode.physicsBody?.applyImpulse(direction.normalized() * (wave.force * 0.040 * multiplier))
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
            let force = CGFloat(16 + defenseBias * 13)
            opponentNode.physicsBody?.applyImpulse(vector.normalized() * force)
        }

        if target.distance(to: opponentNode.position) < 62 {
            let shot = CGVector(dx: fieldRect.midX - target.x + generator.nextSignedUnit() * 78, dy: fieldRect.minY - target.y)
            ballNode.physicsBody?.applyImpulse(shot.normalized() * CGFloat(24 + opponentNation.baseStats.power * 15))
        }

        nextOpponentKickTime = currentTime + configuration.rules.opponentCadence + Double(generator.nextUnit()) * 0.55
    }

    private func updateBallSafety(currentTime: TimeInterval) {
        let velocity = ballNode.physicsBody?.velocity ?? .zero
        if velocity.length > 42 {
            lastBallActiveTime = currentTime
        }

        let idleLimit: TimeInterval = 0.82
        guard currentTime - lastBallActiveTime > idleLimit, !isResettingAfterGoal else { return }
        let towardOpenPlay = CGPoint(x: fieldRect.midX, y: fieldRect.midY).distance(to: ballNode.position) > fieldRect.height * 0.35
        let base = towardOpenPlay
            ? CGVector(dx: fieldRect.midX - ballNode.position.x, dy: fieldRect.midY - ballNode.position.y).normalized()
            : CGVector(dx: generator.nextSignedUnit(), dy: 0.85 + generator.nextUnit() * 0.45).normalized()
        let nudge = base * CGFloat(72 + generator.nextUnit() * 54)
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
            ? aimVector(to: currentTouchLocation)
            : CGVector(dx: ballNode.position.x - origin.x, dy: ballNode.position.y - origin.y)
        let aimingLength = 90 + currentShotPower * 95
        let length = min(sceneTime < cleanBounceUntil ? 230 : aimingLength, max(24, vector.length * 1.12))
        let end = origin + vector.normalized() * length
        let path = CGMutablePath()
        path.move(to: origin)
        path.addLine(to: end)
        guideLineNode.path = path
    }

    private func updateAimArrow(to touchLocation: CGPoint) {
        let vector = aimVector(to: touchLocation)
        let length = min(170, max(54, 70 + currentShotPower * 100))
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
        updatePowerBar(power: currentShotPower)
        updateGuide()
    }

    private func launchStriker(from touchLocation: CGPoint) {
        guard canPlayerLaunch else { return }
        let direction = aimVector(to: touchLocation).normalized()
        guard direction.length > 0 else { return }

        let statMultiplier = CGFloat(0.92 + playerNation.baseStats.power * 0.30)
        let turboMultiplier: CGFloat = sceneTime < turboUntil ? 1.32 : 1
        let modeMultiplier = CGFloat(configuration.rules.launchPowerMultiplier)
        let charge = max(0.28, currentShotPower)
        let impulseMagnitude = (120 + charge * 190) * statMultiplier * turboMultiplier * modeMultiplier
        let impulse = direction * impulseMagnitude
        strikerNode.physicsBody?.applyImpulse(impulse)
        if ballNode.position.distance(to: strikerNode.position) < 170 {
            ballNode.physicsBody?.applyImpulse(direction * (impulseMagnitude * 0.34))
        }
        lastPlayerLaunchTime = sceneTime
        audioService.play(.kick)
    }

    private func handleArenaEffectContact(_ effectNode: SKNode?) {
        let name = effectNode?.name
        comboController.registerHit(named: name)

        switch name {
        case "postBumper", "goalPostBumper":
            let multiplier: CGFloat = sceneTime < cleanBounceUntil ? 1.34 : 1.58
            applyBallVelocityMultiplier(multiplier, curve: 0)
            addBurst(at: ballNode.position, color: UIColor(hex: "#F2C14E"))
        case "adBoard":
            effectNode?.run(.sequence([.rotate(byAngle: 0.22, duration: 0.06), .rotate(byAngle: -0.22, duration: 0.10)]))
            applyBallVelocityMultiplier(1.28, curve: 0.12)
        case "cornerSpring":
            applyBallVelocityMultiplier(1.55, curve: 0.16)
            addBurst(at: ballNode.position, color: UIColor(hex: "#17B978"))
        case "refereeBlocker", "lineJudgeBlocker":
            applyBallVelocityMultiplier(1.36, curve: 0.13)
            effectNode?.run(.sequence([.scale(to: 1.10, duration: 0.05), .scale(to: 1.0, duration: 0.10)]))
        case "keeperBlocker":
            applyBallVelocityMultiplier(1.44, curve: -0.12)
            addBurst(at: ballNode.position, color: UIColor(hex: "#24A0ED"))
        case "flagBlocker", "miniPost":
            applyBallVelocityMultiplier(1.50, curve: 0.20)
            addBurst(at: ballNode.position, color: UIColor(hex: "#F0524F"))
        case "temporaryBumper":
            applyBallVelocityMultiplier(1.56, curve: 0.24)
        default:
            applyBallVelocityMultiplier(1.22, curve: 0.05)
        }
    }

    private func handleGoal(named goalName: String?) {
        guard let goalName else { return }
        isResettingAfterGoal = true

        let playerScored = goalName == "topGoal"
        if playerScored {
            playerScore += 1
            awardSkillEnergy(24)
            roarController.addEnergy(18)
            audioService.play(.goal)
        } else {
            opponentScore += 1
            awardSkillEnergy(30)
            roarController.addEnergy(24)
            audioService.play(.boo)
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
            phaseName: isOvertime ? "Golden Goal" : (configuration.cupContext?.hudTitle ?? configuration.mode.displayName),
            phaseDetail: isOvertime ? "Next goal wins" : (configuration.cupContext?.hudDetail ?? configuration.rules.phaseLabel ?? configuration.mode.shortRule)
        ))
    }

    private func makeHeadline(maxCombo: Int, styleScore: Int) -> String {
        if maxCombo >= 8 { return "\(maxCombo)-hit post riot. Totally intended." }
        if playerScore > opponentScore && styleScore > 120 { return "Lucky rails did exactly what you asked." }
        if playerScore > opponentScore { return playerNation.replayPhrases.randomElement() ?? "The posts did the paperwork." }
        if playerScore == opponentScore { return "No winner, plenty of noise." }
        return "One more bounce and it was history."
    }

    private func awardSkillEnergy(_ amount: Double) {
        skillEnergy = min(100, skillEnergy + max(0, amount))
    }

    private func playContactSound() {
        guard sceneTime - lastContactSoundTime > 0.08 else { return }
        lastContactSoundTime = sceneTime
        audioService.play(.bounce)
    }

    private var currentShotPower: CGFloat {
        guard touchMode == .aiming, let aimChargeStartTime else { return 0 }
        return min(1, max(0, CGFloat((sceneTime - aimChargeStartTime) / 0.82)))
    }

    private func aimVector(to point: CGPoint) -> CGVector {
        let vector = CGVector(dx: point.x - strikerNode.position.x, dy: point.y - strikerNode.position.y)
        if vector.length >= 14 {
            return vector
        }
        return CGVector(dx: ballNode.position.x - strikerNode.position.x, dy: ballNode.position.y - strikerNode.position.y)
    }

    private func updateAimCharge() {
        guard touchMode == .aiming else { return }
        updateAimArrow(to: currentTouchLocation)
    }

    private func updatePowerBar(power: CGFloat) {
        let width: CGFloat = 92
        let height: CGFloat = 9
        let fillWidth = max(3, width * min(1, max(0, power)))
        let yOffset: CGFloat = strikerNode.position.y > fieldRect.midY ? -42 : 42
        let center = clamp(strikerNode.position + CGVector(dx: 0, dy: yOffset), inset: 34)

        powerBarBackNode.position = center
        powerBarFillNode.position = center
        powerBarBackNode.path = CGPath(
            roundedRect: CGRect(x: -width / 2, y: -height / 2, width: width, height: height),
            cornerWidth: height / 2,
            cornerHeight: height / 2,
            transform: nil
        )
        powerBarFillNode.path = CGPath(
            roundedRect: CGRect(x: -width / 2, y: -height / 2, width: fillWidth, height: height),
            cornerWidth: height / 2,
            cornerHeight: height / 2,
            transform: nil
        )
        powerBarBackNode.isHidden = false
        powerBarFillNode.isHidden = false
    }

    private func hidePowerBar() {
        aimChargeStartTime = nil
        powerBarBackNode.isHidden = true
        powerBarFillNode.isHidden = true
        powerBarBackNode.path = nil
        powerBarFillNode.path = nil
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
        let arenaDamping: CGFloat = configuration.arenaID == .iceRink ? 0.10 : 0.16
        return arenaDamping
    }

    private func coinsEarned(maxCombo: Int, styleScore: Int) -> Int {
        var coins = 18 + min(60, maxCombo * 4) + min(50, styleScore / 18)
        if playerScore > opponentScore { coins += 28 }
        if configuration.mode == .globalCup { coins += 18 }
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
