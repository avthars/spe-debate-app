//
//  DebatesViewController.swift
//  NavTransition
//
//  Created by Jonathan Yu on 7/1/15.
//  Copyright (c) 2015 App Design Vault. All rights reserved.
//

import UIKit
import CoreData



class DebatesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //array of Rounds
    var debateRounds = [NSManagedObject]()
    
    @IBOutlet var tableView: UITableView!
    
    var transitionOperator = TransitionOperator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.backgroundColor = gray
        self.tableView.separatorColor = UIColor.whiteColor()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        //fetch Rounds from Core Data and populate table view
        fetchRounds()
    }

    
    @IBAction func cancelToDebatesViewController(segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveDebateDetail(segue: UIStoryboardSegue) {
        
        if let debateDetailsViewController = segue.sourceViewController as? DebateDetailsTableViewController {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchRounds()
        return debateRounds.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("round", forIndexPath: indexPath) as! UITableViewCell
        
        //selected round
        var selectedRound = debateRounds[indexPath.row]
        
        //text label as name of round
        cell.textLabel?.text = selectedRound.valueForKey("name") as? String
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.backgroundColor = gray
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //Deletes file from core data
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            //Get app delegate instance
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            //set up managed context
            let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
            
            //fetch all RecordedAudio items
            let fetchRequest = NSFetchRequest(entityName: "Round")
            var myList = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject]
            
            //set passed array to fetch results
            debateRounds = myList!
            
            //define file selected
            var selectedFile = debateRounds[indexPath.row]
            
            // Delete selected obejct
            managedContext.deleteObject(selectedFile)
            
            debateRounds.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            //4 error
            var error : NSError?
            if !managedContext.save(&error) {
                println("ERROR 1 : Could not save \(error), \(error?.userInfo)")
            }
            
            //Note: deletes file, but playback still continues --> make sure when passed to next screen that if you delete something it terminates playback
            
            println("File deleted")
            
            
            self.tableView.reloadData()
        }
    }
    
    //----Fetch from Core Data----
    
    //fetches recordings from core data and sets them as contents of passedArray
    func fetchRounds(){
        
        //1 get app delegate instance
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        //2 fecth data
        let fetchRequest = NSFetchRequest(entityName:"Round") // get all entities with this name
        
        //3
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject] // return as an [NSManagedObject]
        
        if let results = fetchedResults {
            
            //set recordings to be RecordedAudio objects fetched form CoreData
            debateRounds = results
        }
            
        else {
            
            println("FETCH ERROR 2: Could not fetch \(error), \(error!.userInfo)")
            
        }
        
    } //end fetch func
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "presentNav") {
            
            let toViewController = segue.destinationViewController as! UIViewController
            self.modalPresentationStyle = .Custom
            toViewController.transitioningDelegate = self.transitionOperator
        }
    }
    
    @IBAction func presentNavigation(sender: AnyObject) {
        performSegueWithIdentifier("presentNav", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
