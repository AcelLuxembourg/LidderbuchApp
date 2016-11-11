//
//  AppDelegate.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    var songbookViewController: LBSongbookViewController?
    {
        // retrieve songbook view controller from navigation controller
        if let navigationController = window?.rootViewController as? UINavigationController,
            let songbookViewController = navigationController.viewControllers.first as? LBSongbookViewController
        {
            return songbookViewController
        }
        
        return nil
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        window?.tintColor = LBVariables.tintColor
        return true
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool
    {
        guard let songbookViewController = self.songbookViewController else {
            return false
        }
        
        // handle scheme url
        if url.scheme == "lidderbuch"
        {
            let urlComponents = url.absoluteString.components(separatedBy: "/")
            
            // interpret lidderbuch://songs/1
            if urlComponents.count >= 4 && urlComponents[2] == "songs"
            {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                if let id = numberFormatter.number(from: urlComponents[3])?.intValue {
                    _ = songbookViewController.showSongWithId(id)
                    return true
                }
            }
        }
        
        return false
    }
    
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool
    {
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool
    {
        guard let songbookViewController = self.songbookViewController else {
            return false
        }
        
        switch userActivity.activityType {
        case LBVariables.viewSongUserActivityType:
            
            if let
                userInfo = userActivity.userInfo,
                let id = userInfo["id"] as? Int
            {
                _ = songbookViewController.showSongWithId(id)
                return true
            }
            
        case NSUserActivityTypeBrowsingWeb:
            
            if songbookViewController.showSongWithURL(userActivity.webpageURL!) {
                return true
            }
            
        default: break
            
        }
        
        return false
    }
}
