//
//  LoginViewController.swift
//  On the Map
//
//  Created by Ethan Haley on 8/4/15.
//  Copyright (c) 2015 Ethan Haley. All rights reserved.
//
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!

    
    @IBAction func loginButtonTap(sender: UIButton) {
        if emailField.text.isEmpty || passwordField.text.isEmpty {
            showErrorAlert("Oops--", message: "You need to enter your Udacity email and password to launch \"On the Map\"")
        } else {
            view.endEditing(true)
            attemptLoginThroughUdacity()
        }
    }
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if let error = error {
            println("error = \(error)")
        }
        if let result = result {
            
            println(FBSDKAccessToken.currentAccessToken().tokenString)
            
            //loginThruUdacityWithFBToken(FBSDKAccessToken.currentAccessToken().tokenString)
        }
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("logging out")
    }
   
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    var tapRecognizer: UITapGestureRecognizer?
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the tap recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap")
        
        // Get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Get the shared URL session
        session = NSURLSession.sharedSession()
    
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.addGestureRecognizer(tapRecognizer!)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.removeGestureRecognizer(tapRecognizer!)
    }
    // Remove the keyboard by hitting RETURN key (method called by delegate: self)
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        //return true
        view.endEditing(true)
        return true
    }
    // Remove the keyboard by tapping on the view (method called by tapRecognizer)
    func handleTap() {
        view.endEditing(true)
    }
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController()
        alert.title = title
        alert.message = message
        
        // Dismiss the view controller after the user taps “ok”
        // This uses Gabrielle's code from UIKit Fundamentals
        let okAction = UIAlertAction (title:"OK", style: UIAlertActionStyle.Default) { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion:nil)
    }
    
    func attemptLoginThroughUdacity() {
        var urlString = OnTheMapClient.BaseSecureUrl + "session"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonError: NSError?
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(["udacity": ["username": emailField.text, "password": passwordField.text]], options: nil, error: &jsonError)
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                self.showErrorAlert("Sorry--", message: "There was a problem with the login (task failed).")
            } else {
                var parsingError: NSError?
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                
                let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
                
                if let error = parsingError {
                    println("problems parsing the JSON")
                } else {
                    if let err = parsedResult?.valueForKey("error") as? String {
                        self.showErrorAlert("Login error--", message: err)
                    } else {
                        // Login to student map locations using parse api
                    }
                }
            }
        }
        task.resume()
    }
}
