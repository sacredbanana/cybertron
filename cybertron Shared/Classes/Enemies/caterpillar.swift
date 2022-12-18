//
//  caterpillar.swift
//  cybertron
//
//  Created by Cameron Armstrong on 18/12/2022.
//

import SpriteKit

class Caterpillar: Enemy {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.pointWorth = 1000
        self.hp = 1
    }
}
