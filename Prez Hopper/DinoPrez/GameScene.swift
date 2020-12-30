//
//  GameScene.swift
//  DinoPrez
//
//  Created by Erik Iversen on 11/13/19.
//  Copyright © 2019 Noah Iversen. All rights reserved.
//

import SpriteKit
import LinkPresentation
import UIKit
import GoogleMobileAds

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = UInt32.max
    static let Edge: UInt32 = 0b1
    static let Character: UInt32 = 0b10
    static let Collider: UInt32 = 0b100
    static let Obstacle: UInt32 = 0b1000
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var jumpStack = 135
    var jumpSingle = 67
    
    var sceneCreated = false
    var gameStarted = false
    var canJump = false
    var shouldSpawnObstacle = false
    var shouldSpawnStack = false
    var shouldSpawnHorizontal = false
    var shouldUpdateScore = false
    
    var president = ""
    var presidentList = ["Bernie", "Trump",  "Biden", "Warren", "Buttigieg", "Klobuchar", "Kamala", "Tulsi", "Steyer", "Bloomberg", "Booker", "Beto", "Yang"]
    
    var prezNodes: [SKSpriteNode] = []
    var trashNodes: [SKSpriteNode] = []
    
    let trashList = ["TrashCan-1", "TrashCan-2"]
    
    let scoreNode = SKLabelNode(fontNamed: "ArcadeClassic")
    var prezSpriteNode = President(imageNamed: "Bernie-1")
    var bottomCollider: SKPhysicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -1024, y: -120), to: CGPoint(x:1024, y: -120))
    
    let jumpSound = SKAction.playSoundFileNamed("game-jump.mp3", waitForCompletion: false)
    let clearDouble = SKAction.playSoundFileNamed("game-cleardouble.mp3", waitForCompletion: false)
    let gameButton = SKAction.playSoundFileNamed("game-button.mp3", waitForCompletion: false)
    var gameOverSound = SKAction.playSoundFileNamed("game-over.mp3", waitForCompletion: true)
    
    var prezSounds: [String] = []
    
    var mainMenu: MainMenu?
    var deathScene: DeathScene?

    var speedScore = 0
    var playerScore = 0
    
    var currentObstacles: [SKSpriteNode] = []
    var collidedPrez = ""
    
    var displayTutorial = true
    var stackSpawned = false
    
    var obSpeed : Int {
        let speed = speedScore <= 600 ? speedScore : 600
        return UIDevice.current.userInterfaceIdiom == .pad ? Int((Double(speed) * 2)) : speed
    }
    
    override func didMove(to view: SKView) {
        //1080
        //810
        presidentList = ["Bernie", "Trump",  "Biden", "Warren", "Buttigieg", "Klobuchar", "Kamala", "Tulsi", "Steyer", "Bloomberg", "Booker", "Beto", "Yang"]
        
        
        for index in presidentList.indices {
            if presidentList[index] == president {
                presidentList.remove(at: index)
                prezNodes.remove(at: index)
                break
            }
        }
    
        if UIDevice.current.userInterfaceIdiom == .pad {
            bottomCollider = SKPhysicsBody(edgeFrom: CGPoint(x: -1024, y: self.size.height * (-250.0/810.0)), to: CGPoint(x:1024, y: self.size.height * (-250.0/810.0)))
        } else {
            bottomCollider = SKPhysicsBody(edgeFrom: CGPoint(x: -1024, y: self.size.height * (-120.0/375.0)), to: CGPoint(x:1024, y: self.size.height * (-120.0/375.0)))
        }
        
        let whiteHouse = SKSpriteNode(imageNamed: "whitehouse")
        whiteHouse.zPosition = -30
        whiteHouse.size = self.frame.size
        addChild(whiteHouse)
        
        if displayTutorial {
            let tutorial = SKSpriteNode(imageNamed: "tutorial")
            tutorial.zPosition = -29
            tutorial.size = self.frame.size
            addChild(tutorial)
            
            let tapAnywhere = SKSpriteNode(imageNamed: "tap anywhere")
            tapAnywhere.zPosition = -29
            tapAnywhere.size = self.frame.size
            tapAnywhere.run(SKAction.fadeOut(withDuration: 0))
            addChild(tapAnywhere)
            

            
            let sequence = SKAction.sequence([

                SKAction.fadeIn(withDuration: 1),
                SKAction.fadeOut(withDuration: 1),

            ])


            tapAnywhere.run(SKAction.repeatForever(sequence))
        } 
    }
    
    func loadPrezSounds() {
        let fileManager = FileManager.default
        let path = Bundle.main.resourcePath!
        let soundItems = try! fileManager.contentsOfDirectory(atPath: path)

        
        for sound in soundItems {
            let components = sound.components(separatedBy: "-")
            if components.count > 1 {
                if presidentList.contains(components[1].capitalizingFirstLetter()) {
                    prezSounds.append(sound)
                }
            }
        }
    }
    
    func startGame() {

        print(jumpStack)
        print(jumpSingle)
        currentObstacles.removeAll()
        collidedPrez = ""
        
        self.isPaused = false
        
        for node in self.children {
            if (node.physicsBody?.categoryBitMask == PhysicsCategory.Obstacle) {
                self.removeChildren(in: [node])
            }
        }
        
        gameStarted = true
        canJump = true
        speedScore = 599
        playerScore = 0
        shouldUpdateScore = true
        updateSpeedScore()
        updatePlayerScore()
        self.shouldSpawnObstacle = true
    }
    
    func createSceneContents() {
        
        scoreNode.zPosition = 15
        scoreNode.fontColor = #colorLiteral(red: 0.9226511121, green: 0.7962837815, blue: 0.2950800955, alpha: 1)
        
        let whiteHouse = SKSpriteNode(imageNamed: "whitehouse")
        whiteHouse.zPosition = -30
        whiteHouse.size = self.frame.size
        addChild(whiteHouse)
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            scoreNode.position = CGPoint(x: 0, y: self.size.height * 0.4)
        } else {
            scoreNode.position = CGPoint(x: 0, y: self.size.height * (350.0 / 810.0))
        }
        addChild(scoreNode)
        
        self.physicsWorld.contactDelegate = self
        
        self.physicsBody = bottomCollider
        
        bottomCollider.categoryBitMask = PhysicsCategory.Edge | PhysicsCategory.Collider
        bottomCollider.contactTestBitMask = PhysicsCategory.Character
        bottomCollider.friction = 0
        bottomCollider.restitution = 0
        bottomCollider.linearDamping = 0
        bottomCollider.angularDamping = 1
        bottomCollider.isDynamic = false
        bottomCollider.affectedByGravity = false
        bottomCollider.allowsRotation = false
        
        
        prezSpriteNode.createPrezSprite(scene: self)
        self.addChild(prezSpriteNode)
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            parallaxScroll(image: "fence", y: self.size.height * (74.0/810.0), z: -1, duration: 7, needPhysics: false)
        } else {
            parallaxScroll(image: "fence", y: self.size.height * (36.0/375.0), z: -1, duration: 7, needPhysics: false)
        }
        
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -20)
        } else {
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -30)
        }
        
        
        let wait = SKAction.wait(forDuration: 1.0, withRange: 0.8)
        let spawn = SKAction.run {
            self.setShouldSpawnDouble()
            self.spawnObstacle()
        }
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeatForever(sequence), withKey: "obstacle")
    }
    
    func endGame() {
        if gameStarted {
            canJump = false
            shouldSpawnObstacle = false
            gameStarted = false
            shouldUpdateScore = false
            self.removeAllChildren()
            
            createSceneContents()
            startGame()
        }
        
        for child in self.children {
            child.isPaused = true
            child.removeAllActions()
            child.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            child.physicsBody?.isDynamic = false
        }
        
        self.removeAllActions()
        
        
        canJump = false
        shouldSpawnObstacle = false
        gameStarted = false
        shouldUpdateScore = false
        
        var tempScore = 0
        var tempPrez = ""
        
        if playerScore > UserDefaults.standard.integer(forKey: "high_score1") {
            
            
            tempScore = UserDefaults.standard.integer(forKey: "high_score1")
            tempPrez = UserDefaults.standard.string(forKey: "high_score1_prez") ?? ""
            
            UserDefaults.standard.set(playerScore, forKey: "high_score1")
            UserDefaults.standard.set(president, forKey: "high_score1_prez")
            
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "high_score2"), forKey: "high_score3")
            UserDefaults.standard.set(UserDefaults.standard.string(forKey: "high_score2_prez"), forKey: "high_score3_prez")
            
            UserDefaults.standard.set(tempScore, forKey: "high_score2")
            UserDefaults.standard.set(tempPrez, forKey: "high_score2_prez")
            
        } else if playerScore > UserDefaults.standard.integer(forKey: "high_score2") {
            tempScore = UserDefaults.standard.integer(forKey: "high_score2")
            tempPrez = UserDefaults.standard.string(forKey: "high_score2_prez") ?? ""
            
            UserDefaults.standard.set(playerScore, forKey: "high_score2")
            UserDefaults.standard.set(president, forKey: "high_score2_prez")
            
            UserDefaults.standard.set(tempScore, forKey: "high_score3")
            UserDefaults.standard.set(tempPrez, forKey: "high_score3_prez")
        } else if playerScore > UserDefaults.standard.integer(forKey: "high_score3") {
            UserDefaults.standard.set(playerScore, forKey: "high_score3")
            UserDefaults.standard.set(president, forKey: "high_score3_prez")
        }
        
        playDeathSound()
        deathScene?.deathCount += 1
        deathScene?.presentDeathScene(score: playerScore)
        
    }
    
    func playDeathSound() {
        
        var availableSounds: [String] = []
        
        availableSounds.append("game-over.mp3")
        
        for sound in prezSounds {
            if sound.contains(collidedPrez.lowercased()) {
                availableSounds.append(sound)
            }
        }
        
        if !availableSounds.isEmpty {
            run(SKAction.playSoundFileNamed(availableSounds.randomElement()!, waitForCompletion: false))
        }
    }
    
    func spawnObstacle() {
        if self.shouldSpawnObstacle == false {
            return
        }
        
        //let x = arc4random() % 5;
        //print(x)
        //if x != 2 {
        let obstacle = Obstacle(imageNamed: "Bernie-1-Reverse")
        obstacle.createObstacle(scene: self)
        self.addChild(obstacle)
        currentObstacles.append(obstacle)
        if shouldSpawnHorizontal || shouldSpawnStack {
            let duplicate = Obstacle(imageNamed: "Bernie-1-Reverse")
            duplicate.createObstacle(scene: self)
            currentObstacles.append(duplicate)
            if shouldSpawnHorizontal {
                duplicate.position.x += obstacle.size.width / 2
            } else {
                stackSpawned = true
                duplicate.position.y += obstacle.size.height
                if obstacle.name! == trashList[0] {
                    duplicate.position.y -= 20
                } else if obstacle.name! == trashList[1] {
                    duplicate.position.y -= 10
                }
            }
            addChild(duplicate)
        }
        //}
    }
    
    func setShouldSpawnDouble() {
        if speedScore > 150 {
            let random = Int.random(in: 1...100)
            var hitRandom = speedScore > 350 ? random <= 30 : random <= 25
            hitRandom = speedScore > 500 ? random <= 35 : hitRandom
            if hitRandom {
                let dupPos = Int.random(in: 0...1)
                if dupPos == 0 || speedScore < 300 {
                    shouldSpawnHorizontal = true
                    return
                } else {
                    shouldSpawnStack = true
                    return
                }
            }
        }
        shouldSpawnStack = false
        shouldSpawnHorizontal = false
    }
    
    
    func createObstacleNodes() {
        
        presidentList = ["Bernie", "Trump",  "Biden", "Warren", "Buttigieg", "Klobuchar", "Kamala", "Tulsi", "Steyer", "Bloomberg", "Booker", "Beto", "Yang"]
        
        for prez in presidentList {
            let ob = SKSpriteNode(imageNamed: prez + "-1-Reverse")
            createObstacleBody(ob: ob)
            prezNodes.append(ob)
        }
        
        for trashBin in trashList {
            let ob = SKSpriteNode(imageNamed:  trashBin)
            createObstacleBody(ob: ob)
            trashNodes.append(ob)
        }
    }
    
    func createObstacleBody(ob: SKSpriteNode) {
        if UIDevice.current.userInterfaceIdiom != .pad {
            ob.position = CGPoint(x: 1020, y: self.size.height * (-85/375.0))
        } else {
            ob.setScale(1.25)
            ob.position = CGPoint(x: 1020, y: self.size.height * (210.0/810.0))
        }
        ob.physicsBody = SKPhysicsBody(texture: ob.texture!, size: ob.size)
        if let pb = ob.physicsBody {
            pb.isDynamic = true
            pb.affectedByGravity = false
            pb.allowsRotation = false
            pb.categoryBitMask = PhysicsCategory.Obstacle
            pb.contactTestBitMask = PhysicsCategory.Character
            pb.collisionBitMask = 0
            pb.restitution = 0
            pb.friction = 0
            pb.linearDamping = 0
            pb.angularDamping = 0
            pb.velocity = CGVector(dx: -300 - obSpeed, dy: 0)
        }
    }
    
    func updateSpeedScore() {
        speedScore += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.085, execute: {
            if (self.shouldUpdateScore) {
                self.updateSpeedScore()
            }
        })
        
        switch(speedScore) {
        case 300:
            self.removeAction(forKey: "obstacle")
            let wait = SKAction.wait(forDuration: 0.9, withRange: 0.6)
            let spawn = SKAction.run({ self.spawnObstacle()
            })
            let sequence = SKAction.sequence([wait, self.setShouldSpawnDouble(), spawn, self.stackDelay()])
            self.run(SKAction.repeatForever(sequence), withKey: "obstacle")
        case 600:
            self.removeAction(forKey: "obstacle")
            let wait = SKAction.wait(forDuration: 0.65, withRange: 0.3)
            let spawn = SKAction.run({
                _ = self.setShouldSpawnDouble()
                self.spawnObstacle()
            })
            let sequence = SKAction.sequence([wait, spawn])
            self.run(SKAction.repeatForever(sequence), withKey: "obstacle")
        default:
            break
        }
    }
    
    func updatePlayerScore() {
        if shouldUpdateScore {
            var font = UIFont(name: "ArcadeClassic", size: 50)
            if UIDevice.current.userInterfaceIdiom == .pad {
                font = UIFont(name: "ArcadeClassic", size: 75)
            }
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font!, .strokeColor: UIColor.black,
                .strokeWidth: -3,
                .foregroundColor: #colorLiteral(red: 0.9226511121, green: 0.7962837815, blue: 0.2950800955, alpha: 1)
            ]
            scoreNode.attributedText = NSAttributedString(string: String(playerScore), attributes: attributes)
        }

    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA == prezSpriteNode.physicsBody && contact.bodyB == bottomCollider) ||
            (contact.bodyB == prezSpriteNode.physicsBody && contact.bodyA == bottomCollider) {
            canJump = true
            prezSpriteNode.isPaused = false
        } else {
            //let bodyA = contact.bodyA.node
            // let bodyB = contact.bodyB.node
            
            if !currentObstacles.isEmpty {
                if currentObstacles[0].position.x - prezSpriteNode.position.x < 10 {
                    if currentObstacles[1].position.x - prezSpriteNode.position.x < 10 {
                        jumpStack -= 1
                    }
                } else {
                    jumpSingle -= 1
                }
            }
            
            currentObstacles.removeAll()
            
            
            
            /*if bodyA!.name != nil {
                if presidentList.contains(bodyA!.name!) {
                    collidedPrez = bodyA!.name!
                }
            } else if bodyB!.name != nil {
                if presidentList.contains(bodyB!.name!) {
                    collidedPrez = bodyB!.name!
                }
            }
            */
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if !((contact.bodyA == prezSpriteNode.physicsBody && contact.bodyB == bottomCollider) ||
            (contact.bodyB == prezSpriteNode.physicsBody && contact.bodyA == bottomCollider)) {
            if gameStarted && (contact.bodyA == prezSpriteNode.physicsBody || contact.bodyB == prezSpriteNode.physicsBody) {
                if gameStarted {
                    endGame()
                }
            }
        }
    }
    
    func parallaxScroll(image: String, y: CGFloat, z: CGFloat, duration: Double, needPhysics: Bool) {
        for i in 0...1 {
            let node = SKSpriteNode(imageNamed: image)
            if UIDevice.current.userInterfaceIdiom == .pad {
                node.position = CGPoint(x: 2645 * CGFloat(i), y: y)
                node.setScale(2.94)
                node.size = CGSize(width: node.size.width, height: self.frame.height * 1.2)
                let move = SKAction.moveBy(x: -2645, y: 0, duration: duration)
                let wrap = SKAction.moveBy(x: 2645, y: 0, duration: 0)
                let sequence = SKAction.sequence([move, wrap])
                let forever = SKAction.repeatForever(sequence)
                node.run(forever)
            } else {
                node.position = CGPoint(x: 1645 * CGFloat(i), y: y)
                node.setScale(1.83)
                node.size = CGSize(width: node.size.width, height: self.frame.height * 1.2)
                let move = SKAction.moveBy(x: -1645, y: 0, duration: duration)
                let wrap = SKAction.moveBy(x: 1645, y: 0, duration: 0)
                let sequence = SKAction.sequence([move, wrap])
                let forever = SKAction.repeatForever(sequence)
                node.run(forever)
            }
            node.zPosition = z
            addChild(node)
        }

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameStarted {
            if displayTutorial {
                self.removeAllChildren()
                if !sceneCreated {
                    displayTutorial = false
                    sceneCreated = true
                    createSceneContents()
                    startGame()
                }
            } else if let node = physicsWorld.body(at: touches.first!.location(in: self))?.node as? SKSpriteNode {
                if node.name != nil {
                    if let view = self.view {
                        run(gameButton)
                        switch node.name {
                        case "Play Again":
                            scene?.removeAllChildren()
                            scoreNode.position = CGPoint(x: 0, y: 0)
                            createSceneContents()
                            startGame()
                        case "Choose Character":
                            prezNodes.removeAll()
                            displayTutorial = true
                            createObstacleNodes()
                            mainMenu!.removeAllChildren()
                            view.presentScene(mainMenu!)
                            mainMenu!.run(gameButton)
                        case "Share Score":
                            shareGame()
                        case "Score Board":
                            deathScene?.presentScoreboardScene()
                        case "Back":
                            deathScene?.scoreboardScene?.clearScoreboard()
                            deathScene?.presentDeathScene(score: playerScore)
                        default:
                            break
                        }
                    }
                }
            }
        } else if let _ = touches.first {
            prezSpriteNode.jump(scene: self)
        }
    }
    
    func shareGame() {
         if var top = scene?.view?.window?.rootViewController {
             while let presentedViewController = top.presentedViewController {
                 top = presentedViewController
             }
            let shareController = ShareController()
            let activityVC = UIActivityViewController(activityItems: [ view!.snapshot!, "Check out my score on Prez Hopper! https://apps.apple.com/us/app/prez-hopper/id1513839848", shareController], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = view
            top.present(activityVC, animated: true, completion: nil)
         }
     }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        if !currentObstacles.isEmpty {
            if speedScore > 500 {
                if currentObstacles[0].position.x <= CGFloat(jumpStack) {
                    if currentObstacles.count > 1 {
                        if currentObstacles[1].position.x - currentObstacles[0].position.x < 5{
                            if canJump {
                                prezSpriteNode.jump(scene: self)
                                prezSpriteNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
                                canJump = false
                            }
                        } else if currentObstacles[0].position.x <= CGFloat(jumpSingle) {
                            if canJump {
                                prezSpriteNode.jump(scene: self)
                                canJump = false
                            }
                        }
                    }
                }
            }
            if currentObstacles[0].position.x <= prezSpriteNode.position.x {
                currentObstacles.remove(at: 0)
                playerScore += 1
                if !currentObstacles.isEmpty {
                    if (currentObstacles[0].position.x -  currentObstacles[0].size.width) <= prezSpriteNode.position.x {
                        currentObstacles.remove(at: 0)
                        playerScore += 1
                        run(SKAction.sequence([SKAction.wait(forDuration: 0.06), clearDouble]))
                    }
                }
                updatePlayerScore()
                run(clearDouble)
            }
        }
    }
}

extension UIView {
    var snapshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

