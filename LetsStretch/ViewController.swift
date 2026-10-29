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
    private let settingsButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHomeChrome()
        // Offline-first: show bundled / archived content immediately, then optionally refresh.
        APIRequests.ensureSeededContent()
        routines = APIRequests.routines
        tableView.reloadData()
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

        configureSettingsButton()

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

    private func configureSettingsButton() {
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        settingsButton.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: config), for: .normal)
        settingsButton.tintColor = .white
        settingsButton.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        settingsButton.layer.cornerRadius = 18
        settingsButton.accessibilityLabel = "Settings"
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        view.addSubview(settingsButton)
        view.bringSubviewToFront(settingsButton)

        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            settingsButton.widthAnchor.constraint(equalToConstant: 36),
            settingsButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    @objc private func openSettings() {
        let settings = SettingsViewController()
        navigationController?.pushViewController(settings, animated: true)
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
    
    /* Optional network refresh — UI already seeded from bundle / UserDefaults. */
    func getDateUpdated(){
        APIRequests.getDateUpdated(callback: dateCallback(dateUpdated:) )
    }
    
    func dateCallback(dateUpdated: String){
        // Ignore sentinel from a total content miss; keep whatever we already seeded.
        guard dateUpdated != "00/00/0000",
              let newDate = optionalDate(from: dateUpdated) else {
            refreshTableFromAPI()
            return
        }

        let defaults = UserDefaults.standard

        if let savedDateString = defaults.string(forKey: "DateUpdated"),
           let savedDate = optionalDate(from: savedDateString),
           savedDate == newDate {
            print("Get local data")
            getLocalData()
        } else {
            print(defaults.string(forKey: "DateUpdated") == nil
                  ? "No saved date, refresh from network/bundle"
                  : "Dates do not match")
            getData()
        }

        defaults.setValue(dateUpdated, forKey: "DateUpdated")
    }

    private func optionalDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: dateString)
    }
    
    func getLocalData(){
        let saved = Utils.getSavedRoutines()
        let savedStretches = Utils.getSavedStretches()
        if !saved.isEmpty && !savedStretches.isEmpty {
            self.routines = saved
            APIRequests.routines = saved
            APIRequests.stretches = savedStretches
        } else {
            APIRequests.ensureSeededContent()
            self.routines = APIRequests.routines
        }
        self.tableView.reloadData()
    }

    func getData(){
        APIRequests.getRoutines(callback: callback(success:))
        APIRequests.getStretches(callback: { _ in
            APIRequests.archiveCurrentContent()
        })
    }
    
    func callback(success: Bool){
        if !success {
            APIRequests.ensureSeededContent()
        }
        refreshTableFromAPI()
        APIRequests.archiveCurrentContent()
    }

    private func refreshTableFromAPI() {
        self.routines = APIRequests.routines
        self.tableView.reloadData()
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
