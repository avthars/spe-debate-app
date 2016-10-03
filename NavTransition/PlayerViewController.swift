//
//  PlayerViewController.swift
//  NavTransition
//
//  Created by Avthar Sewrathan on 7/13/15.
//  Copyright (c) 2015 App Design Vault. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import MessageUI

class PlayerViewController: UIViewController, AVAudioPlayerDelegate, AVAudioSessionDelegate, MFMailComposeViewControllerDelegate {

    //declare audio player
    var audioPlayer : AVAudioPlayer!
    
    //passed title and display name from table view VC
    var passedTitle : String = ""
    var passedDisplayName : String = ""
    
    //audioprogress slider
    @IBOutlet weak var audioProgressSlider: UISlider!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }

    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
    
        
    println("passed title: \(passedTitle)")
    println("passed labelName: \(passedDisplayName)")
        
        
    //playback player with passed title
    playBackRecording(passedTitle)
    
        
        //Set Display label text
        displayLabel.text = passedDisplayName
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var displayLabel: UILabel!
    
    
    //playback from title
    func playBackRecording(fileName: String) {
        
    
        //println("path: \(fileName)")
        
        
        //directory in which audio is stored in Core Data
        if let directoryURL = NSFileManager.defaultManager()
            .URLsForDirectory(.DocumentDirectory,
                inDomains: .UserDomainMask)[0]
            as? NSURL {
                
                //Make new path by appending file name to core storage location path
                let newPath = directoryURL.URLByAppendingPathComponent(fileName)
                
                //println("New filePath is : \(newPath)")
                
                var err: NSError?
                
                //Initialize Audioplayer with that data
                audioPlayer = AVAudioPlayer(contentsOfURL: newPath, error: &err)
                
                if let error = err {
                    println("audioPlayer error \(error.localizedDescription)")
                }
                
                //Set up to play
                println("Setting delegate")
                audioPlayer.delegate = self
                println("Playing")
                audioPlayer.prepareToPlay()
                audioPlayer.play()
        }
        
    } //end function
    
    
    //----PAUSE/ PLAY/ STOP Functions --------
    func pausePlay(){
    //pause audioplayer
    audioPlayer.pause()
    
    }
    
    func resumePlay(){
        //resume playing
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }

    func stopPlay(){
        audioPlayer.stop()
    }

    @IBOutlet weak var pausePlayButton: UIBarButtonItem!
    
    @IBAction func pauseAudio(sender: UIBarButtonItem) {
        //Call pause func
        self.pausePlay()
        //disabel pause button
        pausePlayButton.enabled = false
        
        //enable play button
        playButton.enabled = true
        
    }
    
    
    @IBOutlet weak var playButton: UIBarButtonItem!
    
    
    @IBAction func playAudioButton(sender: UIBarButtonItem) {
        //Resume play
        self.resumePlay()
        
        //enable relevant buttons
        playButton.enabled = false
        pausePlayButton.enabled = true
    }
    
    
    //---VOLUME SLIDER CODE----
    //Volume slider
    @IBOutlet weak var volumeSider: UISlider!
    @IBAction func volumeSliderHasChanged(sender: UISlider) {
        
        //changed slider = change in volume of player
        audioPlayer.volume = sender.value
        
        
    }
    
    
    @IBOutlet weak var timeInLabel: UILabel!
    
    
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    
    
    
    //----- EMAIL: SEND FILE AS EMAIL FUNCTIONALITY-----
    
    
    @IBOutlet weak var sendAttachmentButton: UIBarButtonItem!
    
    @IBAction func sendEmailAttachment(sender: UIBarButtonItem) {
        
        pausePlay()
        
        //Check to see the device can send email.
        if( MFMailComposeViewController.canSendMail() ) {

            println("Can send email.")
        
            //instance of MailComposeVC
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject(passedDisplayName) // display name of file
            mailComposer.setMessageBody("Debate round recording from SPE Debate App", isHTML: false)
        
            
            //directory in which audio is stored in Core Data
            if let directoryURL = NSFileManager.defaultManager()
                .URLsForDirectory(.DocumentDirectory,
                    inDomains: .UserDomainMask)[0]
                as? NSURL {
                    
                    //Make new path by appending file name to core storage location path
                    let newPath = directoryURL.URLByAppendingPathComponent(passedTitle)
                    
                    println("New filePath is : \(newPath)")
                    
                    println("Path to file set")
                    
                    //load file as Data
                    if let fileData = NSData(contentsOfURL: newPath) {
                        
                        println("File data loaded.")
                        
                        //load attachment to mail compose
                        mailComposer.addAttachmentData(fileData, mimeType: "audio/wav", fileName: passedDisplayName)
                        
                        println("Attachment set successfully")
                        
                    }
                  
        }//end if let in main directory
        
            //Present VC
            self.presentViewController(mailComposer, animated: true, completion: nil)
            
            
            
        }//end if let can send email
        
    }//end sendEmailAttachment func
    
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        
        //dismiss when finished sending
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //resume playing audio
        resumePlay()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
