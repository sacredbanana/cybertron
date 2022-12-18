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
    
    func hit(damage: UInt32) {
        if hp >= damage {
            hp -= damage
        } else {
            hp = 0
        }
    }
}
