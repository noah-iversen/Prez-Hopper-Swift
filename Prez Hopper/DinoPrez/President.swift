//
//  President.swift
//  DinoPrez
//
//  Created by Erik Iversen on 5/14/20.
//  Copyright © 2020 Noah Iversen. All rights reserved.
//

import Foundation
import SpriteKit

class President: SKSpriteNode {
    
    func createPrezSprite(scene: GameScene) {
        if UIDevice.current.userInterfaceIdiom != .pad {
            self.setScale(1.5)
            self.position = CGPoint(x: scene.size.width * (-300/812.0), y: scene.size.height * (-70.0/375.0))
        } else {
            self.setScale(2)
            self.position = CGPoint(x: -300, y: scene.size.height * (-100.0/810.0))
        }
        
        self.texture = SKTexture(imageNamed: scene.president + "-1")
        self.physicsBody = SKPhysicsBody(texture: scene.prezNodes[0].texture!, size: self.size)
        if let pb = self.physicsBody {
            
            pb.isDynamic = true
            pb.affectedByGravity = true
            pb.allowsRotation = false
            pb.categoryBitMask = PhysicsCategory.Character
            pb.collisionBitMask = PhysicsCategory.Edge
            pb.contactTestBitMask = PhysicsCategory.Collider
            pb.restitution = 0
            pb.friction = 1
            pb.linearDamping = 0
            pb.angularDamping = 1
        }
        
        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: scene.president + "-\(i)"))
        }
        let prezAnimation = SKAction.animate(with: textures,  timePerFrame: 0.1)
        self.run(SKAction.repeatForever(prezAnimation))
    }
    
    func jump(scene: GameScene) {
        
        if !scene.canJump || self.physicsBody!.velocity.dy < -4 {
            return
        }
        
        if scene.gameStarted {
            if let pb = self.physicsBody {
                if pb.velocity.dy > 3 {
                    scene.canJump = false
                }
                
                pb.velocity = CGVector(dx: 0, dy: 0)

                if UIDevice.current.userInterfaceIdiom != .pad {
                    pb.applyImpulse(CGVector(dx:0, dy: 80), at: self.position)
                } else {
                    pb.applyImpulse(CGVector(dx:0, dy:200), at: self.position)
                }
                
                self.texture = SKTexture(imageNamed: scene.president + "-2")
                self.isPaused = true
                scene.run(scene.jumpSound)
            }
        }
    }
}
