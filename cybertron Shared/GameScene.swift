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
    
    fileprivate var movementDirection: CGPoint = .zero
    
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
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        physicsBody = .init(edgeLoopFrom: frame)
        name = "scene"
        hero = .init(lives: 5)
        guard let hero = hero else { fatalError("Error creating hero") }
        addChild(hero)
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let tapLocation = activeTapLocation, let hero = hero {
            movementDirection = .init(x: tapLocation.x - hero.position.x, y: tapLocation.y - hero.position.y)
            movementDirection = normalize(movementDirection)
            let distanceSquared = pow(tapLocation.x - hero.position.x, 2) + pow(tapLocation.y - hero.position.y, 2)
            if distanceSquared > 1 {
                hero.position.x += movementSpeed * movementDirection.x
                hero.position.y += movementSpeed * movementDirection.y
            }
        } else {
            movementDirection = normalize(movementDirection)
            hero?.position.x += movementSpeed * movementDirection.x
            hero?.position.y += movementSpeed * movementDirection.y
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
    
    fileprivate func normalize(_ point: CGPoint) -> CGPoint {
        let length = sqrt(pow(point.x, 2) + pow(point.y, 2))
        if length == 0 {
            return .zero
        } else {
            return .init(x: point.x/length, y: point.y/length)
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
    
        movementDirection = .init(x: xDirection, y: yDirection)
    }

}
#endif

