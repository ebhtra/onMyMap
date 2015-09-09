//
//  StudentLocation.swift
//  On the Map
//
//  Created by Ethan Haley on 8/20/15.
//  Copyright (c) 2015 Ethan Haley. All rights reserved.
//

import Foundation

struct StudentLocation {
    var createdAt: String
    var firstName: String?
    var lastName: String?
    var latitude: Double
    var longitude: Double
    var mapString: String?
    var mediaURL: String
    let objectId: String
    var uniqueKey: String?
    var updatedAt: String
    
    init(dict: [String: AnyObject]) {
        createdAt = dict["createdAt"] as! String
        firstName = dict["firstName"] as? String
        lastName = dict["lastName"] as? String
        latitude = dict["latitude"] as! Double
        longitude = dict["longitude"] as! Double
        mapString = dict["mapString"] as? String
        mediaURL = dict["mediaURL"] as! String
        objectId = dict["objectId"] as! String
        uniqueKey = dict["uniqueKey"] as? String
        updatedAt = dict["updatedAt"] as! String
    }
}