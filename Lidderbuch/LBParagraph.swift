//
//  LBParagraph.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 08/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
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
                type = songJson["type"] as? String,
                content = songJson["content"] as? String
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
    
    func search(keywords: String) -> Int
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