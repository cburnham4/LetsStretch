//
//  StretchViewController.swift
//  LetsStretch
//
//  Created by Carl Burnham on 8/5/17.
//  Copyright © 2017 Carl Burnham. All rights reserved.
//

import UIKit
import Kingfisher
import GoogleMobileAds
// import this
import AVFoundation


class StretchViewController: UIViewController, GADBannerViewDelegate {
    
    /* Outlets */
    @IBOutlet weak var stretchNameLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var stretchImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var stretchNumLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    /* Data */
    var stretches = [Stretch]()
    var routine: Routine?
    var stretchIndex = 0;
    
    /* Timer */
    var secondsLeft = 30;
    var isRunning = false;
    var timer = Timer()
    final var restTime = 3;
    var isRestTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stretchIndex = 0
        
        loadAd()
        self.navigationController?.isNavigationBarHidden = false
        getStretches()
        startStretches()
        
        self.title = routine?.name
    }

    func getStretches(){
        for stretchName in (routine?.stretchKeys)!{
            for stretch in APIRequests.stretches {
                if(stretchName == stretch.name){
                    self.stretches.append(stretch)
                }
            }
        }
    }
    
    func startStretches(){
        if(stretches.count <= stretchIndex) {
            /* Go back to main page */
            navigationController?.popViewController(animated: true)
            return
        }else{
            /* Request ad */
            let request = GADRequest()
            bannerView.load(request)
        }
        let stretch = stretches[stretchIndex]
        
        /* Set stretch values */
        self.secondsLeft = restTime
        stretchNameLabel.text = stretch.name
        instructionLabel.text = stretch.instructions
        let url = URL(string: (stretch.imageURL))
        stretchImage.kf.setImage(with: url)
        stretchNumLabel.text = "\(stretchIndex + 1) / \(stretches.count)"
        
        timeLabel.text = "\(secondsLeft)"
        runTimer()
    }
    
    func runTimer(){
        timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
    }
    
    @objc func updateClock(){
        if(stretches.count <= stretchIndex) {
            /* Go back to main page */
            navigationController?.popViewController(animated: true)
            return
        }
        
        secondsLeft -= 1;
        timeLabel.text = "\(secondsLeft)"
        if(secondsLeft == 0){
            if(isRestTime){
                secondsLeft = stretches[stretchIndex].time
                timeLabel.text = "\(secondsLeft)"
                isRestTime = false
                
            }else{
                playSound()
                stretchIndex += 1;
                startStretches()
                isRestTime = true
            }
            
        }
        
    }
    
    func playSound(){
        
        // create a sound ID, in this case its the tweet sound.
        let systemSoundID: SystemSoundID = 1008
        
        // to play sound
        AudioServicesPlaySystemSound (systemSoundID)
    }
    

    @IBAction func nextButtonClicked(_ sender: UIButton) {
        stretchIndex += 1;
        startStretches()
        isRestTime = true
    }
    
    @IBAction func pauseClicked(_ sender: UIButton) {
        if self.isRunning == false {
            timer.invalidate()
            self.isRunning = true
            sender.setTitle("Play", for: .normal)
        } else {
            runTimer()
            self.isRunning = false
            sender.setTitle("Pause", for: .normal)
        }
    }
    func loadAd(){
        print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
        
        bannerView.delegate = self
        
        /* Setup the bannerview */
        bannerView.adUnitID = "ca-app-pub-8223005482588566/2963446943"
        bannerView.rootViewController = self
        
        /* Request the new ad */
        let request = GADRequest()
        bannerView.load(request)
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }


}
