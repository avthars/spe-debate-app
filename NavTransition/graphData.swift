//
//  graphData.swift
//  NavTransition
//
//  Created by Avthar Sewrathan on 7/17/15.
//  Copyright (c) 2015 App Design Vault. All rights reserved.
//

import UIKit
import CoreData

class graphData {
    
    //----API to save user inputs to coreData--------
    //1. saveRound(format : String, name: String, partner : String, motion : String)
    //2. saveResult(scoreUser : Double, scorePartner : Double, roundResult : Int)
    //3. saveTags(tag1 : String, tag2: String, tag3: String)
    
    
    //-------FUNCTIONS TO SAVE INPUTTED DATA TO CORE DATA---------
    
    
        
    
    //save Round essentials(format, name, partner, motion)
    func saveRound(format : String, name: String, partner : String, motion : String, scoreUser: Double, scorePartner : Double, roundResult : Int, tag1 : String, tag2: String, tag3 : String) {
        
        //1 Call app delegate instance + managedObject context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        //2 Get entity = Round
        let entity =  NSEntityDescription.entityForName("Round", inManagedObjectContext : managedContext)
        
        //instance of entity
        let round = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        //3 Set all values for essentials
        round.setValue(format, forKey: "format")
        round.setValue(name, forKey: "name")
        round.setValue(partner, forKey: "partner")
        round.setValue(motion, forKey: "motion")
        
        //Set results
        round.setValue(scoreUser, forKey: "scoreUser")
        round.setValue(scorePartner, forKey: "scorePartner")
        round.setValue(roundResult, forKey: "result")
        
        
        //Set all values for tags
        round.setValue(tag1, forKey: "tag1")
        round.setValue(tag2, forKey: "tag2")
        round.setValue(tag3, forKey: "tag3")
        
        //4 error
        var error : NSError?
        if !managedContext.save(&error) {
            println("ERROR 1 : Could not save \(error), \(error?.userInfo)")
        }
    }//end save round
    
    
    //-----------FUNCTIONS TO GET ATTRITBUTES FROM CORE DATA----------
    
    //function to fetch all Core data objects of X entity type and returns them as an array
    func fetchAllEntity(entityName: String) -> [NSManagedObject] {
        var fetchedArray : [NSManagedObject]!
        
        //1 get app delegate instance
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        //2 fecth data
        let fetchRequest = NSFetchRequest(entityName: entityName) // get all entities with this name
        
        //3
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject] // return as an [NSManagedObject]
        
        if let results = fetchedResults {
            
            //set array to be results[] fetched form CoreData
            fetchedArray = results
        }
            
        else {

            println("FETCH ERROR 2: Could not fetch \(error), \(error!.userInfo)")
        }
        
        return fetchedArray
    } // end func
    
    //return mean value of all scores from all rounds
    func overallMeanScore() -> Double {
        
        //get all rounds and set them as fetchedArray
        let fetchedArray = fetchAllEntity("Round")
        
        //tracking variables
        var totalScore: Double = 0.0
        var totalRounds: Double = 0
        
        
        //loop through all rounds
        for round in fetchedArray {
            //IF STATEMENT TO CHECK IF ROUND HAS VALUE FOR KEY "scoreUser", then apply increments
            if let scoreForRound = round.valueForKey("scoreUser") as? Double{
                
                //increment
                totalScore += scoreForRound
                totalRounds++
                
            }//end if let
            
        }//end for each
        
        //If no rounds present
        if (totalRounds == 0) {println("ERROR: No Rounds done")
            
            return 0
        }
        
        let overallMeanScore = (totalScore / totalRounds)
        
        
        return overallMeanScore
        
    }
    
    //get all rounds with a chosen partner
    func getRoundsWithPartner(partnerName: String) -> [NSManagedObject] {
        
        //fetch all rounds
        let fetchedArray = fetchAllEntity("Round")
        //array to store rounds with partner
        var roundsWithPartner : [NSManagedObject] = []
        
        //search through all rounds
        for round in fetchedArray{
            
            let partnerInRound = round.valueForKey("partner") as! String
            
            //if match
            if partnerInRound == partnerName {
                
                //add to match array
                roundsWithPartner.append(round)
                
            } // end if
            
        } // end for each
        
        return roundsWithPartner
    }
    
    func meanScoreWithPartner(partnerName : String) -> Double {
        
        //get all rounds with specified partner
        let roundsWithPartner = getRoundsWithPartner(partnerName)
        
        //tracking variables
        var totalScoreWithPartner : Double = 0
        var totalRoundsWithPartner : Double = 0
        
        //fiter rounds
        //search through all rounds
        for round in roundsWithPartner {
            
            if let scoreUser = round.valueForKey("scoreUser") as? Double {
                
                //increment counters
                totalScoreWithPartner += scoreUser
                totalRoundsWithPartner++
            }//end if let
            
        } // end for each
        
        
        //If no rounds exist --> return 0
        if (totalRoundsWithPartner == 0) {println("ERROR: No Rounds with partner")
            
            return 0
        }
        
        return totalScoreWithPartner / totalRoundsWithPartner
    }
    
    
    
    
    //average score for specific tournament
    func meanUserScoreForTournament(tournamentName : String) -> Double{
        
        //get all rounds
        let fetchedArray = fetchAllEntity("Round")
        //tracking vars
        var roundsAtTournament : Double = 0
        var totalScoreAtTournament : Double = 0
        
        //fiter rounds
        //search through all rounds
        for round in fetchedArray{
            
            var fetchedTournamentName = round.valueForKey("tournament") as! String
            
            //if tournament name matches
            if fetchedTournamentName == tournamentName {
                
                //if let defense programming if scoreUser has no value
                if let scoreUser = round.valueForKey("scoreUser") as? Double {
                    
                    //increment tracking vars
                    totalScoreAtTournament += scoreUser
                    roundsAtTournament++
                    
                }
                
                
            }//end tournament check
            
        } // end for each
        
        
        if (roundsAtTournament == 0) {println("ERROR: No Rounds in tournament")
            
            return 0
        }
        
        return (totalScoreAtTournament / roundsAtTournament)
        
    }//end meanScoreForTournament
    
    
    //fetching rounds with specific tag
    func getRoundsWithTag(tagName : String) -> [NSManagedObject] {
        
        //array with rounds of desired tag
        var taggedArray : [NSManagedObject] = []
        
        //get all rounds
        let fetchedArray = fetchAllEntity("Round")
        
        for round in fetchedArray{
            
            //tags for round
            let roundTag1 = round.valueForKey("tag1") as? String
            let roundTag2 = round.valueForKey("tag2") as? String
            let roundTag3 = round.valueForKey("tag3") as? String
            
            //if tag is a match
            if (roundTag1 == tagName) || (roundTag2 == tagName) || (roundTag3 == tagName) {
                
                //add round to tag array
                taggedArray.append(round)
                
            }//end if
            
        }//end for each
        
        
        return taggedArray
    }
    
    //mean score form selection of rounds from input array eg) tag
    func meanScoreFromSelection(selection : [NSManagedObject]) -> Double {
        
        //tracking variables
        var selectionScore: Double = 0
        var selectionRounds: Double = 0
        
        
        //loop through all rounds
        for round in selection {
            //IF STATEMENT TO CHECK IF ROUND HAS VALUE FOR KEY "scoreUser", then apply increments
            if let scoreForRound = round.valueForKey("scoreUser") as? Double {
                
                //increment
                selectionScore += scoreForRound
                selectionRounds++
                
            }//end if
            
        }//end for each
        
        if (selectionRounds == 0) {println("ERROR: No Rounds in Selection")
            
            return 0
        }
        
        
        let overallSelectionScore = (selectionScore / selectionRounds)
        
        return overallSelectionScore
    }//end mean from selection
    
    
    
}
