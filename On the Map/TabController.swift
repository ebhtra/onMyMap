//
//  TabController.swift
//  On the Map
//
//  Created by Ethan Haley on 8/27/15.
//  Copyright (c) 2015 Ethan Haley. All rights reserved.
//

import UIKit

class TabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let pinIcon = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "handlePinTap")
        let reloadIcon = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addStudents")
        navigationItem.setRightBarButtonItems([reloadIcon, pinIcon], animated: true)
    }
    
    // Add another batch of students from Parse to the map when user hits 'add' button
    func addStudents() {
       
        OnTheMapClient.sharedInstance.refreshRoster() { success in
            if success {
                for vc in self.viewControllers! {
                    if vc.isKindOfClass(MapTabViewController) {
                        dispatch_async(dispatch_get_main_queue()){
                            (vc as! MapTabViewController).loadPins()
                        }
                    }
                    if vc.isKindOfClass(ListTabViewController) {
                        dispatch_async(dispatch_get_main_queue()) {
                            (vc as! ListTabViewController).table?.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func handlePinTap() {
        let locationEditor = storyboard!.instantiateViewControllerWithIdentifier("AddLocationVC") as! AddLocationVC
        navigationController?.pushViewController(locationEditor, animated: true)
    }
}
