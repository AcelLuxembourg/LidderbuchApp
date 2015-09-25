//
//  LBSong.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 04/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import Foundation

class LBSong: CustomStringConvertible
{
    var id: Int!
    var name: String!
    var language: String!
    var url: NSURL!
    var category: String!
    var position: Int!
    var paragraphs: [LBParagraph]!
    var bookmarked: Bool = false
    
    var number: Int?
    var way: String?
    var year: Int?
    var lyricsAuthor: String?
    var melodyAuthor: String?
    var updateTime: NSDate?
    
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
            // retrieve required attributes
            if let
                id = songJson["id"] as? Int,
                name = songJson["name"] as? String,
                language = songJson["language"] as? String,
                category = songJson["category"] as? String,
                position = songJson["position"] as? Int,
                paragraphsJson = songJson["paragraphs"] as? [AnyObject],
            
                urlString = songJson["url"] as? String,
                url = NSURL(string: urlString)
            {
                // basic attributes
                self.id = id
                self.name = name
                self.language = language
                self.url = url
                self.category = category
                self.position = position
                
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
                self.year = songJson["year"] as? Int
                self.lyricsAuthor = songJson["lyrics_author"] as? String
                self.melodyAuthor = songJson["melody_author"] as? String
                
                if let timestamp = songJson["update_time"] as? Int {
                    updateTime = NSDate(timeIntervalSince1970: Double(timestamp))
                }
                
                if songJson["bookmarked"] as? Bool == true {
                    self.bookmarked = true
                }
                
                return
            }
        }
        
        return nil
    }
    
    func json() -> [String: AnyObject]
    {
        // prepare paragraphs json object
        var paragraphsJsonObject = [AnyObject]()
        
        for paragraph in paragraphs {
            paragraphsJsonObject.append(paragraph.json())
        }
        
        // prepare json object
        var jsonObject: [String: AnyObject!] = [
            "id": id,
            "name": name,
            "language": language,
            "url": url.absoluteString,
            "category": category,
            "position": position,
            "bookmarked": bookmarked,
            "paragraphs": paragraphsJsonObject,
            
            // replace nil values by NSNull values
            "number": (number != nil ? number! : NSNull()),
            "way": (way != nil ? way! : NSNull()),
            "year": (year != nil ? year! : NSNull()),
            "lyrics_author": (lyricsAuthor != nil ? lyricsAuthor! : NSNull()),
            "melody_author": (melodyAuthor != nil ? melodyAuthor! : NSNull()),
            "update_time": (updateTime != nil ? Int(updateTime!.timeIntervalSince1970) : NSNull()),
        ]
        
        return jsonObject
    }
    
    private var lastSearchKeywords: String?
    private var lastSearchScore: Int?
    
    func search(keywords: String) -> Int
    {
        // retrieve cached result
        if lastSearchKeywords == keywords {
            return lastSearchScore!
        }
        
        // determin search score for given keywords
        var score = 0
        
        // search in meta data
        score += name.countOccurencesOfString(keywords)
        
        if let way = self.way {
            score += way.countOccurencesOfString(keywords)
        }
        
        if let lyricsAuthor = self.lyricsAuthor {
            score += lyricsAuthor.countOccurencesOfString(keywords)
        }
        
        if lyricsAuthor != melodyAuthor {
            if let melodyAuthor = self.melodyAuthor {
                score += melodyAuthor.countOccurencesOfString(keywords)
            }
        }
        
        // an occurence in meta data is 3x more important
        score *= 3
        
        // search score of paragraphs
        for paragraph in paragraphs {
            score += paragraph.search(keywords)
        }
        
        // cache search result
        lastSearchKeywords = keywords
        lastSearchScore = score
        
        return score
    }
}

extension LBSong: Equatable {}

func ==(lhs: LBSong, rhs: LBSong) -> Bool {
    return (lhs.id == rhs.id)
}