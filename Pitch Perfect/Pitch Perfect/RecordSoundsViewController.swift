//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Casey on 3/4/15.
//  Copyright (c) 2015 Casey Halverson. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // Set up our button outlets
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingText: UILabel!
    
    // set up our audio recording
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    // setup the variable that tracks our pausing audio state
    
    var pauseState = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true
        recordingText.text = "Tap to record"
        recordingText.hidden = false
        pauseButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    
    // if our microphone is clicked...

    @IBAction func recordAudio(sender: UIButton) {

        recordingText.text = "Recording in progress"
        
        // modify our buttons and label display to show the user controls and status
        
        recordingText.hidden = false
        recordButton.enabled = false
        stopButton.hidden = false
        pauseButton.hidden = false
        
        // find a location to store the audio recording, and give it a unique file name
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        // setup our audio session
        
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        // prepare the audio recorder and start recording
        
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    
    // if we finished recording
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if(flag) {

        // save the recorded audio
            
        recordedAudio = RecordedAudio()
        recordedAudio.filePathUrl = recorder.url
        recordedAudio.title = recorder.url.lastPathComponent
    
        // pass along the recorded audio file name to next screen
            
        self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
        else {
            // println("Recording was not successful")
            recordButton.enabled = true
            stopButton.hidden = true
        }
    }
    
    // if audio is paused
    
   
    @IBAction func pauseAudio(sender: UIButton) {
        
        // simple state machine that allows us to toggle recording on and off, along with telling
        // the user what state we are in.
        
        if(pauseState == 1) {
            recordingText.text = "Recording"
            audioRecorder.record()
            pauseButton.setImage(UIImage(named:"pause1x.png"), forState:UIControlState.Normal)
            pauseState = 0
            // println("Recording again")
        }
        else {
            recordingText.text = "Paused"
            audioRecorder.pause()
            pauseButton.setImage(UIImage(named:"recordstart1x.png"), forState:UIControlState.Normal)
            pauseState = 1
            // println("Pausing audio")
        }
    }
    
    // handle our stop audio button
    
    
    @IBAction func stopAudio(sender: UIButton) {

        // hide various UI elements to show we have stopped recording
        
        recordingText.hidden = true
        stopButton.hidden = true
        recordButton.enabled = true

        // stop audio
        
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        
        audioSession.setActive(false, error: nil)
       // print("Recording Stopped")
    }
    
    // Segue to our next screen
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "stopRecording") {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            let data = sender as RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }

   

}




