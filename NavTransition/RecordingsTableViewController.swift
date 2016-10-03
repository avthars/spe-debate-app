//
//  RecordingsTableViewController.swift
//  NavTransition
//
//  Created by Avthar Sewrathan on 7/8/15.
//  Copyright (c) 2015 App Design Vault. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class RecordingsTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var transitionOperator = TransitionOperator()
    
    //Array of RecordedAudio objects
    var passedArray : [NSManagedObject] = []
    
    //---For searching----
    var searchActive = false        // search activity
    //search results array
    var filtered = [NSManagedObject]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //---------App behaviour---------
    override func viewWillAppear(animated: Bool) {
        //fetch from core data
        fetchRecordings()
        
//        //search bar placeholder
//        searchBar.placeholder = "e.g. Princeton Round 1"
        
    }
    
    
    //fetches recordings from core data and sets them as contents of passedArray
    func fetchRecordings(){
        
        //1 get app delegate instance
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        //2 fecth data
        let fetchRequest = NSFetchRequest(entityName:"RecordedAudio") // get all entities with this name
        
        //3
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject] // return as an [NSManagedObject]
        
        if let results = fetchedResults {
            
            //set recordings to be RecordedAudio objects fetched form CoreData
            passedArray = results
        }
            
        else {
            
            println("FETCH ERROR 2: Could not fetch \(error), \(error!.userInfo)")
            
        }
        
    } //end fetch func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        //        self.searchBar.delegate = self
        
        self.tableView.backgroundColor = gray
        self.tableView.separatorColor = UIColor.blackColor()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        
        //        // Return the number of rows in the section.
        if (searchActive) {
            return filtered.count
        } else {return passedArray.count}
        
        
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("audiofile", forIndexPath: indexPath) as! UITableViewCell
        
        // Configure the cell...
        
        if (searchActive) {
            
            //get individual file from filtered array
            let audiofile = filtered[indexPath.row]
            
            // set title and subtitle to be name + date
            cell.textLabel!.text = audiofile.valueForKey("displayName") as? String
            
            //get date
            var date =  audiofile.valueForKey("date") as! NSDate
            //format date
            var formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM/yyyy-HH:mm:ss"
            
            //set subtitle date
            cell.detailTextLabel?.text = formatter.stringFromDate(date)
            
            
            
        } else {
            
            //get RecordedAudio object from normal array
            let audiofile = passedArray[indexPath.row]
            
            // set title and subtitle to be name + date
            cell.textLabel!.text = audiofile.valueForKey("displayName") as? String
            
            //get date
            var date =  audiofile.valueForKey("date") as! NSDate
            //format date
            var formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM/yyyy-HH:mm:ss"
            
            //set subtitle date
            cell.detailTextLabel?.text = formatter.stringFromDate(date)
            
        }
        
        return cell
        
    }
    
    //WHEN CELL IS SELECTED: plays audio associated with cell when selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Segue to playerVC
        self.performSegueWithIdentifier("playScreen1", sender: self)
        
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //----DELETES ITEM FROM CORE DATA------
        //if sliding delete was invoked
        if editingStyle == .Delete {
            
            //Get app delegate instance
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            //set up managed context
            let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
            
            //fetch all RecordedAudio items
            let fetchRequest = NSFetchRequest(entityName: "RecordedAudio")
            var myList = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject]
            
            //set passed array to fetch results
            passedArray = myList!
            
            //define file selected
            var selectedFile = passedArray[indexPath.row]
            
            // Delete selected obejct
            managedContext.deleteObject(selectedFile)
            
            passedArray.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            //4 error
            var error : NSError?
            if !managedContext.save(&error) {
                println("ERROR 1 : Could not save \(error), \(error?.userInfo)")
            }
            
            //Note: deletes file, but playback still continues --> make sure when passed to next screen that if you delete something it terminates playback
            
            println("File deleted")
            
            
            
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
        
    }
    
    
    //-----EDITING displayName by swiping------
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        //get instance of cell (so that properties can be edited directly)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        var editRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit", handler:{action, indexpath in
            
            //animates after opening
            self.tableView.setEditing(false, animated: false)
            
            var enteredName: String = ""
            
            var alert = UIAlertController(title: "Edit Name", message: "Please edit recording name below", preferredStyle: UIAlertControllerStyle.Alert)
            
            //Cancel func
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                alert.removeFromParentViewController() //remove alert from controller
                
            }))
            
            // Text field for data entry
            alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
                textField.placeholder = "Name"
            }
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            //Save action
            alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                
                let nameField = alert.textFields![0] as! UITextField
                
                //set name to be text in field
                enteredName = nameField.text
                
                //set name to be displayName in cell
                cell!.textLabel!.text = enteredName
                
                //change display name in core data
                self.changeDisplayNameTo(enteredName, rowNum: indexPath.row)
                
            }))
            
            //Call function to change name with input from text entered in alert
            
            self.tableView.reloadData()
            
            
            
            //println("Edit action completed")
        })
        
        //color of item
        editRowAction.backgroundColor = UIColor.purpleColor()
        
        //delete action
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            
            //animates after opening
            self.tableView.setEditing(false, animated: false)
            
            //call delegate method which handles deletion
            self.tableView(tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
            
            println("Delete Action Completed")
        })
        
        deleteRowAction.backgroundColor = UIColor.redColor()
        
        //Share action --> Need to add
        
        
        
        return [deleteRowAction, editRowAction]
    }
    
    
    
    //------FUNCTION WHICH CHANGES DISPLAY NAME IN CORE DATA OBJECT REPRESENTATION--------
    //rowNum = index of object in arr
    func changeDisplayNameTo(newName : String, rowNum : Int){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //set up managed context
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        //fetch all RecordedAudio items
        let fetchRequest = NSFetchRequest(entityName: "RecordedAudio")
        var myList = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject]
        
        //set passed array to fetch results
        passedArray = myList!
        
        //define file selected
        var selectedFile = passedArray[rowNum]
        
        // edit displayName of selected obejct
        selectedFile.setValue(newName, forKey: "displayName")
        
        //4 error
        var error : NSError?
        if !managedContext.save(&error) {
            println("ERROR 1 : Could not save \(error), \(error?.userInfo)")
        }
        
        self.fetchRecordings()
        
    }//end changeDisplayNameTo func
    
//    //----SEARCH BAR FUNCTIONALITY----
//    //when search bar is tapped/ activated
//    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
//        searchActive = true
//        searchBar.placeholder = ""
//    }
//    
//    //when it stops being active
//    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
//        searchActive = false
//    }
//    
//    //Canceled search
//    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        searchActive = false;
//        searchBar.setShowsCancelButton(false, animated: true)
//        searchBar.text = ""
//        self.tableView.reloadData()
//    }
//    
//    //when search button is clicked
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        searchActive = false
//    }
//    
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        
//        filtered = passedArray.filter({ (text) -> Bool in
//            
//            //modified to access 'displayName' attribute
//            let tmp: NSManagedObject = text
//            let displayTemp =  tmp.valueForKey("displayName") as! String
//            
//            return displayTemp.uppercaseString.hasPrefix(searchText.uppercaseString)
//            
//        })
//        
//        if(filtered.count == 0){
//            searchActive = true;
//        } else {
//            searchActive = true;
//        }
//        self.tableView.reloadData()
//        
//        searchBar.setShowsCancelButton(true, animated: true)
//        
//    }
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    
    // MARK: - Navigation
    
    
    // Presents the Navigation View when user presses the menu button
    @IBAction func presentNavigation(sender: AnyObject?) {
        performSegueWithIdentifier("presentNav", sender: self)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.

        if (segue.identifier == "presentNav") {
            
            let toViewController = segue.destinationViewController as! UIViewController
            self.modalPresentationStyle = .Custom
            toViewController.transitioningDelegate = self.transitionOperator
        }
        
        
        //MODIFY FOR SEGUE FROM SEARCH BAR RESULTS
        
        
        //if segue name is
        if (segue.identifier == "playScreen1"){
            
            //rowNumber = which cell was pressed?
            if let rowNumber = self.tableView.indexPathForSelectedRow()?.row {
                
                //gets destination VC
                let destination = segue.destinationViewController as! PlayerViewController
                
                //set title in PlayerVC
                destination.passedTitle = passedArray[rowNumber].valueForKey("title") as! String
                
                //set displayName in PlayerVC
                destination.passedDisplayName = passedArray[rowNumber].valueForKey("displayName") as! String
                
                println("sent relevant info to playerVC")
                
            }
            //
            //                    //FOR NOW PLAYING BAR
            //                    if segue.identifier == "playScreen3" {
            //
            //
            //                        //rowNumber = which cell was pressed?
            //                        if let rowNumber = self.tableView.indexPathForSelectedRow()?.row {
            //
            //                            //gets destination VC
            //                            let destination = segue.destinationViewController as! NowPlayingBarViewController
            //
            //                            //set title in PlayerVC
            //                            destination.passedTitle = passedArray[rowNumber].valueForKey("title") as! String
            //
            //                            //set displayName in PlayerVC
            //                            destination.passedDisplayName = passedArray[rowNumber].valueForKey("displayName") as! String
            //                            
            //                            println("sent relevant info to playerVC")
            //                
            //                    }
            
            
        }
        
        
    }
    
}
