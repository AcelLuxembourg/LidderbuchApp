//
//  NSDate.swift
//  Lidderbuch
//
//  Created by Fränz Friederes on 02/06/15.
//  Copyright (c) 2015 ACEL. All rights reserved.
//

import Foundation

extension NSDate
{
    
}

func <=(lhs: NSDate, rhs: NSDate) -> Bool {
    return (lhs.timeIntervalSince1970 <= rhs.timeIntervalSince1970)
}

func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return (lhs.timeIntervalSince1970 > rhs.timeIntervalSince1970)
}

func >=(lhs: NSDate, rhs: NSDate) -> Bool {
    return (lhs.timeIntervalSince1970 >= rhs.timeIntervalSince1970)
}