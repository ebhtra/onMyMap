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
    
    
    func loginThruUdacity(dict: [String: AnyObject], completionHandler: (success: Bool, error: String?) -> Void) {
               
        let urlString = OnTheMapClient.Constants.UdacityBaseSecureUrl + OnTheMapClient.Methods.UdacitySession
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(dict, options: [])
        } catch _ as NSError {
            request.HTTPBody = nil
        }
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                
                completionHandler(success: false, error: error.localizedDescription)
                
            } else {
                var parsingError: NSError?
                
                // trim extra 5 Udacity chars
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                
                let parsedResult: AnyObject?
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments)
                } catch let error as NSError {
                    parsingError = error
                    parsedResult = nil
                } catch {
                    fatalError()
                }
                
                if let _ = parsingError {
                    completionHandler(success: false, error: "problems parsing the JSON")
                } else {
                    if let err = parsedResult?.valueForKey("error") as? String {
                        completionHandler(success: false, error: err)
                    } else {
                        // use the presence of "account["key"]" as the test of success
                        if let account = parsedResult?.valueForKey("account") as? NSDictionary {
                            if let userKey = account["key"] as? String {
                                
                                // search Parse for current user
                                self.findUserInParse(userKey) { success, errorString in
                                    if success {
                                        completionHandler(success: true, error: nil)
                                    } else {
                                        completionHandler(success: false, error: errorString)
                                    }
                                }
                            } else {
                                completionHandler(success: false, error: "Unable to find user key in Parse")
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
    
    func findUserInParse(key: String, completion: (success: Bool, error: String?) -> Void) {
        // check the parsed results of Client task for a user's unique key. Update user's known info accordingly
        userSearchTask(key) { jsonResult, error in
            if let results = jsonResult.valueForKey("results") as? [[String: AnyObject]] {
                if results.isEmpty {
                    // user is not stored in Parse yet
                    StudentsList.studentInfoDict = ["uniqueKey": "\(key)"]
                } else {
                    // store what is listed on Parse for user
                    StudentsList.studentInfoDict = results[0]
                }
                completion(success: true, error: nil)
            } else {
                completion(success: false, error: "Could not find that user.")
            }
        }
    }
    
    func getUserNameAndPostToParse(studentDict: [String: AnyObject], completionHandler: (success: Bool, error: String?) -> Void) {
        getUdacityUsernameTask(studentDict) { newStudentDict, nsError in
            if nsError != nil {
                completionHandler(success: false, error: nsError!.localizedDescription)
            } else {
                self.postToParseTask(newStudentDict, completionHandler: completionHandler)
            }
        }
    }
    
    func refreshRoster(completion: (success: Bool) -> Void) {
        // build parameters array
        var params = [String: AnyObject]()
        params[OnTheMapClient.ParameterKeys.Limit] = batchSize
        params[OnTheMapClient.ParameterKeys.Skip] = StudentsList.roster.count
        params[OnTheMapClient.ParameterKeys.Order] = "-updatedAt"
        
        // no method to add here:
        let method = ""
        
        populateRosterTask(method, parameters: params) { jsonResult, error in
            if error != nil {
                completion(success: false)
            } else {
                // An array of students was returned from Parse. Store each one as a StudentLocation struct in StudentsList  
                if let results = jsonResult.valueForKey("results") as? [[String: AnyObject]] {
                    for dict in results {
                        let newStudent = StudentLocation(dict: dict)
                        StudentsList.roster.append(newStudent)
                    }
                    completion(success: true)
                }
            }
        }
    }
}