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


class StretchViewController: UIViewController, BannerViewDelegate {
    
    /* Outlets */
    @IBOutlet weak var stretchNameLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var stretchImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var stretchNumLabel: UILabel!
    @IBOutlet weak var bannerContainer: UIView!
    private var bannerView: BannerView?
    private var didLoadAd = false
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
        applyStretchChrome()
        
        self.navigationController?.isNavigationBarHidden = false
        getStretches()
        startStretches()
        
        self.title = routine?.name
    }

    private func applyStretchChrome() {
        view.backgroundColor = AppTheme.background
        view.tintColor = AppTheme.accent
        bannerContainer?.backgroundColor = AppTheme.background
        timeLabel.superview?.backgroundColor = AppTheme.background

        stretchNameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        stretchNameLabel.textColor = AppTheme.ink

        instructionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        instructionLabel.textColor = AppTheme.inkSecondary
        instructionLabel.textAlignment = .left

        timeLabel.font = .monospacedDigitSystemFont(ofSize: 44, weight: .bold)
        timeLabel.textColor = AppTheme.accent

        stretchNumLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        stretchNumLabel.textColor = AppTheme.inkSecondary

        stretchImage.backgroundColor = AppTheme.surface
        stretchImage.layer.cornerRadius = 20
        stretchImage.layer.cornerCurve = .continuous
        stretchImage.clipsToBounds = true
        stretchImage.contentMode = .scaleAspectFit
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !didLoadAd {
            didLoadAd = true
            loadAd()
        }
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
            bannerView?.load(Request())
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
    func loadAd() {
        bannerView = installBannerAd(
            in: bannerContainer,
            adUnitID: AdUnits.stretchBanner,
            delegate: self
        )
    }
    
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("Stretch banner loaded")
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("Stretch banner failed: \(error.localizedDescription)")
    }
}
