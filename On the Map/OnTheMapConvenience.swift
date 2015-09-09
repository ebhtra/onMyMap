//
//  OnTheMapConvenience.swift
//  On the Map
//
//  Created by Ethan Haley on 9/2/15.
//  Copyright (c) 2015 Ethan Haley. All rights reserved.
//

import Foundation
import UIKit

extension OnTheMapClient {
    
    func loginThruUdacity(loginVC: LoginViewController, dict: [String: AnyObject], completionHandler: (success: Bool, error: String?) -> Void) {
        
        var urlString = OnTheMapClient.UdacityBaseSecureUrl + "session"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonError: NSError?
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(dict, options: nil, error: &jsonError)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                println("Sorry--", message: "There was a problem with the login (task failed).")
            } else {
                var parsingError: NSError?
                
                /* trim extra 5 Udacity chars */
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
                let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
                
                if let error = parsingError {
                    println("problems parsing the JSON")
                } else {
                    if let err = parsedResult?.valueForKey("error") as? String {
                        loginVC.showErrorAlert("Login error--", message: err)
                    } else {
                        println(parsedResult!)
                        if let account = parsedResult?.valueForKey("account") as? NSDictionary {
                            if let success = account["registered"] as? Int {
                                if success == 1 {
                                    completionHandler(success: true, error: nil)
                                }
                            }
                        } else {
                            completionHandler(success: false, error: "Failed to login to Udacity")
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func refreshRoster(completion: (success: Bool) -> Void) {
        
        populateRosterTask() { jsonResult, error in
            
            if let results = jsonResult.valueForKey("results") as? [[String: AnyObject]] {
                StudentsList.roster = []
                for dict in results {
                    let newStudent = StudentLocation(dict: dict)
                    StudentsList.roster.append(newStudent)
                }
                completion(success: true)
            } else {
                println(error?.localizedDescription)
                completion(success: false)
            }
        }
    }
    
    func loadTheMap(hostVC: MapTabViewController) {
        refreshRoster { success in
            if success {
                hostVC.loadPins()
            }
        }
    }
    
    func loadTheList(hostVC: ListTabViewController) {
        refreshRoster { success in
            if success {
                hostVC.students = StudentsList.roster
                hostVC.table.reloadData()
            }
        }
    }
}