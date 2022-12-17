//
//  hero.swift
//  cybertron
//
//  Created by Cameron Armstrong on 17/12/2022.
//

import SpriteKit

class Hero: SKSpriteNode {
    var lives: UInt = 5
    
    var score: UInt = 0
    
    var powerup: String? = nil
    
    init(lives: UInt) {
        self.lives = lives
        let texture = SKTexture(imageNamed: "hero")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = "hero"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
