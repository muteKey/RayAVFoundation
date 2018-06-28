//
//  AppDelegate.swift
//  PenguinPet
//
//  Created by Michael Briscoe on 1/13/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appHasMicAccess: Bool = false


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try session.setActive(true)
            session.requestRecordPermission({ (granted) in
                self.appHasMicAccess = granted
            })
        } catch let error as NSError {
            print(error)
        }
        
        return true
    }


}

