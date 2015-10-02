//
//  ListTabViewController.swift
//  On the Map
//
//  Created by Ethan Haley on 8/21/15.
//  Copyright (c) 2015 Ethan Haley. All rights reserved.
//

import UIKit

class ListTabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table = UITableView()
    
    override func viewWillAppear(animated: Bool) {
        println("viewWillAppear in list tab vc")
        super.viewWillAppear(animated)
        table!.reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentsList.roster.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell", forIndexPath: indexPath) as! StudentTableViewCell
        let studentStruct = StudentsList.roster[indexPath.row]
        cell.studentName.text = (studentStruct.firstName == nil ? "" : studentStruct.firstName!) + " "
            + (studentStruct.lastName == nil ? "" : studentStruct.lastName!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        UIApplication.sharedApplication().openURL(NSURL(string: StudentsList.roster[indexPath.row].mediaURL)!)
    }

   
}
