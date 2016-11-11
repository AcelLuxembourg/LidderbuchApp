//
//  NSDate.swift
//  Lidderbuch
//
//  Copyright (c) 2015 Fränz Friederes <fraenz@frieder.es>
//  Licensed under the MIT license.
//

import Foundation

extension Date
{
    
}

func <=(lhs: Date, rhs: Date) -> Bool {
    return (lhs.timeIntervalSince1970 <= rhs.timeIntervalSince1970)
}

func >(lhs: Date, rhs: Date) -> Bool {
    return (lhs.timeIntervalSince1970 > rhs.timeIntervalSince1970)
}

func >=(lhs: Date, rhs: Date) -> Bool {
    return (lhs.timeIntervalSince1970 >= rhs.timeIntervalSince1970)
}
