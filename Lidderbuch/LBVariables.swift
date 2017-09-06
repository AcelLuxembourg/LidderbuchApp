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
    static let tintColor = UIColor(
        hue: (11.0 / 360.0),
        saturation: 0.83,
        brightness: 0.81,
        alpha: 1.0)
    
    // user activity type for song views
    static let viewSongUserActivityType = "lu.acel.Lidderbuch.Song.View"
    
    // it is considered a song view when a user views a song for this duration
    static let songViewDuration = 15.0
}
