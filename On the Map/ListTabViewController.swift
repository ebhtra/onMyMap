//
//  ListTabViewController.swift
//  On the Map
//
//  Created by Ethan Haley on 8/21/15.
//  Copyright (c) 2015 Ethan Haley. All rights reserved.
//

import UIKit

class ListTabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    var students: [StudentLocation]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        students = StudentsList.roster
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        table.reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentsList.roster.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell", forIndexPath: indexPath) as! StudentTableViewCell
        let studentStruct = students[indexPath.row]
        
        cell.studentName.text = (studentStruct.firstName == nil ? "" : studentStruct.firstName!) + " "
            + (studentStruct.lastName == nil ? "" : studentStruct.lastName!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        UIApplication.sharedApplication().openURL(NSURL(string: students[indexPath.row].mediaURL)!)
    }

   
}
