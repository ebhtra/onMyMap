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

class AddLocationVC: UIViewController, UITextFieldDelegate {
    
    var studentInfoDict: [String: AnyObject]!  // all known info about user
    var locFound = false  // has the user entered a valid location?
    var didEnterLoc = false // has the user tapped on the location entry field yet?
    var didEnterUrl = false // has the user tapped on the URL entry field yet?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var entryField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBAction func cancel(sender: UIButton) {
        navigationController!.popViewControllerAnimated(true)
    }
    var tapRecognizer: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        navigationController?.navigationBarHidden = true
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
        mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(CLLocationDegrees(78.0), CLLocationDegrees(-41.0)), MKCoordinateSpanMake(CLLocationDegrees(18.0), CLLocationDegrees(18.0)))
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.removeGestureRecognizer(tapRecognizer!)
        navigationController?.navigationBarHidden = false
    }
    
    @IBAction func submitButton(sender: UIButton) {
        if !locFound {
            findLocation()
        } else {
            findLinkAndCreateEntry()
        }
    }
    
    func findLocation() {
        
        if entryField.text == "" || !didEnterLoc {
            showErrorAlert("You need to type in a location above.", message: "")
        } else {
            indicator.startAnimating()
            indicator.hidden = false
            mapView.alpha = CGFloat(0.4)
            
            let userInput = entryField.text
            CLGeocoder().geocodeAddressString(userInput) { placemarkArray, nsError in
                if nsError != nil {
                    self.indicator.hidden = true
                    self.mapView.alpha = CGFloat(1.0)
                    self.showErrorAlert("Unable to locate that spot", message: nsError.localizedDescription)  // 'kCLErrorDomain error 2.' when i kill internet during search
                    //'kCLErrorDomain error 8.'  when i geocode demott avenue on simulator
                } else {
                    let place = placemarkArray[0] as! CLPlacemark
                    let coordinate = place.location.coordinate
        
                    self.studentInfoDict["latitude"] = coordinate.latitude
                    self.studentInfoDict["longitude"] = coordinate.longitude
                    self.studentInfoDict["mapString"] = userInput
                    
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    self.mapView.region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(CLLocationDegrees(0.03), CLLocationDegrees(0.03)))
                    self.mapView.addAnnotation(annotation)
                    self.locFound = true
                    self.indicator.stopAnimating()
                    self.mapView.alpha = CGFloat(1.0)
                    self.indicator.hidden = true
                    self.submitButton.setTitle("Submit link", forState: UIControlState.Normal)
                    self.entryField.text = "Tap here to enter where on the Internet"
                    self.entryField.placeholder = "Enter a webpage starting with \"http(s)://\""
                }
            }
        }
    }
    
    func findLinkAndCreateEntry() {
        if entryField.text == "" || !didEnterUrl {
            showErrorAlert("You need to type in a webpage address above.", message: "")
        } else {
            let userInput = entryField.text
            if let nsurl = NSURL(string: userInput) {
                if UIApplication.sharedApplication().canOpenURL(nsurl) {
                    studentInfoDict["mediaURL"] = userInput
                    if studentInfoDict["firstName"] != nil {
                        OnTheMapClient.sharedInstance.updateUserTask(studentInfoDict) { result, error in
                            if error != nil {
                                self.showErrorAlert("Unable to update your location and link", message: error!.localizedDescription)
                            } else {
                                if let update = result["updatedAt"] as? String {
                                    StudentsList.roster = []
                                    // protocol method here for refreshing roster upon return to tab screen
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.navigationController!.popViewControllerAnimated(true)
                                    }
                                }
                            }
                        }
                    } else {
                        OnTheMapClient.sharedInstance.getUserNameAndPostToParse(studentInfoDict) { success, error in
                            if success {
                                StudentsList.roster = []
                                 // protocol method here for refreshing roster upon return to tab screen
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.navigationController!.popViewControllerAnimated(true)
                                }
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
        if textField.text == "Tap here to enter where on the Internet" {
            didEnterUrl = true
        }
        if textField.text == "Tap here 🌐  to enter where on Earth" {
            didEnterLoc = true
        }
        textField.text = ""
    }
    // Stop editing text field when user hits return key (called by delegate: self)
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // call findLocation() if return key should trigger geocoder
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