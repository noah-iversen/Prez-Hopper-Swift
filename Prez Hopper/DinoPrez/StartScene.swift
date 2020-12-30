//
//  StartScene.swift
//  DinoPrez
//
//  Created by Erik Iversen on 4/14/20.
//  Copyright © 2020 Noah Iversen. All rights reserved.
//

import SpriteKit

class StartScene: SKScene {
    
    var gameScene: GameScene?
    var mainMenu: MainMenu?
    
    let gameButton = SKAction.playSoundFileNamed("game-button.mp3", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        let whitehouse = SKSpriteNode(imageNamed: "whitehouse")
        whitehouse.zPosition = -5
        whitehouse.size = self.frame.size
        addChild(whitehouse)
        
        let overlay = SKSpriteNode(imageNamed: "overlay")
        overlay.zPosition = -3
        overlay.size = self.frame.size
        addChild(overlay)
        
        let prezHopper = SKSpriteNode(imageNamed: "Prez Hopper Text")
        prezHopper.zPosition = -1
        prezHopper.size = self.frame.size
        addChild(prezHopper)
        
        let playButton = SKSpriteNode(imageNamed: "Start Screen Play Button")
        playButton.name = "Play"
        playButton.zPosition = 1
        playButton.size = self.frame.size
        playButton.physicsBody = SKPhysicsBody(texture: playButton.texture!, size: playButton.size)
        playButton.physicsBody?.isDynamic = false
        playButton.physicsBody?.affectedByGravity = false
        playButton.physicsBody?.allowsRotation = false
        addChild(playButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let node = physicsWorld.body(at: touches.first!.location(in: self))?.node as? SKSpriteNode {
            if node.name != nil {
                if let view = self.view {
                    if node.name == "Play" {
                        view.presentScene(mainMenu!)
                        mainMenu!.run(gameButton)
                    }
                }
            }
        }
    }
}
