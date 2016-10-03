//
//  APDAViewController.swift
//  NavTransition
//
//  Created by Jonathan Yu on 6/25/15.
//  Copyright (c) 2015 Jonathan Yu. All rights reserved.
//

// Resources
// http://www.techotopia.com/index.php/An_iOS_8_Swift_Graphics_Tutorial_using_Core_Graphics_and_Core_Image

import UIKit
import CoreData
import AVFoundation

let gray = UIColor(white: 0.95, alpha: 1.0)
let blueX = UIColor(red: 0.188235, green: 0.513726, blue: 0.984314, alpha: 1.0)
let updateRate = 0.05

class APDAViewController: UIViewController, AVAudioRecorderDelegate  {
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var buttonLabel: UIButton!
    @IBOutlet var timeLimitSelector: UISegmentedControl!
    @IBOutlet var menuItem : UIBarButtonItem!
    @IBOutlet var toolbar : UIToolbar!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var startButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var transitionOperator = TransitionOperator()
    
    var timing: Bool = false
    var timer = NSTimer()
    var progressBarTimer = NSTimer()
    var currentTime = 0.0
    var mod = 0
    var selectedTimeLimit = 2
    var APDA = [7, 8, 4, 5]
    var progress: Float = 0.00
    var circularProgressBar: SWProgressIndicator!
    var circularBackground: SWProgressIndicator!
    //var rectProgressBarBackground: RectProgressBar!
    
    // Allow user to select time limit using segmented control bar
    @IBAction func timeLimitSelected(sender: UISegmentedControl) {
        selectedTimeLimit = APDA[timeLimitSelector.selectedSegmentIndex]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure tool bar
        self.menuItem.image = UIImage(named: "menu")
        self.toolbar.tintColor = UIColor.blackColor()
        
        // Add swipe-from-left-edge functionality
        var swipeRight = UIScreenEdgePanGestureRecognizer(target: self, action: "swiped:")
        swipeRight.edges = UIRectEdge.Left
        self.view.addGestureRecognizer(swipeRight)
        
        self.timeLabel.textColor = UIColor.blackColor()
        
        // Add a long press gesture recognizer that resets the timer
        var longPress = UILongPressGestureRecognizer(target: self, action: "longPressed:")
        longPress.minimumPressDuration = 1.5
        self.buttonLabel.addGestureRecognizer(longPress)
        
        // Configure start button
        self.startButton.backgroundColor = UIColor.whiteColor()
        self.startButton.layer.cornerRadius = 36
        self.startButton.layer.borderWidth = 2.5
        self.startButton.layer.borderColor = UIColor.greenColor().CGColor
        
        // Configure reset button
        self.resetButton.backgroundColor = UIColor.whiteColor()
        self.resetButton.layer.cornerRadius = 36
        self.resetButton.layer.borderWidth = 2.5
        self.resetButton.layer.borderColor = UIColor.blackColor().CGColor
        self.resetButton.alpha = 0.3
        self.resetButton.enabled = false
        
        // Set custom background color
        self.view.backgroundColor = gray
        
        // Display circular background
        self.circularBackground = SWProgressIndicator()
        self.circularBackground.frame = CGRect(x: 37.0, y: 123.0, width: 301.0, height: 301.0)
        self.circularBackground.backgroundColor = UIColor.clearColor()
        self.circularBackground.progress = 1.00
        self.circularBackground.alpha = 0.2
        self.view.addSubview(circularBackground)
        self.view.sendSubviewToBack(circularBackground)
        
        // Display circular progress bar
        self.circularProgressBar = SWProgressIndicator()
        self.circularProgressBar.frame = CGRect(x: 37.0, y: 123.0, width: 301.0, height: 301.0)
        self.circularProgressBar.backgroundColor = UIColor.clearColor()
        self.view.addSubview(circularProgressBar)
        self.view.sendSubviewToBack(circularProgressBar)
        
        // Configure start recording button
        //self.recordButton.backgroundColor = UIColor.whiteColor()
        self.recordButton.layer.borderColor = UIColor.redColor().CGColor
    }
    
    // Update timer display and progress bar
    func updateTimer() {
        
        currentTime += updateRate
        mod += 1
        
        // calculate minutes and seconds in elapsed time
        var elapsedTime = currentTime
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        // format the time with leading zeroes
        let strMinutes = String(format: "%01d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        self.timeLabel.text = "\(strMinutes):\(strSeconds)"
        
        // flash progress bar when time reaches last minute
        if (Int(minutes) == selectedTimeLimit - 1) {
            if (mod % 16 == 0) {
                self.circularProgressBar.hidden = true
            }
            else if (mod % 16 == 8) {
                self.circularProgressBar.hidden = false
            }
            self.circularBackground.color = UIColor.orangeColor().CGColor
            self.circularBackground.setNeedsDisplay()
            self.circularProgressBar.color = UIColor.orangeColor().CGColor
        }
        
        // flash progress bar during extra time
        else if (Int(minutes) == selectedTimeLimit && strSeconds != "30") {
            if (mod % 16 == 0) {
                self.circularProgressBar.hidden = true
            }
            else if (mod % 16 == 8) {
                self.circularProgressBar.hidden = false
            }
            self.circularBackground.color = UIColor.redColor().CGColor
            self.circularBackground.setNeedsDisplay()
            self.circularProgressBar.color = UIColor.redColor().CGColor
        }
        
        // end timer when time reaches time limit + extra time
        else if (Int(minutes) == selectedTimeLimit && strSeconds == "30") {
            endOfTimer()
        }
        
        // update progress bar
        self.progress = Float(currentTime/Double(selectedTimeLimit)/60)
        self.circularProgressBar.progress = self.progress
        self.circularProgressBar.setNeedsDisplay()
    }
    
    // Start, stop, or resume timing
    @IBAction func buttonPressed(sender: AnyObject) {
        
        (timing) ? pause() : resume()
    }
    
    @IBAction func startPressed(sender: AnyObject) {
        
        (timing) ? pause() : resume()
    }
    
    @IBAction func resetPressed(sender: AnyObject) {
        reset()
    }
    
    // Reset timer
    func longPressed(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if (gestureRecognizer.state == UIGestureRecognizerState.Began) {
            reset()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Timer Actions
    // Pause, Start/Resume, and Reset
    
    func pause() {
        timer.invalidate()
        progressBarTimer.invalidate()
        timing = false
        circularProgressBar.hidden = false
        
        self.startButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
        self.startButton.setTitle("Start", forState: .Normal)
        self.startButton.layer.borderColor = UIColor.greenColor().CGColor
        
        resetButton.alpha = 1.0
        resetButton.enabled = true
    }
    
    func resume() {
        timeLabel.textColor = UIColor.blackColor()
        timer = NSTimer.scheduledTimerWithTimeInterval(updateRate, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
        timing = true
        
        self.startButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        self.startButton.setTitle("Stop", forState: .Normal)
        self.startButton.layer.borderColor = UIColor.redColor().CGColor
        
        resetButton.alpha = 0.3
        resetButton.enabled = false
    }
    
    func reset() {
        self.currentTime = 0
        self.mod = 0
        self.timeLabel.text = "0:00"
        self.timeLabel.textColor = UIColor.blackColor()
        self.timer.invalidate()
        self.progressBarTimer.invalidate()
        self.timing = false
        self.progress = 0.00
        self.circularBackground.color = blueX.CGColor
        self.circularBackground.hidden = false
        self.circularBackground.setNeedsDisplay()
        self.circularProgressBar.color = blueX.CGColor
        self.circularProgressBar.progress = self.progress
        self.circularProgressBar.setNeedsDisplay()

        self.startButton.setTitle("Start", forState: .Normal)
        self.startButton.layer.borderColor = UIColor.greenColor().CGColor
        self.startButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
        
        self.resetButton.alpha = 0.3
        self.resetButton.enabled = false
    }
    
    func endOfTimer() {
        pause()
        self.circularBackground.hidden = true
        self.circularProgressBar.color = UIColor.redColor().CGColor
        self.circularProgressBar.setNeedsDisplay()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

            let toViewController = segue.destinationViewController as! UIViewController
            self.modalPresentationStyle = .Custom
            toViewController.transitioningDelegate = self.transitionOperator
    
        
    }
    
    // Presents the Navigation View when user swipes from left screen edge
    func swiped(gestureRecognizer: UIGestureRecognizer) {
        
        if (gestureRecognizer.state == UIGestureRecognizerState.Ended) {
            performSegueWithIdentifier("presentNav", sender: self)
        }
    }
    
    // Presents the Navigation View when user presses the menu button
    @IBAction func presentNavigation(sender: AnyObject?) {
        performSegueWithIdentifier("presentNav", sender: self)
    }
    
    
    //-----AVTHAR: Code for Recoder-----
    //Data variables
    var recordings : [NSManagedObject] = []  // recordings = core data objects
    //create audio recorder uninitialized
    var audioRecorder : AVAudioRecorder!
    
    //is device currently recording?
    var recording = false
    
    func recordAudio() {
        
        //-----Recording code----
        //Get the place to store the recorded file in the app's memory
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as! String
        
        //Name the file with date/time to be unique
        //get date
        var currentDateTime = NSDate();
        //new formatter
        var formatter = NSDateFormatter();
        formatter.dateFormat = "ddMMyyyy-HHmmss";
        
        //set file name
        //AVTHAR: DO NOT CHANGE FORMAT FROM WAV
        var recordingName = formatter.stringFromDate(currentDateTime) + ".wav"
        
        var pathArray = [dirPath, recordingName]
        
        //complete filePath from pathArray
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        //println("File is stored in path: \(filePath)")
        
        
        //Create a recording session
        var session=AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord,error:nil)
        
        //Initialize audio recorder
        audioRecorder = AVAudioRecorder(URL: filePath, settings:nil, error:nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled=true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        //tell other functions device is now in recording mode
        recording = true
        
        
        //Change 'record' button text to 'stop'
        self.recordButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        self.recordButton.setTitle("Stop", forState: .Normal)
        self.recordButton.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    //CALL SAVE TO CORE DATA FUNCTION
    // function from AVAudioRecorder Delegate for when recording ends
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        
        if(flag) {
            
            // arguments to pass into function
            var filePathURL = recorder.url.absoluteString // String version ofURL
            
            //gets title to store in core data
            var title1 = recorder.url.lastPathComponent!
            
            //Get date in format 2
            var currentDateTimef2 = NSDate()
            //new formatter
            var formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM/yyyy-HH:mm:ss"
            
            //formatted date in string form = formatter.stringFromDate(currentDateTimef2)
            
            //Call function to save data in core data when finished recording
            self.saveRecording(title1, displayName: title1, date: currentDateTimef2)
            //NOTE: title and DisplayName will be the same initially
            
            println("Sent to data model function --GREAT SUCCESS")
        }
            
        else {
            println("SAVE UNSUCCESSFUL")
        }
        
    }
    
    //stop recording function
    func stopRecording() {
        
        
        //----Stop Recording Code----
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
        recording = false //set tracker variable to false
        
        println("finished Recording")
        
        //----------Button code--------
        //Change 'stop' button back to 'record' button
        self.recordButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        self.recordButton.setTitle("Record", forState: .Normal)
        self.recordButton.layer.borderColor = UIColor.greenColor().CGColor
    }
    
    //function for saving RecordedAudio objects to CoreData
    func saveRecording(title: String, displayName: String, date: NSDate) {
        
        //1 Call app delegate instance
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        //2 Get entity
        let entity =  NSEntityDescription.entityForName("RecordedAudio", inManagedObjectContext : managedContext)
        
        //instance of entity
        let recording = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        //3 Set all values for object
        recording.setValue(title, forKey: "title")
        recording.setValue(displayName, forKey: "displayName") // Used to display name ofrecordings in TV
        recording.setValue(date, forKey: "date")
        
        //4 error
        var error : NSError?
        if !managedContext.save(&error) {
            println("ERROR 1 : Could not save \(error), \(error?.userInfo)")
        }
        
        //5 Add to recordings array
        recordings.append(recording)
    }
    
    //function to fetch all RecordedAudio Core data objects and sets them as the array 'Recordings'
    func fetchRecordings()
    
    {
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
            recordings = results
            
        }
            
        else {
            
            println("FETCH ERROR 2: Could not fetch \(error), \(error!.userInfo)")
            
            
            
        }
    } // end func
    
    
    //Before view will appear
    override func viewWillAppear(animated: Bool) {
        //Fetch Core data
        fetchRecordings()
    }
    
    //Facilitates record button <--> Stop button
    @IBAction func recordButtonPressed(sender: UIButton) {
        
        if (recording) {
            stopRecording()
        } else {
            recordAudio()
        }
        
    }//end func
    
    
    //To delete all previous core data
    func deleteAllCoreData() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "RecordedAudio")
        var myList = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject]
        
        recordings = myList!
        
        for song in recordings {
        
            managedContext.deleteObject(song)
        }
        
        managedContext.save(nil)
        
        println("All previous core data deleted")
        
    }
    

}
