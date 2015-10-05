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
            songbookViewController = navigationController.viewControllers.first as? LBSongbookViewController
        {
            return songbookViewController
        }
        
        return nil
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool
    {
        window?.tintColor = LBVariables.tintColor
        return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool
    {
        guard let songbookViewController = self.songbookViewController else {
            return false
        }
        
        // handle scheme url
        if url.scheme == "lidderbuch"
        {
            let urlComponents = url.absoluteString.componentsSeparatedByString("/")
            
            // interpret lidderbuch://songs/1
            if urlComponents.count >= 4 && urlComponents[2] == "songs"
            {
                let numberFormatter = NSNumberFormatter()
                numberFormatter.numberStyle = .DecimalStyle
                if let id = numberFormatter.numberFromString(urlComponents[3])?.integerValue {
                    songbookViewController.showSongWithId(id)
                    return true
                }
            }
        }
        
        return false
    }
    
    func application(application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool
    {
        return true
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool
    {
        guard let songbookViewController = self.songbookViewController else {
            return false
        }
        
        switch userActivity.activityType {
        case LBVariables.viewSongUserActivityType:
            
            if let
                userInfo = userActivity.userInfo,
                id = userInfo["id"] as? Int
            {
                songbookViewController.showSongWithId(id)
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
