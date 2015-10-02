//
//  OnTheMapClient.swift
//  On the Map
//
//  Created by Ethan Haley on 8/10/15.
//  Copyright (c) 2015 Ethan Haley. All rights reserved.
//

import Foundation

class OnTheMapClient: NSObject {
    
    static let sharedInstance = OnTheMapClient()  // Singleton instance of the class
   
    let batchSize = 100 // how many students to add per query?
    
    // GET students from Parse
    func populateRosterTask(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseParseRequest + method + OnTheMapClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue(OnTheMapClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OnTheMapClient.Constants.ParseRESTkey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error!)
            } else {
                var parseError: NSError?
                let results = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError) as! NSDictionary
                completionHandler(result: results, error: nil)
            }
        }
        task.resume()
        
        return task
    }
    
    // GET a user from Parse using a Udacity unique key as ID
    func userSearchTask(userKey: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: NSURL(string: OnTheMapClient.Constants.BaseParseRequest + "?where=%7B%22uniqueKey%22%3A%22" + userKey + "%22%7D")!)
        request.addValue(OnTheMapClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OnTheMapClient.Constants.ParseRESTkey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error!)
            } else {
                var parseError: NSError?
                let results = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError) as! NSDictionary
                completionHandler(result: results, error: nil)
            }
        }
        task.resume()
        
        return task
    }

    // PUT/update a user's info on Parse
    func updateUserTask(dict: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let objID = dict["objectId"] as! String
        var jsonError: NSError?
        let request = NSMutableURLRequest(URL: NSURL(string: OnTheMapClient.Constants.BaseParseRequest + "/" + objID)!)
        request.HTTPMethod = "PUT"
        request.addValue(OnTheMapClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OnTheMapClient.Constants.ParseRESTkey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(dict, options: nil, error: &jsonError)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error!)
            } else {
                var parseError: NSError?
                let results = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError) as! NSDictionary
                completionHandler(result: results, error: nil)
            }
        }
        task.resume()
        
        return task
    }
    
    // GET a user's name from Udacity using uniqueKey as ID
    // This method takes the user's partial info as a variable parameter so that it can update it
    func getUdacityUsernameTask(var dict: [String: AnyObject], completionHandler: (result: [String: AnyObject], error: NSError?) -> Void) -> NSURLSessionDataTask {
        let id = dict["uniqueKey"] as! String
        let request = NSMutableURLRequest(URL: NSURL(string: OnTheMapClient.Constants.UdacityBaseSecureUrl + "users/" + id)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: dict, error: error)
            } else {
                var parseError: NSError?
                /* trim extra udacity chars */
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
                
                if let error = parseError {
                    completionHandler(result: dict, error: error)
                } else {
                    if let err = parsedResult?.valueForKey("error") as? String {
                        let nsErr = NSError(domain: "Udacity parsing error", code: 0, userInfo: [NSLocalizedDescriptionKey: err])
                        completionHandler(result: dict, error: nsErr)
                    } else {
                        // use presence of "user" dictionary in parsed results as a test of success
                        if let user = parsedResult?.valueForKey("user") as? NSDictionary {
                            // add all known user info to the user's dict, so that it can be POSTed to Parse API
                            if let firstName = user["first_name"] as? String {
                                dict["firstName"] = firstName
                            } else {
                                dict["firstName"] = ""
                            }
                            if let lastName = user["last_name"] as? String {
                                dict["lastName"] = lastName
                            } else {
                                dict["lastName"] = ""
                            }
                            completionHandler(result: dict, error: nil)
                        } else {
                            let errString = "The \"user\" dictionary is missing from this Udacity profile"
                            let nsErr = NSError(domain: "Udacity parsing error", code: 1, userInfo: [NSLocalizedDescriptionKey: errString])
                            completionHandler(result: dict, error: nsErr)
                        }
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    // add a new user to Parse API
    func postToParseTask(dict: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: OnTheMapClient.Constants.BaseParseRequest)!)
        var jsonError: NSError?
        request.HTTPMethod = "POST"
        request.addValue(OnTheMapClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OnTheMapClient.Constants.ParseRESTkey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(dict, options: nil, error: &jsonError)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: error.localizedDescription)
            } else {
                var parseError: NSError?
                // parse the results
                let results = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError) as! NSDictionary
                // use presence of "createdAt" key as a test of success
                if let update = results["createdAt"] as? String {
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: false, errorString: "Could not place your mind on the map.")
                }
            }
        }
        task.resume()
        return task
    }
    
    class func logOut(completionHandler: (success: Bool, errorString: String?) -> Void) {
        // end the Udacity session using a DELETE request along with the cached session cookie
        let request = NSMutableURLRequest(URL: NSURL(string: OnTheMapClient.Constants.UdacityBaseSecureUrl + OnTheMapClient.Methods.UdacitySession)!)
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
            if error != nil {
                completionHandler(success: false, errorString: error.localizedDescription)
            } else {
                var parseError: NSError?
                /* trim extra udacity chars */
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parseError) as! NSDictionary
                // use the presence of the "session" key in the parsed results as a test of success
                if let _ = parsedResult["session"] as? [String: AnyObject] {
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: false, errorString: "Could not log out from Udacity.")
                }
            }
        }
        task.resume()
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a URL.
       Copied and pasted from Jarrod Parkes' Movie Manager app on Udacity */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }

}