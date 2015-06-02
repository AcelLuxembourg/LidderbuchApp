//
//  LBSongMapper.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 13/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import Foundation

class LBSongbook
{
    lazy var songs: [LBSong] = self.load()
    var delegate: LBSongbookDelegate?
    
    var updateTime: NSDate? {
        // determin songbook update time by last updated song time
        var lastUpdatedSong: LBSong? = songs.first
        for i in 1..<songs.count {
            if songs[i].updateTime > lastUpdatedSong!.updateTime {
                lastUpdatedSong = songs[i]
            }
        }
        return lastUpdatedSong?.updateTime
    }
    
    private var songsFileURL: NSURL {
        let documentDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as! NSURL
        return documentDirectoryURL.URLByAppendingPathComponent("songs.json")
    }
    
    static var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter
    }()
    
    private func load() -> [LBSong]
    {
        // schedule songs update at low QOS in 2 seconds
        let utilityQueue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), utilityQueue) {
            self.update()
        }
        
        // try loading from local songs file
        if let data = NSData(contentsOfURL: songsFileURL) {
            return songsWithData(data)
        }
        
        // try loading from songs delivered with the bundle
        if let bundleSongsFilePath = NSBundle.mainBundle().pathForResource("songs", ofType: "json") {
            if let data = NSData(contentsOfFile: bundleSongsFilePath) {
                return songsWithData(data)
            }
        }
        
        return [LBSong]()
    }
    
    private func save()
    {
        if let data = dataWithSongs(songs) {
            data.writeToURL(songsFileURL, atomically: true)
        }
    }
    
    private func update()
    {
        var webServiceUrl = NSURL(string: "https://dev.acel.lu/api/v1/songs")!
        
        // include songbook version in request
        if let updateTime = updateTime {
            let sinceParameterString = LBSongbook.dateFormatter.stringFromDate(updateTime).stringByAddingPercentEncodingForURLQueryValue()!
            webServiceUrl = NSURL(string: "https://dev.acel.lu/api/v1/songs?since=\(sinceParameterString)")!
        }
        
        // retrieve song updates from web service
        let task = NSURLSession.sharedSession().dataTaskWithURL(webServiceUrl, completionHandler: { (data, response, error) in
            if (error == nil)
            {
                // interpret songs from data
                let songs = self.songsWithData(data)
                if count(songs) > 0
                {
                    // integrate each song
                    for song in songs {
                        self.integrateSong(song)
                    }
                    
                    // call delegate in the main queue, it could cause ui changes
                    if let delegate = self.delegate {
                        dispatch_async(dispatch_get_main_queue()) {
                            delegate.songbookDidUpdate(self)
                        }
                    }
                    
                    // save changes
                    self.save()
                }
            }
        })
        
        task.resume()
    }
    
    private func songsWithData(data: NSData) -> [LBSong]
    {
        var songs = [LBSong]()
        var jsonError: NSError?
        
        // interpret json
        if let songsJson = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? [AnyObject] {
            for songJson in songsJson
            {
                // integrate song if initialisation succeeds
                if let song = LBSong(json: songJson) {
                    songs.append(song)
                }
            }
        }
        
        return songs
    }
    
    private func dataWithSongs(songs: [LBSong]) -> NSData?
    {
        // prepare json object
        var jsonObject = [AnyObject]()
        for song in songs {
            jsonObject.append(song.json())
        }
        
        // serialize to NSData
        return NSJSONSerialization.dataWithJSONObject(jsonObject, options: nil, error: nil)
    }
    
    private func integrateSong(song: LBSong)
    {
        // find existing song
        if let index = find(songs, song) {
            if song.updateTime > songs[index].updateTime {
                // replace song
                songs.removeAtIndex(index)
                songs.insert(song, atIndex: index)
            }
        } else {
            // add song
            songs.append(song)
        }
    }
    
    func search(keywords: String, callback: (([LBSong], String) -> Void))
    {
        if count(keywords) < 3 {
            callback(songs, keywords)
            return
        }
        
        // run search in background
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        dispatch_async(backgroundQueue, {
            
            // filter songs by keywords
            var songs = self.songs.filter { (song) -> Bool in
                return song.search(keywords) != 0
            }
            
            // use cached scores to sort by relevance
            songs.sort { (a, b) -> Bool in
                return a.search(keywords) > b.search(keywords)
            }
            
            // propagate results in main queue, they may cause ui changes
            dispatch_async(dispatch_get_main_queue(), {
                callback(songs, keywords)
            })
        })
    }
}

protocol LBSongbookDelegate
{
    func songbookDidUpdate(songbook: LBSongbook)
}
