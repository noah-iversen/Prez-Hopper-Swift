//
//  AppDelegate.swift
//  DinoPrez
//
//  Created by Erik Iversen on 11/13/19.
//  Copyright © 2019 Noah Iversen. All rights reserved.
//

import UIKit
import SpriteKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static var date: Date?
    
    var savedPlayerScore = 0
    var savedSpeedScore = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppDelegate.date = Date()
        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if let view = window?.rootViewController?.view as? SKView {
            if let scene = view.scene as? GameScene {
                if scene.gameStarted {
                    savedSpeedScore = scene.speedScore
                    savedPlayerScore = scene.playerScore
                    scene.currentObstacles.removeAll()
                    for node in scene.children {
                        if (node.physicsBody?.categoryBitMask == PhysicsCategory.Obstacle) {
                            scene.removeChildren(in: [node])
                        }
                    }
                    scene.shouldUpdateScore = false
                }
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let view = window?.rootViewController?.view as? SKView {
            if let scene = view.scene as? GameScene {
                if scene.gameStarted {
                    scene.speedScore = savedSpeedScore
                    scene.playerScore = savedPlayerScore
                    scene.shouldUpdateScore = true
                    scene.updateSpeedScore()
                }
            }
        }
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
}

