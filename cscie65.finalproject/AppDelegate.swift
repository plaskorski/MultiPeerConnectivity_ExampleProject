//
//  AppDelegate.swift
//  csci.e55.projectproofofconcept
//
//  Created by plaskorski on 4/16/16.
//  Copyright © 2016 Paul Laskorski. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var profileManager: ProfileManager?
    var serviceManager: ServiceManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Since I could not get persistence to work, I initialize with a blank profile
        var d = [String:String]()
        d["displayName"] = String(arc4random_uniform(10000000))
        d["screenName"] = "Unknown"
        d["age"] = "Unknown"
        d["headline"] = "Unknown"
        d["about"] = "Unknown"
        d["imgDate"] = "\(Date())"
        profileManager = ProfileManager()
        serviceManager = ServiceManager(pM: profileManager!,d: d)
        NSLog("%@", "PeerID: \(serviceManager!.myPeerID)")
        profileManager?.delegate = serviceManager
        let img = UIImage(named: "avatar01.jpg")
        profileManager?.insertSelf(d, img: img)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
