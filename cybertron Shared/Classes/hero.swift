//
//  hero.swift
//  cybertron
//
//  Created by Cameron Armstrong on 17/12/2022.
//

import SpriteKit

class Hero: SKSpriteNode {
    var powerup: String? = nil
    
    init() {
        let texture = SKTexture(imageNamed: "hero")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = "hero"
        self.physicsBody = .init(edgeLoopFrom: .init(origin: .init(x: 4, y: 4), size: .init(width: 8, height: 8)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
