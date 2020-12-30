//
//  Obstacle.swift
//  DinoPrez
//
//  Created by Erik Iversen on 5/14/20.
//  Copyright © 2020 Noah Iversen. All rights reserved.
//

import Foundation
import SpriteKit

class Obstacle: SKSpriteNode {
    
    
    func createObstacle(scene: GameScene) {
        if Int.random(in: 1...4) == 1 {
            let index = Int.random(in: 0...1)
            self.name = scene.trashList[index]
            self.texture = SKTexture(imageNamed: scene.trashList[index])
            adjustForiPad(scene: scene)
            self.physicsBody = scene.trashNodes[index].physicsBody?.copy() as? SKPhysicsBody
            
        } else {
            let index = Int.random(in: 0..<scene.presidentList.count)
            self.name = scene.presidentList[index]
            self.texture = SKTexture(imageNamed: scene.presidentList[index] + "-1-Reverse")
            adjustForiPad(scene: scene)
            self.physicsBody = scene.prezNodes[index].physicsBody?.copy() as? SKPhysicsBody
            runAnimation(scene: scene)
        }
        
        
        self.physicsBody?.velocity = CGVector(dx: -400 - scene.obSpeed, dy: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 14.0, execute: {
            scene.removeChildren(in: [self])
        })
        
    }
    
    func adjustForiPad(scene: GameScene) {
        if UIDevice.current.userInterfaceIdiom != .pad {
            self.position = CGPoint(x: 1020, y: scene.size.height * (-85.0/375.0))
        } else {
            self.setScale(1.25)
            self.position = CGPoint(x: 1020, y: scene.size.height * (-210.0/810.0))
        }
    }
    
    func runAnimation(scene: GameScene) {
        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: self.name! + "-\(i)-Reverse"))
        }
        let prezAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        self.run(SKAction.repeatForever(prezAnimation))
    }
}
