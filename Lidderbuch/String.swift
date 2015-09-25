//
//  String.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 17/05/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import Foundation

extension String
{
    
    func countOccurencesOfString(
        string: String,
        compareOptions: NSStringCompareOptions = NSStringCompareOptions.DiacriticInsensitiveSearch.union(.CaseInsensitiveSearch)) -> Int
    {
        var count = 0
        
        var index: String.Index? = startIndex
        while (index != nil) {
            if let occurenceRange = rangeOfString(string, options: compareOptions, range: index!..<endIndex) {
                count++
                index = occurenceRange.endIndex
            } else {
                index = nil
            }
        }
        
        return count
    }
    
    func stringByAddingPercentEncodingForURLQueryValue() -> String?
    {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("-._~")
        return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
    }
}