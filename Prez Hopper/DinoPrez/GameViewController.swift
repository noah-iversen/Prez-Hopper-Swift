//
//  GameViewController.swift
//  DinoPrez
//
//  Created by Erik Iversen on 11/13/19.
//  Copyright © 2019 Noah Iversen. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate {
    
    var loadScene: StartScene?
    var gameScene: GameScene?
    
    var extendedLaunch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            view.ignoresSiblingOrder = true
            view.preferredFramesPerSecond = 60
            // Load the SKScene from 'GameScene.sks'
            if let scene = StartScene(fileNamed: "StartScene") {
                if let mainMenu = MainMenu(fileNamed: "MainMenu") {
                    if let gameScene = GameScene(fileNamed: "GameScene") {
                        self.gameScene = gameScene
                        // Set the scale mode to scale to fit the window
                        scene.scaleMode = .aspectFit
                        scene.size = view.bounds.size
                        scene.mainMenu = mainMenu
                        
                        gameScene.scaleMode = .aspectFit
                        gameScene.size = view.bounds.size
                        
                        mainMenu.scaleMode = .aspectFit
                        mainMenu.size = view.bounds.size
                        
                        mainMenu.loadButtonNodes()
                        mainMenu.gameScene = gameScene
                        
                        scene.gameScene = gameScene
                        gameScene.mainMenu = mainMenu
                        gameScene.deathScene = DeathScene(scene: scene.gameScene!)
                        gameScene.deathScene!.scoreboardScene = ScoreboardScene(scene: gameScene, deathScene: gameScene.deathScene!)
                        gameScene.createObstacleNodes()
                        gameScene.loadPrezSounds()
                        // gameScene.deathScene?.intAd = createAndLoadInterstitial()
                        
                        
                        mainMenu.bannerView.frame = CGRect(x: scene.size.width / 2, y: -scene.size.height * 0.9, width: scene.size.width, height: scene.size.height * 0.1)
                        /*mainMenu.bannerView.adUnitID = "ca-app-pub-4798898525992407/9638061260"
                        mainMenu.bannerView.delegate = self
                        mainMenu.bannerView.rootViewController = self
                        mainMenu.bannerView.load(GADRequest())
                        */
                        if AppDelegate.date!.timeIntervalSinceNow > -2.0 && !extendedLaunch {
                            loadScene = scene
                            extendSplashScreenPresentation()
                        } else {
                            view.presentScene(scene)
                        }
                    }
                }
                
            }
        }
    }
    
    private func extendSplashScreenPresentation(){
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LaunchScreen")
        self.present(vc, animated: false, completion: nil)
        extendedLaunch = true
        self.viewDidLoad()
        
    }

    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-4798898525992407/8769818252")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        gameScene?.deathScene?.intAd = createAndLoadInterstitial()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
