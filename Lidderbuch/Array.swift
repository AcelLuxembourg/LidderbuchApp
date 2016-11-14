//
//  Array.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 12/11/16.
//  Copyright © 2016 ACEL. All rights reserved.
//

import Foundation

extension Array
{
    
    var random: Element? {
        if self.count == 0 {
            return nil
        }

        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
