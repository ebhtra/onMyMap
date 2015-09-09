//
//  OnTheMapClient.swift
//  On the Map
//
//  Created by Ethan Haley on 8/10/15.
//  Copyright (c) 2015 Ethan Haley. All rights reserved.
//

import Foundation

class OnTheMapClient: NSObject {
    
    static let sharedInstance = OnTheMapClient()
    
    //static var loggedIn = false
    
    static let UdacityBaseSecureUrl = "https://www.udacity.com/api/"
    static let UdacitySignupURL = "https://www.google.com/url?q=https%3A%2F%2Fwww.udacity.com%2Faccount%2Fauth%23!%2Fsignin&sa=D&sntz=1&usg=AFQjCNERmggdSkRb9MFkqAW_5FgChiCxAQ"
    
    override init() {
        println("just initialized an OnTheMapClient object")
    }
    
    func populateRosterTask(completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
       
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=10")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error!)
            } else {
                //println(NSString(data: data, encoding: NSUTF8StringEncoding))
                var parseError: NSError?
                let results = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError) as! NSDictionary
                completionHandler(result: results, error: nil)
            }
            println("The list of students is \(StudentsList.roster.count) entries long")
        }
        task.resume()
        
        return task
    }
    
    class func logOut() {
        println("about to attempt log out from client class")
        
        let request = NSMutableURLRequest(URL: NSURL(string: UdacityBaseSecureUrl + "session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie?
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                println("error with logout data task: \(error)")
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
}