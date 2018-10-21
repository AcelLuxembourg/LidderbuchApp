//
//  LBSongMapper.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import UIKit

class LBSongbook: NSObject
{
    fileprivate var hasChangesToSave = false
    
    var songs: [LBSong]!
    
    var categories: [String]!
    var categorySongs: [String: [LBSong]]!
    
    var delegate: LBSongbookDelegate?
    
    fileprivate var songsUrl2017 = "songs_2017";
    fileprivate var songsUrl = "songs_2015";
    
    var updateTime: Date?
    {
        // determin songbook version by latest song update time
        var updateTime: Date?
        for song in songs {
            if updateTime == nil || song.updateTime > updateTime! {
                updateTime = song.updateTime as Date?
            }
        }
        
        return updateTime
    }
    
    fileprivate var isAfterPressConference: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let pc = formatter.date(from: "2017-09-15 09:45:00")

        let today = Date();

        return today > pc!
    }
    
    fileprivate var correctAssets: String {
        var url = songsUrl;
        if(isAfterPressConference) {
            url = songsUrl2017;
        }
        
        return url;
    }
    
    fileprivate var localSongsFileURL: URL {
        let fileManager = FileManager.default
        let documentDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let url = correctAssets + ".json";
        
        return documentDirectoryURL.appendingPathComponent(url)
    }
    
    override init()
    {
        super.init()
        
        // load songs
        songs = load()
        reloadMeta()
        
        // react on application entering background
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        // schedule songs update at low QOS in 2 seconds
        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).asyncAfter(deadline: .now() + 2.0) {
            self.update()
        }
    }
    
    func applicationDidEnterBackground(_ notification: Notification)
    {
        // save songs when entering background
        if hasChangesToSave {
            save()
        }
    }
    
    fileprivate func load() -> [LBSong]
    {
        var songs = [LBSong]()
        
        // try loading from local songs file
        if let data = try? Data(contentsOf: localSongsFileURL) {
            songs = songsWithData(data)
        }
        
        if songs.isEmpty
        {
            // try loading songs delivered with bundle
            if let
                bundleSongsFilePath = Bundle.main.path(forResource: correctAssets, ofType: "json") ,
                let data = try? Data(contentsOf: URL(fileURLWithPath: bundleSongsFilePath))
            {
                songs = songsWithData(data)
            }
        }
        
        return songs
    }
    
    fileprivate func save()
    {
        if let data = dataWithSongs(songs) {
            try? data.write(to: localSongsFileURL, options: [.atomic])
            hasChangesToSave = false
        }
    }
    
    fileprivate func update()
    {
        var webServiceUrl: URL = URL(string: LBVariables.songbookApiEndpoint)!
        
        // include songbook version in request
        if let updateTime = updateTime {
            webServiceUrl = URL(string: "\(LBVariables.songbookApiEndpoint)?since=\(Int(updateTime.timeIntervalSince1970))")!
        }
        
        // retrieve song updates from web service
        let task = URLSession.shared.dataTask(
            with: webServiceUrl, completionHandler: { (data, response, error) in
            
            if data != nil && error == nil
            {
                // integrate songs from data and preserve meta
                let songs = self.songsWithData(data!)
                self.integrateSongs(songs, replaceMeta: false)
            }
        })
        
        task.resume()
    }
    
    fileprivate func songsWithData(_ data: Data) -> [LBSong]
    {
        var songs = [LBSong]()
        
        // try to read json data
        if let songsJson = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [AnyObject]
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
    
    fileprivate func dataWithSongs(_ songs: [LBSong]) -> Data?
    {
        // prepare json object
        var jsonObject = [AnyObject]()
        for song in songs {
            jsonObject.append(song.json() as AnyObject)
        }
        
        // serialize to NSData
        return try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
    
    func integrateSongs(_ songs: [LBSong], replaceMeta: Bool)
    {
        // integrate each song and ask last one to propagate changes
        for i in 0 ..< songs.count {
            integrateSong(songs[i], replaceMeta: false, propagate: (i == songs.count - 1))
        }
    }
    
    func integrateSong(_ song: LBSong, replaceMeta: Bool, propagate: Bool = true)
    {
        // is the song already included
        if let index = songs.index(of: song)
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
                songs[index] = song
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
                DispatchQueue.main.async {
                    delegate.songbookDidUpdate(self)
                }
            }
        }
    }
    
    fileprivate func reloadMeta()
    {
        // sort songs by position
        songs.sort { $1.position > $0.position }
        
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
            if categories.index(of: song.category) == nil {
                categories.append(song.category)
                categorySongs[song.category] = [song]
            } else {
                categorySongs[song.category]!.append(song)
            }
        }
    }
    
    func search(_ keywords: String, callback: @escaping (([LBSong], String) -> Void))
    {
        // handle song number
        
        if let song = songWithNumber(keywords) {
            callback([song], keywords)
            return
        }
        
        // return no results when query too short
        if keywords.count < 2 {
            callback([LBSong](), keywords)
            return
        }
        
        // run search in background to prevent UI lag
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        backgroundQueue.async(execute: {
            
            // filter songs by keywords
            var songs = self.songs.filter { (song) -> Bool in
                return song.search(keywords) != 0
            }
            
            // use cached scores to sort by relevance
            songs.sort { (a, b) -> Bool in
                return a.search(keywords) > b.search(keywords)
            }
            
            // propagate results in main queue, they may cause UI changes
            DispatchQueue.main.async(execute: {
                callback(songs, keywords)
            })
        })
    }
    
    func songWithId(_ id: Int) -> LBSong?
    {
        let index = songs.index(where: { (song: LBSong) -> Bool in
            return song.id == id
        })
        
        return (index != nil ? songs[index!] : nil)
    }
    
    func songWithNumber(_ number: String) -> LBSong?
    {
        let index = songs.index(where: { (song: LBSong) -> Bool in
            return song.number?.lowercased() == number.lowercased()
        })
        
        return (index != nil ? songs[index!] : nil)
    }
    
    func songWithURL(_ url: URL) -> LBSong?
    {
        let index = songs.index { (song: LBSong) -> Bool in
            
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
    func songbookDidUpdate(_ songbook: LBSongbook)
}
