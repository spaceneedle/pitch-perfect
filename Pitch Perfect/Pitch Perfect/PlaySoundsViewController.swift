//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Casey on 3/5/15.
//  Copyright (c) 2015 Casey Halverson. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    var audioPlayer:AVAudioPlayer!
    var receivedAudio:RecordedAudio!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    var audioPlayerNode:AVAudioPlayerNode!
    var echoEffect:AVAudioUnitDelay!
    var timePitchEffect:AVAudioUnitTimePitch!
    var distortionEffect:AVAudioUnitDistortion!
    var speedEffect:AVAudioUnitVarispeed!

    override func viewDidLoad() {
        super.viewDidLoad()

        // setup our audio file and initalize our effects
        
        audioPlayerNode = AVAudioPlayerNode()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        echoEffect = AVAudioUnitDelay()
        timePitchEffect = AVAudioUnitTimePitch()
        distortionEffect = AVAudioUnitDistortion()
        speedEffect = AVAudioUnitVarispeed()
        audioEngine = AVAudioEngine()
        
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(echoEffect)
        audioEngine.attachNode(timePitchEffect)
        audioEngine.attachNode(distortionEffect)
        audioEngine.attachNode(speedEffect)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // each of our buttons calls a common function which changes playback effects
    
    
    @IBAction func playDistort(sender: UIButton) {
        playAudio(0, rate: 0, echo: 0, distort: 100)
    }
    @IBAction func playEcho(sender: UIButton) {
        playAudio(0, rate: 0, echo: 0.25, distort: 0)
    }
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        playAudio(-1000,rate: 0, echo: 0, distort: 0)
    }
    @IBAction func playSlowAudio(sender: UIButton) {
        playAudio(0,rate: 0.5, echo: 0, distort: 0)
    }
    
    @IBAction func playFastSound(sender: UIButton) {
        playAudio(0,rate: 2.0, echo: 0, distort: 0)
    }
    @IBAction func stopAllAudio(sender: UIButton) {
        audioPlayerNode.stop()
    }
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudio(1000,rate: 0, echo: 0, distort: 0)
   }
    
    // playAudio function allows control of various effects using one function
    
    func playAudio(pitch: Float, rate: Float, echo: Float, distort: Float) {
        
        // stop all audio, reset engine
        
        audioEngine.stop()
        audioEngine.reset()
        audioPlayerNode.stop()
        
        // set everything to a known value
        
        echoEffect.delayTime = NSTimeInterval(0)
        echoEffect.feedback = 0
        distortionEffect.wetDryMix = 0
        timePitchEffect.pitch = 1
        speedEffect.rate = 1
        
        // Set our audio parameters

        timePitchEffect.pitch = pitch
        
        if(rate != 0) { speedEffect.rate = rate }  // prevents an bug where settting rate to 0 has a strange effect on timepitch
        
        if(echoEffect != 0) {
            echoEffect.delayTime = NSTimeInterval(echo)
            echoEffect.feedback = 25
        } else { echoEffect.delayTime = 0 }
        
        distortionEffect.wetDryMix = distort
        
        // Chain our nodes together and plays the audio
        
        audioEngine.connect(audioPlayerNode, to: speedEffect, format: nil)
        audioEngine.connect(speedEffect, to:timePitchEffect, format: nil)
        audioEngine.connect(timePitchEffect, to: distortionEffect, format: nil)
        audioEngine.connect(distortionEffect, to: echoEffect, format: nil)
        audioEngine.connect(echoEffect, to: audioEngine.outputNode, format: nil)
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
        

}

