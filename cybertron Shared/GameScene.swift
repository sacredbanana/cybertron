//
//  GameScene.swift
//  cybertron Shared
//
//  Created by Cameron Armstrong on 17/12/2022.
//

import SpriteKit

class GameScene: SKScene {
    fileprivate var hero : Hero?
    
    fileprivate let movementSpeed: CGFloat = 10
    
    fileprivate var movementDirection: CGVector = .zero
    
    fileprivate var fireDirection: CGVector = .init(dx: 1.0, dy: 0.0)
    
    fileprivate var activeTapLocation: CGPoint?
    
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
        physicsBody = .init(edgeLoopFrom: frame)
        name = "scene"
        hero = .init(lives: 5)
        guard let hero = hero else { fatalError("Error creating hero") }
        
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
        background.physicsBody = .init(edgeLoopFrom: background.frame)
        
        let backgroundShader = SKShader(fileNamed: "background-level1")
        let resolution = SKUniform(name: "v2Resolution", vectorFloat2: .init(x: Float(background.frame.width), y: Float(background.frame.height)))
        backgroundShader.uniforms = [resolution]
        background.fillShader = backgroundShader
        addChild(background)
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            let friendlyFire = SKSpriteNode(imageNamed: "weapon-normal")
            friendlyFire.name = "friendlyFire"
            friendlyFire.physicsBody = .init(rectangleOf: .init(width: 2.0, height: 3.0))
            friendlyFire.position = hero.position
            friendlyFire.run(.sequence([.rotate(byAngle: -atan(self.fireDirection.dx/self.fireDirection.dy), duration: 0.0),
                                        .applyForce(self.fireDirection, duration: 1.0)]))
            self.addChild(friendlyFire)
        }
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
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
        
        checkForCollisions()
    }
    
    fileprivate func checkForCollisions() {
        if let heroCollisions = hero?.physicsBody?.allContactedBodies() {
            for collision in heroCollisions where collision.node != nil && (collision.node!.name ?? "").starts(with: "enemy") {
                guard let node = collision.node as? SKSpriteNode else { continue }
                node.removeFromParent()
            }
        }
        
        
        for friendlyFire in scene!.children where (name ?? "").starts(with: "friendlyFire") {
            if let friendlyFireCollisions = friendlyFire.physicsBody?.allContactedBodies() {
                for collision in friendlyFireCollisions {
                    guard let node = collision.node as? SKSpriteNode else { continue }
                    guard let nodeName = node.name else { continue }
                    switch nodeName {
                    case let x where x.starts(with: "enemy"):
                        node.removeFromParent()
                    default:
                        continue
                    }
                }
            }
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

