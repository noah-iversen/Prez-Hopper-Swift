//
//  DeathScene.swift
//  DinoPrez
//
//  Created by Erik Iversen on 4/14/20.
//  Copyright © 2020 Noah Iversen. All rights reserved.
//

import SpriteKit
import GoogleMobileAds

class DeathScene {
    
    
    var scene: GameScene
    var scoreboardScene: ScoreboardScene?
    
    var deathCount = 0
    
    var intAd = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/5135589807")
    
    let overlay = SKSpriteNode(imageNamed: "overlay")
    let deathHeader = SKSpriteNode(imageNamed: "Death Header")
    let scoreLabel = SKLabelNode()
    let highScoreLabel = SKLabelNode()
    let playAgain = SKSpriteNode(imageNamed: "Play Again Button")
    let chooseCharacter = SKSpriteNode(imageNamed: "Choose Character")
    let scoreBoard = SKSpriteNode(imageNamed: "Score Board Button")
    let shareScore = SKSpriteNode(imageNamed: "Share Score Button")
    
    func presentDeathScene(score: Int) {
        
        scene.scoreNode.removeFromParent()
        
        overlay.zPosition = 25
        overlay.alpha = 0.8
        overlay.size = scene.frame.size
        scene.addChild(overlay)
        
        
        deathHeader.zPosition = 30
        deathHeader.size = scene.frame.size
        scene.addChild(deathHeader)
        
        
        let font : UIFont
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            highScoreLabel.position = CGPoint(x: 100, y: scene.size.height * 0.168)
            scoreLabel.position = CGPoint(x: 100, y: scene.size.height * (83.0/375.0))
            font = UIFont(name: "ArcadeClassic", size: 30)!
        } else {
            highScoreLabel.position = CGPoint(x: 100, y: scene.size.height * 0.174)
            scoreLabel.position = CGPoint(x: 100, y: scene.size.height * (86.0/375.0))
            font = UIFont(name: "ArcadeClassic", size: 50)!
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let attributes : [NSAttributedString.Key:Any] = [
            .font: font,
            .strokeWidth: -3, .strokeColor: UIColor.black,
            .foregroundColor: #colorLiteral(red: 0.9226511121, green: 0.7962837815, blue: 0.2950800955, alpha: 1), .paragraphStyle: paragraphStyle
        ]
        
        
        
        highScoreLabel.zPosition = 35
        highScoreLabel.horizontalAlignmentMode = .left
        highScoreLabel.attributedText = NSAttributedString(string: String(UserDefaults.standard.integer(forKey: "high_score1")), attributes: attributes)
        scene.addChild(highScoreLabel)
        
        scoreLabel.zPosition = 35
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.attributedText = NSAttributedString(string: String(score), attributes: attributes)
        scene.addChild(scoreLabel)
        
        scene.addChild(playAgain)
        scene.addChild(chooseCharacter)
        scene.addChild(scoreBoard)
        scene.addChild(shareScore)

        if deathCount == 4 {
            deathCount = 0
            if intAd.isReady {
                intAd.present(fromRootViewController: scene.view!.window!.rootViewController!)
            }
        }

    }
    
    func presentScoreboardScene() {
        deathHeader.removeFromParent()
        scoreLabel.removeFromParent()
        highScoreLabel.removeFromParent()
        playAgain.removeFromParent()
        chooseCharacter.removeFromParent()
        scoreBoard.removeFromParent()
        shareScore.removeFromParent()
        
        scoreboardScene!.presentScoreboard()
        
    }
    
    func addSceneButton(node: SKSpriteNode, name: String) {
        node.name = name
        node.zPosition = 30
        node.size = scene.frame.size
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.collisionBitMask = PhysicsCategory.None
        node.physicsBody?.friction = 0
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.isDynamic = false
    }
    
    init(scene: GameScene) {
        self.scene = scene
        addSceneButton(node: playAgain, name: "Play Again")
        addSceneButton(node: chooseCharacter, name: "Choose Character")
        addSceneButton(node: scoreBoard, name: "Score Board")
        addSceneButton(node: shareScore, name: "Share Score")
        
        
    }
}
