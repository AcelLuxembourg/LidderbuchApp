//
//  LBSongMapper.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import UIKit

class LBSongbook
{
    private var hasChangesToSave = false
    
    var songs: [LBSong]!
    
    var categories: [String]!
    var categorySongs: [String: [LBSong]]!
    
    var delegate: LBSongbookDelegate?
    
    var updateTime: NSDate?
    {
        // determin songbook version by latest song update time
        var updateTime: NSDate?
        for var i = 0; i < songs.count; ++i {
            if updateTime == nil || songs[i].updateTime > updateTime! {
                updateTime = songs[i].updateTime
            }
        }
        
        return updateTime
    }
    
    private var localSongsFileURL: NSURL {
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationDidEnterBackground:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        // schedule songs update at low QOS in 2 seconds
        let utilityQueue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), utilityQueue) {
            self.update()
        }
    }
    
    @IBAction func applicationDidEnterBackground(notification: NSNotification)
    {
        // save songs when entering background
        if hasChangesToSave {
            save()
        }
    }
    
    private func load() -> [LBSong]
    {
        var songs = [LBSong]()
        
        // try loading from local songs file
        if let data = NSData(contentsOfURL: localSongsFileURL) {
            songs = songsWithData(data)
        }
        
        if songs.isEmpty
        {
            // try loading songs delivered with bundle
            if let
                bundleSongsFilePath = NSBundle.mainBundle().pathForResource("songs", ofType: "json") ,
                data = NSData(contentsOfFile: bundleSongsFilePath)
            {
                songs = songsWithData(data)
            }
        }
        
        return songs
    }
    
    private func save()
    {
        if let data = dataWithSongs(songs) {
            data.writeToURL(localSongsFileURL, atomically: true)
            hasChangesToSave = false
        }
    }
    
    private func update()
    {
        var webServiceUrl: NSURL = NSURL(string: LBVariables.songbookApiEndpoint)!
        
        // include songbook version in request
        if let updateTime = updateTime {
            webServiceUrl = NSURL(string: "\(LBVariables.songbookApiEndpoint)?since=\(Int(updateTime.timeIntervalSince1970))")!
        }
        
        // retrieve song updates from web service
        let task = NSURLSession.sharedSession().dataTaskWithURL(
            webServiceUrl, completionHandler: { (data, response, error) in
            
            if data != nil && error == nil
            {
                // integrate songs from data and preserve meta
                let songs = self.songsWithData(data!)
                self.integrateSongs(songs, replaceMeta: false)
            }
        })
        
        task.resume()
    }
    
    private func songsWithData(data: NSData) -> [LBSong]
    {
        var songs = [LBSong]()
        
        // try to read json data
        if let songsJson = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [AnyObject]
        {
            for songJson in songsJson
            {
                // add song if initialisation succeeds
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
    
    func integrateSongs(songs: [LBSong], replaceMeta: Bool)
    {
        // integrate each song and ask last one to propagate changes
        for (var i = 0; i < songs.count; i++) {
            integrateSong(songs[i], replaceMeta: false, propagate: (i != songs.count - 1))
        }
    }
    
    func integrateSong(song: LBSong, replaceMeta: Bool, propagate: Bool = true)
    {
        // is the song already included
        if let index = songs.indexOf(song)
        {
            let oldSong = songs[index]
            if song.updateTime > oldSong.updateTime ||
                (replaceMeta && song.updateTime == oldSong.updateTime)
            {
                if !replaceMeta {
                    song.bookmarked = oldSong.bookmarked
                    song.views = oldSong.views
                    song.viewTime = oldSong.viewTime
                }
                
                // replace song
                songs.removeAtIndex(index)
                songs.insert(song, atIndex: index)
            }
        }
        else
        {
            // add song to library
            songs.append(song)
        }
        
        if propagate
        {
            reloadMeta()
            
            hasChangesToSave = true
            
            if let delegate = self.delegate {
                dispatch_async(dispatch_get_main_queue()) {
                    delegate.songbookDidUpdate(self)
                }
            }
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
        let bookmarkCategory = NSLocalizedString("Markéiert", comment: "Bookmark category title")
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
        // handle song number
        if let number = Int(keywords) {
            if let song = songWithNumber(number) {
                callback([song], keywords)
            } else {
                callback([LBSong](), keywords)
            }
            
            return
        }
        
        // return no results when query too short
        if keywords.characters.count < 2 {
            callback([LBSong](), keywords)
            return
        }
        
        // run search in background to prevent UI lag
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
            
            // propagate results in main queue, they may cause UI changes
            dispatch_async(dispatch_get_main_queue(), {
                callback(songs, keywords)
            })
        })
    }
    
    func songWithId(id: Int) -> LBSong?
    {
        let index = songs.indexOf({ (song: LBSong) -> Bool in
            return song.id == id
        })
        
        return (index != nil ? songs[index!] : nil)
    }
    
    func songWithNumber(number: Int) -> LBSong?
    {
        let index = songs.indexOf({ (song: LBSong) -> Bool in
            return song.number == number
        })
        
        return (index != nil ? songs[index!] : nil)
    }
    
    func songWithURL(url: NSURL) -> LBSong?
    {
        let index = songs.indexOf { (song: LBSong) -> Bool in
            
            // only compare the path part of each url
            // allow different hosts (e.g. with / without www)
            // allow different schemes (e.g. http, https)
            return url.path == song.url.path
        }
        
        return (index != nil ? songs[index!] : nil)
    }
}

protocol LBSongbookDelegate
{
    func songbookDidUpdate(songbook: LBSongbook)
}
