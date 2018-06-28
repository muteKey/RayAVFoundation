//
//  ViewController.swift
//  PenguinPet
//
//  Created by Michael Briscoe on 1/13/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
// 

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController {

  @IBOutlet weak var penguin: UIImageView!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var recordButton: UIButton!
  @IBOutlet weak var playButton: UIButton!
  
  var audioStatus: AudioStatus = AudioStatus.Stopped
  
  var audioRecorder: AVAudioRecorder!
  var audioPlayer: AVAudioPlayer!
  
  // MARK: - Setup
  override func viewDidLoad() {
    super.viewDidLoad()
    setupRecorder()
	
	let session = AVAudioSession.sharedInstance()
	let nc = NotificationCenter.default
	
	nc.addObserver(self, 
				   selector: #selector(handleInteruptions(note:)),
				   name: NSNotification.Name.AVAudioSessionInterruption, 
				 object: session)
	nc.addObserver(self, 
				   selector: #selector(handleRouteChanges(note:)), 
				   name: NSNotification.Name.AVAudioSessionRouteChange, 
				   object: session)
	
  }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
  
  // MARK: - Controls
  @IBAction func onRecord(sender: UIButton) {
    if appHasMicAccess == true { // Look into why I did this ;]
      if audioStatus != .Playing {
        
        switch audioStatus {
        case .Stopped:
        recordButton.setBackgroundImage(UIImage(named: "button-record1"), for: .normal)
          record()
        case .Recording:
            recordButton.setBackgroundImage(UIImage(named: "button-record"), for: .normal)
          stopRecording()
        default:
          break
        }
      }
    } else {
        recordButton.isEnabled = false
      let theAlert = UIAlertController(title: "Requires Microphone Access",
        message: "Go to Settings > PenguinPet > Allow PenguinPet to Access Microphone.\nSet switch to enable.",
        preferredStyle: .alert)
      
      theAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.view?.window?.rootViewController?.present(theAlert, animated: true, completion:nil)
    }

  }

  @IBAction func onPlay(sender: UIButton) {
    if audioStatus != .Recording {
      
      switch audioStatus {
      case .Stopped:
        play()
      case .Playing:
        stopPlayback()
      default:
        break
      }
    }
  }

  func setPlayButtonOn(flag: Bool) {
    if flag == true {
        playButton.setBackgroundImage(UIImage(named: "button-play1"), for: .normal)
    } else {
        playButton.setBackgroundImage(UIImage(named: "button-play"), for: .normal)
    }
  }

  
}

// MARK: - AVFoundation Methods
extension ViewController: AVAudioPlayerDelegate, AVAudioRecorderDelegate {
  
  // MARK: Recording
  func setupRecorder() {
    let fileURL = getURLforMemo()
    let recordSettings = [
        AVFormatIDKey: Int(kAudioFormatLinearPCM),
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]
    
    do {
        audioRecorder = try AVAudioRecorder(url: fileURL, settings: recordSettings)
        audioRecorder.delegate = self
        audioRecorder.prepareToRecord()
    } catch {
        print("Error creating recorder")
    }
}
  

  func record() {
    audioStatus = .Recording
    audioRecorder.record()
  }
  
  func stopRecording() {
    recordButton.setBackgroundImage(UIImage(named: "button-record"), for: .normal)
    audioStatus = .Stopped
    audioRecorder.stop()
  }
  
  // MARK: Playback
  func  play() {
	let fileURL = getURLforMemo()
	do {
		audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
		audioPlayer.delegate = self
		if audioPlayer.duration > 0 {
			setPlayButtonOn(flag: true)
			audioStatus = .Playing
			audioPlayer.play()
		}
	} catch {
		print("Error playing audio")
	}
  }
  
  func stopPlayback() {
    setPlayButtonOn(flag: false)
    audioStatus = .Stopped
	audioPlayer.stop()
  }
  
  // MARK: Delegates
	
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		audioStatus = .Stopped
		setPlayButtonOn(flag: false)
	}

	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		audioStatus = .Stopped
	}
  
  // MARK: Notifications
	
	@objc func handleInteruptions(note: Notification) {
		if let info = note.userInfo {
			let t = info[AVAudioSessionInterruptionTypeKey] as! UInt
			let type = AVAudioSessionInterruptionType(rawValue: t)
			if type == .began {
				if audioStatus == .Playing {
					stopPlayback()
				} else if audioStatus == .Recording {
					stopRecording()
				}
			} else {
				let o = info[AVAudioSessionInterruptionOptionKey] as! UInt
				let options = AVAudioSessionInterruptionOptions(rawValue: o)
				if options == .shouldResume {
					//...
				}
			}
		}
	}
	
	@objc func handleRouteChanges(note: Notification) {
		if let info = note.userInfo {
			let r = info[AVAudioSessionRouteChangeReasonKey] as! UInt
			let reason = AVAudioSessionRouteChangeReason(rawValue: r)
			if reason == AVAudioSessionRouteChangeReason.oldDeviceUnavailable {
				let previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription
				let prevousOutput = previousRoute!.outputs.first!
				if prevousOutput.portType == AVAudioSessionPortHeadphones {
					if audioStatus == .Playing {
						stopPlayback()
					} else if audioStatus == .Recording {
						stopRecording()
					}
				}
			}
		}
	}
  
  // MARK: - Helpers
  
  func getURLforMemo() -> URL {
    let tempDir = NSTemporaryDirectory()
    let filePath = tempDir + "/TempMemo.caf"
    
    return URL(fileURLWithPath: filePath)
  }
}


