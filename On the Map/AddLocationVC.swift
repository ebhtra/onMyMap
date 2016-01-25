//
//  AddLocationVC.swift
//  On the Map
//
//  Created by Ethan Haley on 9/10/15.
//  Copyright (c) 2015 Ethan Haley. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

/* Use this delegate method to update the student list later */
protocol StudentAgentDelegate {
    func moveStudentToFront()
}

class AddLocationVC: UIViewController, UITextFieldDelegate {
    
    var studentInfoDict: [String: AnyObject]!  // all known info about user
    var locFound = false  // has the user entered a valid location?
    var didEnterLoc = false // has the user tapped on the location entry field yet?
    var didEnterUrl = false // has the user tapped on the URL entry field yet?
    
    var delegate: StudentAgentDelegate?  // the TabController that directed the app here
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var entryField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    // returns the user to the Map Tab Controller without updating Parse
    @IBAction func cancel(sender: UIButton) {
        navigationController!.popViewControllerAnimated(true)
    }
    // used only to end editing of text fields
    var tapRecognizer: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        navigationController?.navigationBarHidden = true
        // store the current user's known info
        studentInfoDict = StudentsList.studentInfoDict
        
        // configure activity indicator
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        indicator.color = UIColor.blueColor()
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap")
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.addGestureRecognizer(tapRecognizer!)
        
        // display Greenland by default
        mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(CLLocationDegrees(78.0),
            CLLocationDegrees(-41.0)), MKCoordinateSpanMake(CLLocationDegrees(18.0), CLLocationDegrees(18.0)))
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.removeGestureRecognizer(tapRecognizer!)
        navigationController?.navigationBarHidden = false
    }
    
    @IBAction func submitButton(sender: UIButton) {
        // Step 1: Get a valid map location from the user
        if !locFound {
            findLocation()
        } else {
            // Step 2: Get a valid URL from the user
            findLinkAndCreateEntry()
        }
    }
    
    func findLocation() {
        // Step 1: Get a valid map location from the user
        if entryField.text == "" || !didEnterLoc {
            showErrorAlert("You need to type in a location above.", message: "")
        } else {
            indicator.startAnimating()
            indicator.hidden = false
            mapView.alpha = CGFloat(0.4)
            
            let userInput = entryField.text
            CLGeocoder().geocodeAddressString(userInput!) { placemarkArray, nsError in
                if nsError != nil {
                    // There was a problem finding the user input location
                    self.indicator.hidden = true
                    self.mapView.alpha = CGFloat(1.0)
                    // Try to parse out some error info for the user
                    if nsError!.domain == "kCLErrorDomain" {
                        var errorMsg = ""
                        switch nsError!.code {
                        case 2: errorMsg = "The network connection failed"
                        case 8: errorMsg = "It returned no search results"
                        default: errorMsg = "Please try another spot"
                        }
                        self.showErrorAlert("Unable to find that location.", message: errorMsg)
                    } else {
                        self.showErrorAlert("Unable to locate that spot.", message: nsError!.localizedDescription)
                    }
                    
                } else {
                    // User input matched at least one map location. Use first one returned.
                    let place = placemarkArray![0]
                    let coordinate = place.location!.coordinate
        
                    // Add known info to user's student dict
                    self.studentInfoDict["latitude"] = coordinate.latitude
                    self.studentInfoDict["longitude"] = coordinate.longitude
                    self.studentInfoDict["mapString"] = userInput
                    
                    // Zoom in the map to a pin with user's location
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    self.mapView.region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(CLLocationDegrees(0.03), CLLocationDegrees(0.03)))
                    self.mapView.addAnnotation(annotation)
                    
                    // mark Step 1 as complete and hide activity indicator
                    self.locFound = true
                    self.indicator.stopAnimating()
                    self.mapView.alpha = CGFloat(1.0)
                    self.indicator.hidden = true
                    
                    // Update UI elements to prepare for Step 2
                    self.submitButton.setTitle("Submit link", forState: UIControlState.Normal)
                    self.entryField.text = "Tap here to enter where on the Internet"
                    self.entryField.placeholder = "Enter a webpage starting with \"http(s)://\""
                }
            }
        }
    }
    
    func findLinkAndCreateEntry() {
        // Step 2: Get a valid URL from the user
        if entryField.text == "" || !didEnterUrl {
            showErrorAlert("You need to type in a webpage address above.", message: "")
        } else {
            // Attempt to build a NSURL with the user's input
            let userInput = entryField.text
            if let nsurl = NSURL(string: userInput!) {
                // If the app can open the NSURL, add it to the known user info
                if UIApplication.sharedApplication().canOpenURL(nsurl) {
                    studentInfoDict["mediaURL"] = userInput
                    // Use presence of first name as a test of whether to POST or PUT to Parse
                    if studentInfoDict["firstName"] != nil {   // call PUT task
                        OnTheMapClient.sharedInstance.updateUserTask(studentInfoDict) { result, error in
                            if error != nil {
                                self.showErrorAlert("Unable to update your location and link", message: error!.localizedDescription)
                            } else {
                                // Use updatedAt as a test of successful PUT to Parse
                                if let _ = result["updatedAt"] as? String {
                                    // Call the delegate method in the Tab Controller, which will pop this screen
                                    self.delegate!.moveStudentToFront()
                                }
                            }
                        }
                    } else {
                        // call Udacity task to get user's name, then call POST task, since user is new to Parse API
                        OnTheMapClient.sharedInstance.getUserNameAndPostToParse(studentInfoDict) { success, error in
                            if success {
                                // call the delegate method in the Tab Controller, which will pop this screen
                                self.delegate?.moveStudentToFront()
                            } else {
                                self.showErrorAlert("Unable to add your mind to the map--", message: error!)
                            }
                        }
                    }
                } else {
                    showErrorAlert("Unable to open that URL", message: "Please try typing a different URL")
                }
            } else {
                showErrorAlert("Not a valid URL", message: "Please try again")
            }
        }
    }
       
    // Remove the keyboard by tapping on the view (method called by tapRecognizer)
    func handleTap() {
        view.endEditing(true)
    }
    // Clear text entry field when user taps it (called by delegate: self)
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "Tap here 🌐  to enter where on Earth" {
            // mark that the user has found the textfield for location entry
            didEnterLoc = true
        }
        if textField.text == "Tap here to enter where on the Internet" {
            // mark that the user has found the textfield for URL entry
            didEnterUrl = true
        }
        textField.text = ""
    }
    // Stop editing text field when user hits return key (called by delegate: self)
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // (call findLocation() if return key should trigger 'Submit' button)
        return true
    }
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController()
        alert.title = title
        alert.message = message
        
        // Dismiss the alert VC after the user taps “OK” and return editing to text entry field
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { action in
            self.entryField.becomeFirstResponder()
        }
        alert.addAction(okAction)
        // Add popover code for larger devices:
        alert.modalPresentationStyle = UIModalPresentationStyle.Popover
        // Segue for all devices
        self.presentViewController(alert, animated: true, completion:nil)
        // And back to the popover code:
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(submitButton.center.x, submitButton.center.y, CGFloat(0), CGFloat(0))
    }

    
}