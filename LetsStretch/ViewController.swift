//
//  ViewController.swift
//  LetsStretch
//
//  Created by Carl Burnham on 8/5/17.
//  Copyright © 2017 Carl Burnham. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BannerViewDelegate {
    
    /* Data */
    var routines = [Routine]()
    
    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var bannerView: BannerView?
    private var didLoadAd = false
    private let heroTitleLabel = UILabel()
    private let heroSubtitleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHomeChrome()
        getDateUpdated()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if !didLoadAd {
            didLoadAd = true
            loadAd()
        }
    }

    private func configureHomeChrome() {
        view.backgroundColor = AppTheme.background
        tableView.backgroundColor = AppTheme.background
        tableView.separatorStyle = .none
        tableView.rowHeight = 88
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 12, right: 0)
        tableView.showsVerticalScrollIndicator = false
        bannerContainer.backgroundColor = AppTheme.background

        // Soften the accent bar under the hero
        if let accentBar = tableView.superview?.subviews.first(where: { $0.bounds.height == 4 || abs($0.bounds.height - 4) < 0.5 }) {
            accentBar.backgroundColor = AppTheme.accent
        }
        // Walk stack for the 4pt accent view
        view.subviews.forEach { applyAccentIfNeeded(in: $0) }

        guard let hero = findHeroImageView() else { return }
        hero.contentMode = .scaleAspectFill
        hero.clipsToBounds = true

        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        hero.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: hero.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: hero.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: hero.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: hero.bottomAnchor)
        ])

        heroTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        heroTitleLabel.text = "Let's Stretch"
        heroTitleLabel.textColor = .white
        heroTitleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        hero.addSubview(heroTitleLabel)

        heroSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        heroSubtitleLabel.text = "Pick a routine and move"
        heroSubtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        heroSubtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        hero.addSubview(heroSubtitleLabel)

        NSLayoutConstraint.activate([
            heroTitleLabel.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 20),
            heroTitleLabel.trailingAnchor.constraint(equalTo: hero.trailingAnchor, constant: -20),
            heroTitleLabel.bottomAnchor.constraint(equalTo: heroSubtitleLabel.topAnchor, constant: -4),
            heroSubtitleLabel.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 20),
            heroSubtitleLabel.trailingAnchor.constraint(equalTo: hero.trailingAnchor, constant: -20),
            heroSubtitleLabel.bottomAnchor.constraint(equalTo: hero.bottomAnchor, constant: -18)
        ])
    }

    private func applyAccentIfNeeded(in view: UIView) {
        if view.constraints.contains(where: { ($0.firstAttribute == .height) && ($0.constant == 4) }) {
            view.backgroundColor = AppTheme.accent
        }
        view.subviews.forEach { applyAccentIfNeeded(in: $0) }
    }

    private func findHeroImageView() -> UIImageView? {
        func search(_ view: UIView) -> UIImageView? {
            if let imageView = view as? UIImageView,
               imageView.image == UIImage(named: "stretching_photo250height")
                || imageView.constraints.contains(where: { $0.firstAttribute == .height && ($0.constant == 180 || $0.constant == 220) }) {
                return imageView
            }
            for child in view.subviews {
                if let found = search(child) { return found }
            }
            return nil
        }
        return search(view)
    }
    
    /* Get data if it has been updated, else use the existing data */
    func getDateUpdated(){
        APIRequests.getDateUpdated(callback: dateCallback(dateUpdated:) )
    }
    
    func dateCallback(dateUpdated: String){
        let defaults = UserDefaults.standard
        let newDate = DateHelper.getDate(dateString: dateUpdated)
        
        if let savedDateString = defaults.string(forKey: "DateUpdated") {
            
            let savedDate = DateHelper.getDate(dateString: savedDateString)
             // Date froom server
            /* If the dates are different then get data from server */
            
            
            if(savedDate != newDate){
                getData()
                print("Dates do not match")
            }else{
                print("Get local data")
                getLocalData()
            }
        }else{
            /* If no saved date then make sure to get new data from server */
            print("No saved date, get new data")
            getData()
        }
        
        
        /* Save the new date */
        defaults.setValue(dateUpdated, forKey: "DateUpdated")
    }
    
    func getLocalData(){
        self.routines = Utils.getSavedRoutines()
        APIRequests.routines = self.routines
        self.tableView.reloadData()
        
        APIRequests.stretches = Utils.getSavedStretches()
    }
    

    
    func getData(){
        let defaults = UserDefaults.standard
        
        APIRequests.getRoutines(callback: callback(success:))
        APIRequests.getStretches(callback: {_ in
            let data = NSKeyedArchiver.archivedData(withRootObject: APIRequests.stretches)
            defaults.set(data, forKey: "SavedStretches")
        })
    }
    
    func callback(success: Bool){
        self.routines = APIRequests.routines
        self.tableView.reloadData()
        
        let defaults = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: self.routines)
        defaults.set(data, forKey: "SavedRoutines")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routines.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineCell",
                                                 for: indexPath) as! RoutineCell
        cell.configure(with: routines[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let routine = routines[indexPath.row]
        
        let stretchViewController = self.storyboard?.instantiateViewController(withIdentifier: "StretchViewController") as! StretchViewController
        stretchViewController.routine = routine
        
        navigationController?.pushViewController(stretchViewController, animated: true)
    }
    
    func loadAd() {
        bannerView = installBannerAd(
            in: bannerContainer,
            adUnitID: AdUnits.homeBanner,
            delegate: self
        )
    }

    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("Home banner loaded")
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("Home banner failed: \(error.localizedDescription)")
    }
}
