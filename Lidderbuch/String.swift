//
//  String.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import Foundation

extension String
{
    
    func countOccurencesOfString(
        _ string: String,
        compareOptions: NSString.CompareOptions = NSString.CompareOptions.diacriticInsensitive.union(.caseInsensitive)) -> Int
    {
        var count = 0
        
        var index: String.Index? = startIndex
        while (index != nil) {
            if let occurenceRange = range(of: string, options: compareOptions, range: index!..<endIndex) {
                count += 1
                index = occurenceRange.upperBound
            } else {
                index = nil
            }
        }
        
        return count
    }
    
    func stringByAddingPercentEncodingForURLQueryValue() -> String?
    {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-._~")
        return addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)
    }
}
