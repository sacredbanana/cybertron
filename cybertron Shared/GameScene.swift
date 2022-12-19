//
//  GameScene.swift
//  cybertron Shared
//
//  Created by Cameron Armstrong on 17/12/2022.
//

import SpriteKit

let heroCategory: UInt32 = 1 << 0
let friendlyFireCategory: UInt32 = 1 << 1
let enemyCategory: UInt32 = 1 << 2
let sceneBorderCategory: UInt32 = 1 << 3

class GameScene: SKScene, SKPhysicsContactDelegate {
    fileprivate var hero : Hero?
    
    fileprivate var scoreLabel: SKLabelNode?
    
    fileprivate var livesLabel: SKLabelNode?
    
    fileprivate let movementSpeed: CGFloat = 10
    
    fileprivate var movementDirection: CGVector = .zero
    
    fileprivate var fireDirection: CGVector = .init(dx: 1.0, dy: 0.0)
    
    fileprivate var activeTapLocation: CGPoint?
    
    fileprivate var score: UInt32 = 0 {
        didSet {
            scoreLabel?.text = "Score: \(score)"
        }
    }
    
    fileprivate var lives: UInt32 = 5 {
        didSet {
            livesLabel?.text = "Lives: \(lives)"
        }
    }
    
    #if os(OSX)
    fileprivate var upPressed: Bool = false

    fileprivate var downPressed: Bool = false

    fileprivate var leftPressed: Bool = false

    fileprivate var rightPressed: Bool = false
    #endif
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        
        return scene
    }
    
    func setUpScene() {
        let resolution = SKUniform(name: "v2Resolution", vectorFloat2: .init(x: Float(frame.width), y: Float(frame.height)))
    
        physicsWorld.contactDelegate = self
        physicsBody = .init(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = sceneBorderCategory
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 0
        name = "scene"
        shouldEnableEffects = true
        let sceneShader = SKShader(fileNamed: "scene")
        shader = sceneShader
        
        
        scoreLabel = .init(fontNamed: "Chalkboard")
        guard let scoreLabel = scoreLabel else { fatalError("Error creating score label") }
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 100
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = .init(x: frame.minX + 100, y: frame.maxY - 100)
        addChild(scoreLabel)
        
        livesLabel = .init(fontNamed: "Chalkboard")
        guard let livesLabel = livesLabel else { fatalError("Error creating lives label") }
        livesLabel.text = "Lives: \(lives)"
        livesLabel.fontSize = 100
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.position = .init(x: frame.maxX - 400, y: frame.maxY - 100)
        addChild(livesLabel)
        
        hero = .init()
        guard let hero = hero else { fatalError("Error creating hero") }
        hero.physicsBody?.categoryBitMask = heroCategory
        hero.physicsBody?.collisionBitMask = enemyCategory | sceneBorderCategory
        
        addChild(hero)
        
        let uniforms: [SKUniform] = [
            SKUniform(name: "u_speed", float: 1),
            SKUniform(name: "u_strength", float: 3),
            SKUniform(name: "u_frequency", float: 20)
        ]
        
        let heroShader = SKShader(fileNamed: "hero")
        heroShader.uniforms = uniforms
        hero.shader = heroShader
                
        let background = SKShapeNode(rect: frame)
        background.name = "background"
        background.strokeColor = .clear
        
        let backgroundShader = SKShader(fileNamed: "background-level1")
        backgroundShader.uniforms = [resolution]
        background.fillShader = backgroundShader
        addChild(background)
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            let friendlyFire = SKSpriteNode(imageNamed: "weapon-normal")
            friendlyFire.name = "friendlyFire normal"
            friendlyFire.setScale(2.0)
            friendlyFire.physicsBody = .init(rectangleOf: .init(width: 2.0, height: 3.0))
            friendlyFire.physicsBody?.categoryBitMask = friendlyFireCategory
            friendlyFire.physicsBody?.collisionBitMask = enemyCategory
            friendlyFire.physicsBody?.contactTestBitMask = enemyCategory | sceneBorderCategory
            friendlyFire.position = hero.position
            friendlyFire.run(.sequence([.rotate(byAngle: -atan(self.fireDirection.dx/self.fireDirection.dy), duration: 0.0),
                                        .applyForce(self.fireDirection, duration: 1.0),
                                        .wait(forDuration: 2),
                                        .removeFromParent()]))
            self.addChild(friendlyFire)
        }
        
        for enemy in children where enemy is Enemy {
            (enemy as? Enemy)?.activateAI()
        }
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    fileprivate func hitEnemy(_ enemy: Enemy, contactPoint: CGPoint) {
        enemy.hit(damage: 1)
        if enemy.isDead {
            score += enemy.pointWorth
            guard let explosion = SKEmitterNode(fileNamed: "Explosion Regular") else { fatalError("Error loading explosion")}
            explosion.position = contactPoint
            addChild(explosion)
            explosion.run(.sequence([.wait(forDuration: 1.0),
                                     .run {
                                         explosion.particleBirthRate = 0
                                     },
                                     .wait(forDuration: 2.0),
                                     .removeFromParent()]))
            
            enemy.removeFromParent()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        switch contactMask {
        case heroCategory | enemyCategory:
            die()
        case friendlyFireCategory | enemyCategory:
            guard let enemy = (contact.bodyA.categoryBitMask == enemyCategory ? contact.bodyA.node : contact.bodyB.node) as? Enemy else { return }
            hitEnemy(enemy, contactPoint: contact.contactPoint)
        default:
            break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let tapLocation = activeTapLocation, let hero = hero {
            movementDirection = .init(dx: tapLocation.x - hero.position.x, dy: tapLocation.y - hero.position.y)
            movementDirection = normalize(movementDirection)
            let distanceSquared = pow(tapLocation.x - hero.position.x, 2) + pow(tapLocation.y - hero.position.y, 2)
            if distanceSquared > 1 {
                hero.position.x += movementSpeed * movementDirection.dx
                hero.position.y += movementSpeed * movementDirection.dy
            }
        } else {
            movementDirection = normalize(movementDirection)
            hero?.position.x += movementSpeed * movementDirection.dx
            hero?.position.y += movementSpeed * movementDirection.dy
        }
        
        if movementDirection != .zero {
            fireDirection = movementDirection
        }
        
        for enemy in children where enemy is Enemy {
            (enemy as? Enemy)?.heroPosition = hero?.position ?? .zero
        }
    }
    
    fileprivate func normalize(_ vector: CGVector) -> CGVector {
        let length = sqrt(pow(vector.dx, 2) + pow(vector.dy, 2))
        if length == 0 {
            return .zero
        } else {
            return .init(dx: vector.dx/length, dy: vector.dy/length)
        }
    }
    
    fileprivate func die() {
        lives = lives - 1
        hero?.position = .zero
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.green)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.blue)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        activeTapLocation = event.location(in: self)
    }
    
    override func mouseDragged(with event: NSEvent) {
        activeTapLocation = event.location(in: self)
    }
    
    override func mouseUp(with event: NSEvent) {
        activeTapLocation = nil
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            leftPressed = true
        case 124:
            rightPressed = true
        case 125:
            downPressed = true
        case 126:
            upPressed = true
        default:
            break
        }
        
        setMovementDirectionForKeyboard()
    }
        
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            leftPressed = false
        case 124:
            rightPressed = false
        case 125:
            downPressed = false
        case 126:
            upPressed = false
        default:
            break
        }
        
        setMovementDirectionForKeyboard()
    }
    
    fileprivate func setMovementDirectionForKeyboard() {
        var xDirection: CGFloat = 0.0
        var yDirection: CGFloat = 0.0
        
        if leftPressed {
            xDirection -= 1.0
        }
        if rightPressed {
            xDirection += 1.0
        }
        if upPressed {
            yDirection += 1.0
        }
        if downPressed {
            yDirection -= 1.0
        }
    
        movementDirection = .init(dx: xDirection, dy: yDirection)
    }

}
#endif

