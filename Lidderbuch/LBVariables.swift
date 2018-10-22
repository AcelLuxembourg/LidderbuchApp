//
//  LBVariables.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import UIKit

struct LBVariables
{
    // endpoint url of songbook api
    static let songbookApiEndpoint = "https://acel.lu/api/v2/songs"
    
    // endpoint url of backer api
    static let backerApiEndpoint = "https://acel.lu/api/v1/backers/lidderbuch_app"
    
    // global tint color
    static let tintColor = UIColor(red:0.95, green:0.57, blue:0.00, alpha:1.0)
    
    // user activity type for song views
    static let viewSongUserActivityType = "lu.acel.Lidderbuch.Song.View"
    
    // it is considered a song view when a user views a song for this duration
    static let songViewDuration = 15.0
    
    //offset in Header Bar for iphone x and newer for scrolling down
    static var headerOffset : CGFloat {
        let modelName = UIDevice.modelName
        let devices = ["iPhone X", "iPhone XS", "iPhone XR", "iPhone XS Max", "Simulator iPhone X", "Simulator iPhone XS", "Simulator iPhone XR", "Simulator iPhone XS Max" ]
        if devices.contains(modelName) {
            return 25
        }
        return 0
    }
}
