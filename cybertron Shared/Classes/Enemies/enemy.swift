//
//  enemy.swift
//  cybertron
//
//  Created by Cameron Armstrong on 18/12/2022.
//

import SpriteKit

class Enemy: SKSpriteNode {
    var pointWorth: UInt32 = 0
    
    var hp: UInt32 = 1
    
    var isDead: Bool {
        get {
            return hp == 0
        }
    }
    
    var heroPosition: CGPoint = .zero
    
    var action: SKAction = .init()
    
    func hit(damage: UInt32) {
        if hp >= damage {
            hp -= damage
        } else {
            hp = 0
        }
    }
    
    func activateAI() {
        run(action)
    }
}
