//
//  AnalyticsViewController.swift
//  NavTransition
//
//  Created by Jonathan Yu on 7/13/15.
//  Copyright (c) 2015 App Design Vault. All rights reserved.
//

import UIKit

// sample data
var data: [[Int]] = [[4, 2, 6, 4, 5, 8, 3, 10], [7, 5, 8, 3, 4, 6, 2, 5], [0, 1, 2, 2, 0, 1, 0, 2], [9, 10, 9, 10, 9, 10, 10, 9]]
var displayData = [true, true, true, true, true]

// graph view options
let options = ["Constructive Speech", "Speech 2", "Speech 3", "Speech 4", "Speech 5"]

class AnalyticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var optionsTableView: UITableView!
    @IBOutlet var graphView: GraphView!
    
    var transitionOperator = TransitionOperator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = gray
        self.graphView.backgroundColor = UIColor.clearColor()
        
        // configure Options table view
        self.optionsTableView.backgroundColor = UIColor.clearColor()
        self.optionsTableView.separatorColor = UIColor.grayColor()
        self.optionsTableView.scrollEnabled = false
        
        self.optionsTableView.dataSource = self
        self.optionsTableView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        self.graphView.setNeedsDisplay()
        self.optionsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = optionsTableView.dequeueReusableCellWithIdentifier("graphOption", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = options[indexPath.row] as String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        cell.accessoryType = (displayData[indexPath.row]) ? .None : .Checkmark
        
        displayData[indexPath.row] = !displayData[indexPath.row]
        
        self.graphView.setNeedsDisplay()
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let toViewController = segue.destinationViewController as! UIViewController
        self.modalPresentationStyle = .Custom
        toViewController.transitioningDelegate = self.transitionOperator
    }
    
    // Presents the Navigation View when user presses the menu button
    @IBAction func presentNavigation(sender: AnyObject?) {
        performSegueWithIdentifier("presentNav", sender: self)
    }
    
}
