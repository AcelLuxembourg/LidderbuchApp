//
//  NSDate.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
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