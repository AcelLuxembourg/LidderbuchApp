//
//  LBParagraph.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import Foundation

class LBParagraph
{
    var id: Int!
    var type: String!
    var content: String!
    
    var refrain: Bool {
        return type == "refrain"
    }
    
    init?(json: AnyObject)
    {
        if let songJson = json as? [String: AnyObject]
        {
            // retrieve required attributes
            if let
                id = songJson["id"] as? Int,
                let type = songJson["type"] as? String,
                let content = songJson["content"] as? String
            {
                // basic attributes
                self.id = id
                self.type = type
                self.content = content
                
                return
            }
        }
        
        return nil
    }
    
    func json() -> [String: AnyObject]
    {
        var json = [String: AnyObject]()
        json["id"] = id as AnyObject
        json["type"] = type as AnyObject
        json["content"] = content as AnyObject
        return json
    }
    
    func search(_ keywords: String) -> Int
    {
        // search score is determined by occurence count
        return content.countOccurencesOfString(keywords)
    }
}

extension LBParagraph: Equatable {}

func ==(lhs: LBParagraph, rhs: LBParagraph) -> Bool
{
    return (lhs.id == rhs.id)
}
