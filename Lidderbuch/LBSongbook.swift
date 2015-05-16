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
    
    func filterSongs(keywords: String) -> [LBSong]
    {
        return songs.filter { (song: LBSong) -> Bool in
            return song.filter(keywords)
        }
    }
    
    private func load() -> [LBSong]
    {
        return [LBSong]()
    }
    
    func update()
    {
        let url = NSURL(string: "https://dev.acel.lu/api/v1/songs")!
        let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) in
            if (error == nil) {
                self.integrateSongsWithData(data)
            }
        })
        
        task.resume()
    }
    
    private func integrateSongsWithData(data: NSData)
    {
        var songs = [LBSong]()
        var jsonError: NSError?
        
        // interpret json
        if let songsJson = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? [AnyObject] {
            for songJson in songsJson
            {
                // integrate song if initialisation succeeds
                if let song = LBSong(json: songJson) {
                    integrateSong(song)
                }
            }
        }
        
        // call delegate in the main queue, it could cause ui changes
        if (delegate != nil) {
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.songbookDidChange(self)
            }
        }
    }
    
    private func integrateSong(song: LBSong)
    {
        // find and remove existing song
        if let index = find(songs, song) {
            songs.removeAtIndex(index)
        }
        
        // add song
        songs.append(song)
    }
}

protocol LBSongbookDelegate
{
    func songbookDidChange(songbook: LBSongbook)
}
