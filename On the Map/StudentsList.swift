//
//  StudentsList.swift
//  On the Map
//
//  Created by Ethan Haley on 8/20/15.
//  Copyright (c) 2015 Ethan Haley. All rights reserved.
//

import Foundation

struct StudentsList {
    // currently know info about user
    static var studentInfoDict: [String: AnyObject]!
    
    // current list of students on the map
    static var roster = [StudentLocation]()
}