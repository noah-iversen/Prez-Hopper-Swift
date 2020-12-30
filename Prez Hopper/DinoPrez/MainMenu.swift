//
//  MainMenu.swift
//  DinoPrez
//
//  Created by Erik Iversen on 2/6/20.
//  Copyright © 2020 Noah Iversen. All rights reserved.
//

import SpriteKit
import GoogleMobileAds

class MainMenu: SKScene {
    
    let presidentList = ["Bernie", "Trump",  "Biden", "Warren", "Buttigieg", "Klobuchar", "Kamala", "Tulsi", "Steyer", "Bloomberg", "Booker", "Beto", "Yang"]
    
    var prezSelected = false
    var selectedPrez = ""
    
    var gameScene: GameScene?
    
    let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerLandscape)
    
    let selectSound = SKAction.playSoundFileNamed("game-select.mp3", waitForCompletion: false)
    let gameButton = SKAction.playSoundFileNamed("game-button.mp3", waitForCompletion: false)
    
    
    var buttonNodes: [SKSpriteNode] = []
    
    override func didMove(to view: SKView) {
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        self.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        let flag = SKSpriteNode(imageNamed: "flag")
        flag.zPosition = -100
        flag.size = self.frame.size
        addChild(flag)
        
        for face in buttonNodes {
            addChild(face)
        }
        
        clearSelection()
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else { return }
        if let node = physicsWorld.body(at: touches.first!.location(in: self))?.node as? SKSpriteNode {
            if node.name != nil {
                switch(node.name) {
                
                case "play":
                    if prezSelected {
                        if let view = self.view {
                            if gameScene != nil {
                                run(gameButton)
                                gameScene!.president = selectedPrez == "random" ? presidentList.randomElement()! : selectedPrez
                                gameScene!.scaleMode = .aspectFit
                                gameScene!.size = view.bounds.size
                                gameScene!.removeAllChildren()
                                gameScene!.sceneCreated = false
                                view.presentScene(gameScene)
                                gameScene!.run(gameButton)
                            }
                            
                        }
                    }
                case "random":
                    if prezSelected {
                        clearSelection()
                    }
                    makeSelection(selection: "random")
                    run(selectSound)
                default:
                    if presidentList.contains(node.name!) {
                        if prezSelected {
                            clearSelection()
                        }
                        makeSelection(selection: node.name!)
                        run(selectSound)
                    }
                }
            }
        }
    }

    func clearSelection() {
        for child in children {
            if let prezSprite = child as? SKSpriteNode {
                if prezSprite.name != nil {
                    prezSelected = false
                    prezSprite.alpha = 1
                }
            }
        }
    }
    
    func makeSelection(selection: String) {
        selectedPrez = selection
        for child in children {
            if let prezSprite = child as? SKSpriteNode {
                if (prezSprite.name != nil) && (selection != prezSprite.name && prezSprite.name != "play") {
                    prezSelected = true
                    prezSprite.alpha = 0.6
                }
            }
        }
    }
    
    func loadButtonNodes() {
        for index in presidentList.indices {
            let face = SKSpriteNode(imageNamed: presidentList[index] + " Button Full")
            face.name = presidentList[index]
            createButtonNode(face: face)
            buttonNodes.append(face)
        }
        
        let random = SKSpriteNode(imageNamed: "Random Button Full")
        random.name = "random"
        createButtonNode(face: random)
        buttonNodes.append(random)
        
        let play = SKSpriteNode(imageNamed: "Menu Play Button")
        play.name = "play"
        createButtonNode(face: play)
        buttonNodes.append(play)
    }
    
    func createButtonNode(face: SKSpriteNode) {
        face.zPosition = 30
        face.size = self.frame.size

        face.physicsBody = SKPhysicsBody(texture: face.texture!, size: face.size)
            
        if let pb = face.physicsBody {
            pb.affectedByGravity = false
                pb.isDynamic = false
                pb.allowsRotation = false
        }
    }
    
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
      // Position the banner. Stick it to the bottom of the Safe Area.
      // Make it constrained to the edges of the safe area.
        let guide = view?.safeAreaLayoutGuide
      NSLayoutConstraint.activate([
        guide!.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
        guide!.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
        guide!.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
      ])
    }
}
