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
    
    
    //var appDelegate: AppDelegate!
    //var session: NSURLSession!
    
    var tapRecognizer: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the tap recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap")
        
        // Get the app delegate
        //appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Get the shared URL session
        //session = NSURLSession.sharedSession()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.addGestureRecognizer(tapRecognizer!)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.removeGestureRecognizer(tapRecognizer!)
    }
    // Since this VC isn't in the same UINavigation stack as the rest of the app
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        OnTheMapClient.logOut()
        let facebook = FBSDKLoginManager()
        facebook.logOut()
    }
    
    @IBAction func signupButtonTap(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: OnTheMapClient.UdacitySignupURL)!)
    }
    // Login button for Udacity:
    @IBAction func loginButtonTap(sender: UIButton) {
        if emailField.text.isEmpty || passwordField.text.isEmpty {
            showErrorAlert("Oops--", message: "You need to enter your Udacity email and password to launch \"On the Map.\"\nOr you can login with Facebook below.")
        } else {
            view.endEditing(true)
            // empty the password field after storing the user input
            let pw = passwordField.text
            passwordField.text = ""
            let jsonDict = ["udacity": ["username": emailField.text, "password": pw]]
            udacityAuthenticate(jsonDict)
        }
    }
    // Login button for Facebook:
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if let error = error {
            showErrorAlert("Unable to authenticate with Facebook:", message: error.localizedDescription)
        }
        else {
            if let fbToken = FBSDKAccessToken.currentAccessToken()?.tokenString {
                let jsonDict = ["facebook_mobile": ["access_token": fbToken]]
                udacityAuthenticate(jsonDict)
            }
        }
    }
    
    func udacityAuthenticate(dict: [String: AnyObject]) {
        OnTheMapClient.sharedInstance.loginThruUdacity(self, dict: dict) { success, errorString in
            if success {
                self.completeLogin()
            } else {
                if let errorString = errorString {
                    self.showErrorAlert("Problems logging in:", message: errorString)
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        //empty method call to conform to FB protocol
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue()) {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("RootNavController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    // Remove the keyboard by hitting RETURN key (method called by delegate: self)
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    // Remove the keyboard by tapping on the view (method called by tapRecognizer)
    func handleTap() {
        view.endEditing(true)
    }
    // Generic alert display for login errors
    func showErrorAlert(title: String, message: String) { //dispatch this?
        let alert = UIAlertController()
        alert.title = title
        alert.message = message
        
        // Dismiss the alert VC after the user taps “ok”
        // This uses some of Gabrielle's code from UIKit Fundamentals
        let okAction = UIAlertAction(title:"OK", style: UIAlertActionStyle.Default) { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(okAction)
        // Add popover code for larger devices:
        alert.modalPresentationStyle = UIModalPresentationStyle.Popover
        // Segue for all devices
        self.presentViewController(alert, animated: true, completion:nil)
        // And back to the popover code:
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(loginButton.center.x, loginButton.center.y, CGFloat(0), CGFloat(0))
    }
}
