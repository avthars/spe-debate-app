//
//  DebateDetailsViewControllerTableViewController.swift
//  NavTransition
//
//  Created by Jonathan Yu on 7/15/15.
//  Copyright (c) 2015 App Design Vault. All rights reserved.
//

import UIKit
import CoreData

class DebateDetailsTableViewController: UITableViewController {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var partnerTextField: UITextField!
    @IBOutlet var motionTextField: UITextField!
    @IBOutlet var scoreUserTextField: UITextField!
    @IBOutlet var scorePartnerTextField: UITextField!
    @IBOutlet var commentsTextField: UITextField!
    
    @IBOutlet var formatSegmentedControl: UISegmentedControl!
    @IBOutlet var resultSegmentedControl: UISegmentedControl!
    
    var format: Bool = true
    var result: Bool = true
    
    var debateRound: DebateRound!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            nameTextField.becomeFirstResponder()
        }
        
        // do same for other cells
    }
    
    @IBAction func didChangeFormat(sender: UISegmentedControl) {
        
        self.format = (formatSegmentedControl.selectedSegmentIndex == 0) ? true: false
    }
    
    @IBAction func didChangeResult(sender: UISegmentedControl) {
        
        self.format = (resultSegmentedControl.selectedSegmentIndex == 0) ? true: false
    }
    
    
    // MARK: - Save in Core Data
    
    func saveRound(name: String, partner: String, motion: String, roundFormat: Bool, scoreUser: Double, scorePartner: Double, roundResult: Bool) {
        
        //instance of managed object context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        //create entity Round
        let entity =  NSEntityDescription.entityForName("Round", inManagedObjectContext : managedContext)
        
        //instance of entity
        let round = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        //set values
        round.setValue(name, forKey: "name")
        round.setValue(partner, forKey: "partner")
        round.setValue(motion, forKey: "motion")
        round.setValue(roundFormat, forKey: "format")
        round.setValue(scoreUser, forKey: "scoreUser")
        round.setValue(scorePartner, forKey: "scorePartner")
        round.setValue(roundResult, forKey: "result")
        
        // error
        var error : NSError?
        if !managedContext.save(&error) {
            println("ERROR 1 : Could not save \(error), \(error?.userInfo)")
        } else {
            println("***FORM INFO SAVE TO CORE DATA SUCCESSFULLY***")
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "SaveDebateDetail") {
            
            //makes new round
            var newRound = DebateRound(name: self.nameTextField.text, partner: self.partnerTextField.text, motion: self.motionTextField.text, format: self.format, scoreUser: (self.scoreUserTextField.text as NSString).doubleValue, scorePartner: (self.scorePartnerTextField.text as NSString).doubleValue, result: self.result)
            
            
            //saves stuff to core data
            
            println("Saving to core data")
            
            saveRound(self.nameTextField.text, partner: self.partnerTextField.text, motion: self.motionTextField.text, roundFormat: self.format, scoreUser: (self.scoreUserTextField.text as NSString).doubleValue, scorePartner: (self.scorePartnerTextField.text as NSString).doubleValue, roundResult: self.result)
            
            self.debateRound = newRound
        }
    }
}
