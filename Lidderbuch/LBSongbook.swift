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
    var songs: [LBSong]!
    
    var categories: [String]!
    var categorySongs: [String: [LBSong]]!
    
    var delegate: LBSongbookDelegate?
    
    var updateTime: NSDate? {
        // determin songbook update time by last updated song time
        var updateTime: NSDate? = nil
        for var i = 1; i < songs.count; ++i {
            if let songUpdateTime = songs[i].updateTime {
                if updateTime == nil {
                    updateTime = songUpdateTime
                } else if songUpdateTime > updateTime! {
                    updateTime = songUpdateTime
                }
            }
        }
        return updateTime
    }
    
    private var songsFileURL: NSURL {
        let fileManager = NSFileManager.defaultManager()
        let documentDirectoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! 
        return documentDirectoryURL.URLByAppendingPathComponent("songs.json")
    }
    
    init()
    {
        // load songs
        songs = load()
        reloadMeta()
        
        // react on application entering background
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationDidEnterBackground:"), name: "UIApplicationDidEnterBackgroundNotification", object: nil)
        
        // schedule songs update at low QOS in 2 seconds
        let utilityQueue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), utilityQueue) {
            self.update()
        }
    }
    
    private func load() -> [LBSong]
    {
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
    
    @IBAction func applicationDidEnterBackground(notification: NSNotification)
    {
        save()
    }
    
    private func save()
    {
        if let data = dataWithSongs(songs) {
            data.writeToURL(songsFileURL, atomically: true)
        }
    }
    
    private func update()
    {
        var webServiceUrl: NSURL = NSURL(string: "https://dev.acel.lu/api/v1/songs")!
        
        // include songbook version in request
        if let updateTime = updateTime {
            webServiceUrl = NSURL(string: "https://dev.acel.lu/api/v1/songs?since=\(Int(updateTime.timeIntervalSince1970))")!
        }
        
        // retrieve song updates from web service
        let task = NSURLSession.sharedSession().dataTaskWithURL(webServiceUrl, completionHandler: { (data, response, error) in
            if (error == nil)
            {
                // interpret songs from data
                let songs = self.songsWithData(data)
                if songs.count > 0
                {
                    // integrate each song
                    for song in songs {
                        self.integrateSong(song, preserveMeta: true, propagate: false)
                    }
                    
                    // reload categories
                    self.reloadMeta()
                    
                    // call delegate in the main queue, it could cause ui changes
                    if let delegate = self.delegate {
                        dispatch_async(dispatch_get_main_queue()) {
                            delegate.songbookDidUpdate(self)
                        }
                    }
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
        if let songsJson = NSJSONSerialization.JSONObjectWithData(data, options: []) as? [AnyObject] {
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
        return try? NSJSONSerialization.dataWithJSONObject(jsonObject, options: [])
    }
    
    func integrateSong(song: LBSong, preserveMeta: Bool, propagate: Bool = true)
    {
        // find existing song
        if let index = songs.indexOf(song) {
            let oldSong = songs[index]
            if (song.updateTime == nil || oldSong.updateTime == nil)
                || (song.updateTime! > oldSong.updateTime!)
            {
                // preserve meta
                if preserveMeta {
                    song.bookmarked = oldSong.bookmarked
                }
                
                // replace song
                songs.removeAtIndex(index)
                songs.insert(song, atIndex: index)
            }
        } else {
            // add song
            songs.append(song)
        }
        
        if propagate {
            reloadMeta()
            delegate?.songbookDidUpdate(self)
        }
    }
    
    private func reloadMeta()
    {
        // sort songs by position
        songs.sortInPlace { $1.position > $0.position }
        
        // collect songs for each category
        categories = [String]()
        categorySongs = [String: [LBSong]]()
        
        // create bookmark category
        let bookmarkCategory = "Markéiert"
        categories.append(bookmarkCategory)
        categorySongs[bookmarkCategory] = [LBSong]()
        
        for song in songs
        {
            // add song to bookmarks
            if song.bookmarked {
                categorySongs[bookmarkCategory]!.append(song)
            }
            
            // add song to it's category
            if categories.indexOf(song.category) == nil {
                categories.append(song.category)
                categorySongs[song.category] = [song]
            } else {
                categorySongs[song.category]!.append(song)
            }
        }
    }
    
    func search(keywords: String, callback: (([LBSong], String) -> Void))
    {
        if keywords.characters.count < 3 {
            callback([LBSong](), keywords)
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
            songs.sortInPlace { (a, b) -> Bool in
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
