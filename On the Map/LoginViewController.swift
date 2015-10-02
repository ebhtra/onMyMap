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
    
    // Udacity login control elements
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    // Facebook login control element
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    
    // Will be used only to end editing
    var tapRecognizer: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Log out of any previously Facebook-authenticated session
        // --May wish to instead complete login since already authorized
        if FBSDKAccessToken.currentAccessToken() != nil {
            FBSDKLoginManager().logOut()
        }
        
        // Set up the tap recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap")
        
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
        
        OnTheMapClient.logOut() { success, errorString in
            if success {
                self.showErrorAlert("Successfully logged out from Udacity", message: "")
            } else {
                self.showErrorAlert("Sorry--", message: "Unable to log out from Udacity")
            }
        }
        // if logged in through FB, log out using FB's LoginManager method
        if FBSDKAccessToken.currentAccessToken() != nil {
            FBSDKLoginManager().logOut()
        }
    }
    // Reroute the user to Udacity to sign up
    @IBAction func signupButtonTap(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: OnTheMapClient.Constants.UdacitySignupURL)!)
    }
    
    // Login button for Udacity:
    @IBAction func loginButtonTap(sender: UIButton) {
        if emailField.text.isEmpty || passwordField.text.isEmpty {
            showErrorAlert("Oops--", message: "You need to enter your Udacity email and password to launch \"On the Map.\"\nOr you can login with Facebook.")
        } else {
            view.endEditing(true)
            // empty the password field after storing the user input
            let pw = passwordField.text
            passwordField.text = ""
            // use the username and pw for Udacity authentication
            let jsonDict = ["udacity": ["username": emailField.text, "password": pw]]
            udacityAuthenticate(jsonDict)
        }
    }
    // Login button for Facebook:
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if let error = error {
            showErrorAlert("Unable to authenticate with Facebook:", message: error.localizedDescription)
        }
        else {  // use the FB token string for Udacity authentication
            if let fbToken = FBSDKAccessToken.currentAccessToken()?.tokenString {
                let jsonDict = ["facebook_mobile": ["access_token": fbToken]]
                udacityAuthenticate(jsonDict)
            }
        }
    }
    
    // Authenticate. If authentication fails, display the error returned by the completion handler
    func udacityAuthenticate(dict: [String: AnyObject]) {
        OnTheMapClient.sharedInstance.loginThruUdacity(dict) { success, errorString in
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
        //empty method call to conform to FBSDKLoginButtonDelegate protocol
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
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController()
        alert.title = title
        alert.message = message
        
        // Dismiss the alert VC after the user taps “OK”
        let okAction = UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil)
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
