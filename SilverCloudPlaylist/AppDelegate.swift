//
//  AppDelegate.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 11/25/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard SPTAuth.defaultInstance().canHandle(url) else {
            //filtered Url
            return false
        }
        
        SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url, callback: {
            (error, session) in
            guard let sptSession = session, error == nil else {
                print("error in callBack: \(error)")
                return
            }
            let userDefaults = UserDefaults.standard
            //userDefaults.set(true, forKey: AuthParam.sessionUserDefaultsKey.rawValue)
            let sessionData = NSKeyedArchiver.archivedData(withRootObject: sptSession)
            userDefaults.set(sessionData, forKey: AuthParam.sessionUserDefaultsKey.rawValue)
            userDefaults.synchronize()
        })
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

