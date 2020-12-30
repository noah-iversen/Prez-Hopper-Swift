//
//  ScoreboardScene.swift
//  DinoPrez
//
//  Created by Erik Iversen on 4/26/20.
//  Copyright © 2020 Noah Iversen. All rights reserved.
//

import SpriteKit

class ScoreboardScene {
    
    let scene: GameScene
    let deathScene: DeathScene
    
    let highscores = SKSpriteNode(imageNamed: "High Scores")
    let backButton = SKSpriteNode(imageNamed: "Scoreboard Back Button")
    let shareButton = SKSpriteNode(imageNamed: "Scoreboard Share Button")
    
    let scores = [SKLabelNode(), SKLabelNode(), SKLabelNode()]
    var prezFaces = [SKSpriteNode(), SKSpriteNode(), SKSpriteNode()]
    
    func presentScoreboard() {
        highscores.zPosition = 30
        highscores.size = scene.frame.size
        scene.addChild(highscores)
        
        
        var font = UIFont(name: "ArcadeClassic", size: 45)
        if UIDevice.current.userInterfaceIdiom == .pad {
            font = UIFont(name: "ArcadeClassic", size: 65)
            scores[0].position = CGPoint(x: 0, y: scene.size.height * 0.17)
            scores[1].position = CGPoint(x: 0, y: scene.size.height * (13.0/375.0))
            scores[2].position = CGPoint(x: 0, y: scene.size.height * (-35.0/375.0))
        } else {
            scores[0].position = CGPoint(x: 0, y: scene.size.height * 0.16)
            scores[1].position = CGPoint(x: 0, y: scene.size.height * (10.0/375.0))
            scores[2].position = CGPoint(x: 0, y: scene.size.height * (-40.0/375.0))
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let attributes : [NSAttributedString.Key:Any] = [
            .font: font!,
            .strokeWidth: -3, .strokeColor: UIColor.black,
            .foregroundColor: #colorLiteral(red: 0.9226511121, green: 0.7962837815, blue: 0.2950800955, alpha: 1), .paragraphStyle: paragraphStyle
        ]
        
        
        
        
        
        
        for index in scores.indices {
            scores[index].zPosition = 30
            scores[index].horizontalAlignmentMode = .left
            scores[index].attributedText = NSAttributedString(string: getScore(score: index + 1), attributes: attributes)
            scene.addChild(scores[index])
            
            
            if let prezName = UserDefaults.standard.string(forKey: "high_score" + String(index + 1) + "_prez") {
                if scene.presidentList.contains(prezName) || prezName == scene.president {
                    prezFaces[index] = SKSpriteNode(imageNamed: prezName)
                    prezFaces[index].zPosition = 30
                    prezFaces[index].position = scores[index].position
                    
                    if UIDevice.current.userInterfaceIdiom != .pad {
                        prezFaces[index].setScale(0.5)
                        
                        prezFaces[index].position.x += 90
                        prezFaces[index].position.y += 17
                    } else {
                        
                        prezFaces[index].position.x += 150
                        prezFaces[index].position.y += 20
                    }
                    scene.addChild(prezFaces[index])
                }
            }
        }
        
        
        scene.addChild(backButton)
        scene.addChild(shareButton)
        
    }
    
    func getScore(score: Int) -> String {
        String(UserDefaults.standard.integer(forKey: "high_score" + String(score)))
    }
    
    func clearScoreboard() {
        deathScene.overlay.removeFromParent()
        highscores.removeFromParent()
        backButton.removeFromParent()
        shareButton.removeFromParent()
        
        for score in scores {
            score.removeFromParent()
            score.position = CGPoint(x: 0, y: 0)
        }
        
        for face in prezFaces {
            face.removeFromParent()
        }
    }
    
    init(scene: GameScene, deathScene: DeathScene) {
        self.scene = scene
        self.deathScene = deathScene
        deathScene.addSceneButton(node: backButton, name: "Back")
        deathScene.addSceneButton(node: shareButton, name: "Share Score")
    }
}
