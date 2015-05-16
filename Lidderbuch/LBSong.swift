//
//  LBSong.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 04/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import Foundation

class LBSong: Printable
{
    var id: Int!
    var name: String!
    var language: String!
    var url: NSURL!
    var updateTime: NSDate!
    var paragraphs: [LBParagraph]!
    
    var number: Int?
    var way: String?
    var category: String?
    var year: Int?
    var lyricsAuthor: String?
    var melodyAuthor: String?
    
    var description: String {
        return "\(id): \(name)"
    }
    
    var preview: String {
        // grab the two first lines of a song
        // if a paragraph has only one line, the next one will be included too
        var preview = "", lines = 0, i = -1
        while (++i < paragraphs.count && lines < 2) {
            let paragraphLines = paragraphs[i].content.componentsSeparatedByString("\n")
            var j = -1
            while (++j < paragraphLines.count && lines < 2) {
                preview += (lines > 0 ? "\n" : "") + paragraphLines[j]
                lines++
            }
        }
        return preview
    }
    
    init?(json: AnyObject)
    {
        if let songJson = json as? [String: AnyObject]
        {
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            
            // retrieve required attributes
            if let
                id = songJson["id"] as? Int,
                name = songJson["name"] as? String,
                language = songJson["language"] as? String,
                paragraphsJson = songJson["paragraphs"] as? [AnyObject],
            
                urlString = songJson["url"] as? String,
                url = NSURL(string: urlString),
                
                updateTimeString = songJson["update_time"] as? String,
                updateTime = dateFormatter.dateFromString(updateTimeString)
            {
                // basic attributes
                self.id = id
                self.name = name
                self.language = language
                self.url = url
                self.updateTime = updateTime
                
                // paragraphs
                self.paragraphs = [LBParagraph]()
                for paragraphJson in paragraphsJson {
                    if let paragraph = LBParagraph(json: paragraphJson) {
                        self.paragraphs.append(paragraph)
                    }
                }
                
                // optional attributes
                self.number = songJson["number"] as? Int
                self.way = songJson["way"] as? String
                self.category = songJson["category"] as? String
                self.year = songJson["year"] as? Int
                self.lyricsAuthor = songJson["lyrics_author"] as? String
                self.melodyAuthor = songJson["melody_author"] as? String
                
                return
            }
        }
        
        return nil
    }
    
    func filter(keywords: String) -> Bool
    {
        var i = -1, filter = false
        while (++i < paragraphs.count && !filter) {
            filter = paragraphs[i].filter(keywords)
        }
        return filter
    }
}

extension LBSong: Equatable {}

func ==(lhs: LBSong, rhs: LBSong) -> Bool
{
    return (lhs.id == rhs.id)
}