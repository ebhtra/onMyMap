//
//  MapTabViewController.swift
//  On the Map
//
//  Created by Ethan Haley on 8/21/15.
//  Copyright (c) 2015 Ethan Haley. All rights reserved.
//

import UIKit
import MapKit

class MapTabViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // store a batch of students from the Parse API and load them into map
        OnTheMapClient.sharedInstance.refreshRoster() { success in
            if success {
                self.loadPins()
            }
        }
    }
    
    func loadPins() {
        // begin by removing old pins
        let pinList = mapView.annotations
        mapView.removeAnnotations(pinList)
        annotations = []
        
        // rebuild the array of pins from scratch
        for student in StudentsList.roster {
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            // Build a CL coordinate
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Create the annotation and set its coordinate,
            //      title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            // Make it work for Madonna or Gandhi
            annotation.title = (student.firstName == nil ? "" : student.firstName!) + " " + (student.lastName == nil ? "" : student.lastName!)
            annotation.subtitle = student.mediaURL
            
            // Add to the array of annotations
            annotations.append(annotation)
        }
        // When the array is complete,  add the annotations to the map.
        mapView.addAnnotations(annotations)
    }
    
    // MARK: - MKMapViewDelegate
    
    // Tack on a right callout accessory view for each annotation.
    //      This is taken right from the Udacity "Pin Sample" app:
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // delegate method called upon user tapping accessory view,
    //    opening the provided webpage outside of the app
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            UIApplication.sharedApplication().openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
}
