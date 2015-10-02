//
//  StudentLocation.swift
//  On the Map
//
//  Created by Ethan Haley on 8/20/15.
//  Copyright (c) 2015 Ethan Haley. All rights reserved.
//

import Foundation

// Each student/user will have one of these associated with himself
struct StudentLocation {
    var createdAt: String  // Parse API date for User's initial info
    var firstName: String?
    var lastName: String?
    var latitude: Double
    var longitude: Double
    var mapString: String?  // Text User used to locate himself
    var mediaURL: String    // Text User entered to locate a URL
    let objectId: String  // Parse API unique User identifier
    var uniqueKey: String?  // Udacity unique User identifier
    var updatedAt: String  // Parse API date for User's updated info
    
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