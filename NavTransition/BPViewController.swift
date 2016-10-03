//
//  BPViewController.swift
//  NavTransition
//
//  Created by Jonathan Yu on 6/25/15.
//  Copyright (c) 2015 Jonathan Yu. All rights reserved.
//

// Resources
// http://www.techotopia.com/index.php/An_iOS_8_Swift_Graphics_Tutorial_using_Core_Graphics_and_Core_Image

import UIKit

class BPViewController: UIViewController {
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var buttonLabel: UIButton!
    @IBOutlet var timeLimitSelector: UISegmentedControl!
    @IBOutlet var menuItem : UIBarButtonItem!
    @IBOutlet var toolbar : UIToolbar!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var startButton: UIButton!
    
    var transitionOperator = TransitionOperator()
    
    var timing: Bool = false
    var timer = NSTimer()
    var progressBarTimer = NSTimer()
    var currentTime = 0.0
    var mod = 0
    var selectedTimeLimit = 2
    var APDA = [7, 8, 4, 5]
    var progress: Float = 0.00
    var rectProgressBar: RectProgressBar!
    var rectProgressBarBackground: RectProgressBar!
    
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
        self.startButton.layer.cornerRadius = 30
        self.startButton.layer.borderWidth = 2
        self.startButton.layer.borderColor = UIColor.greenColor().CGColor
        
        // Configure reset button
        self.resetButton.backgroundColor = UIColor.whiteColor()
        self.resetButton.layer.cornerRadius = 30
        self.resetButton.layer.borderWidth = 2
        self.resetButton.layer.borderColor = UIColor.blackColor().CGColor
        self.resetButton.alpha = 0.3
        self.resetButton.enabled = false
        
        // Set custom background color
        self.view.backgroundColor = gray
        
        // Display rectangular progress bar
        self.rectProgressBar = RectProgressBar()
        self.rectProgressBar.frame = CGRect(x: 0.0, y: 184.0, width: 375.0, height: 180.0)
        self.rectProgressBar.backgroundColor = UIColor.clearColor()
        self.rectProgressBar.alpha = 0.20
        self.view.addSubview(rectProgressBar)
        self.view.sendSubviewToBack(rectProgressBar)
        
        // Display rectangular progress background
        self.rectProgressBarBackground = RectProgressBar()
        self.rectProgressBarBackground.progress = 1.0
        self.rectProgressBarBackground.color = UIColor.whiteColor().CGColor
        self.rectProgressBarBackground.frame = CGRect(x: 0.0, y: 184.0, width: 375.0, height: 180.0)
        self.view.addSubview(rectProgressBarBackground)
        self.view.sendSubviewToBack(rectProgressBarBackground)

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
                self.rectProgressBar.hidden = true
            }
            else if (mod % 16 == 8) {
                self.rectProgressBar.hidden = false
            }
            self.rectProgressBar.color = UIColor.orangeColor().CGColor
            self.rectProgressBar.setNeedsDisplay()
            self.rectProgressBar.color = UIColor.orangeColor().CGColor
        }
            
            // flash progress bar during extra time
        else if (Int(minutes) == selectedTimeLimit && strSeconds != "30") {
            if (mod % 16 == 0) {
                self.rectProgressBar.hidden = true
            }
            else if (mod % 16 == 8) {
                self.rectProgressBar.hidden = false
            }
            self.rectProgressBar.color = UIColor.redColor().CGColor
            self.rectProgressBar.setNeedsDisplay()
            self.rectProgressBar.color = UIColor.redColor().CGColor
        }
            
            // end timer when time reaches time limit + extra time
        else if (Int(minutes) == selectedTimeLimit && strSeconds == "30") {
            endOfTimer()
        }
        
        // update progress bar
        self.progress = Float(currentTime/Double(selectedTimeLimit)/60)
        self.rectProgressBar.progress = self.progress
        self.rectProgressBar.setNeedsDisplay()
    }
    
    // Start, stop, or resume timing
    @IBAction func buttonPressed(sender: AnyObject) {
        
        if (timing) {
            pause()
        } else {
            resume()
        }
    }
    
    
    @IBAction func startPressed(sender: AnyObject) {
        if (timing) {
            pause()
        } else {
            resume()
        }
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
        rectProgressBar.hidden = false
        
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
        self.rectProgressBar.color = blueX.CGColor
        self.rectProgressBar.hidden = false
        self.rectProgressBar.setNeedsDisplay()
        self.rectProgressBar.color = blueX.CGColor
        self.rectProgressBar.progress = self.progress
        self.rectProgressBar.setNeedsDisplay()
        
        self.startButton.setTitle("Start", forState: .Normal)
        self.startButton.layer.borderColor = UIColor.greenColor().CGColor
        self.startButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
        
        self.resetButton.alpha = 0.3
        self.resetButton.enabled = false
    }
    
    func endOfTimer() {
        pause()
        self.rectProgressBar.hidden = false
        self.rectProgressBar.color = UIColor.redColor().CGColor
        self.rectProgressBar.setNeedsDisplay()
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
    
}
