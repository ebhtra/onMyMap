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

        let pinIcon = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        let reloadIcon = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "handleRefresh")
        navigationItem.setRightBarButtonItems([reloadIcon, pinIcon], animated: true)
        println("yo")
    }

    func handleRefresh() {
        let thisVC = selectedViewController!
        if thisVC.isKindOfClass(MapTabViewController) {
            OnTheMapClient.sharedInstance.loadTheMap(thisVC as! MapTabViewController)
        }
        else if thisVC.isKindOfClass(ListTabViewController) {
            OnTheMapClient.sharedInstance.loadTheList(thisVC as! ListTabViewController)
        }
    }
    
}
