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
        self.action = .customAction(withDuration: .infinity, actionBlock: { node, elapsedTime in
            let dx = self.heroPosition.x - node.position.x
            let dy = self.heroPosition.y - node.position.y
            let angle = atan2(dx,dy)
            node.position.x += sin(angle) * 1
            node.position.y += cos(angle) * 1
        })
    }
}
