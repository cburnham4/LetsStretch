//
//  ViewController.swift
//  LetsStretch
//
//  Created by Carl Burnham on 8/5/17.
//  Copyright © 2017 Carl Burnham. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Kingfisher

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /* Data */
    var routines = [Routine]()
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDateUpdated()
        
        routines.append(Routine(stretchKeys: [String](), imageURL: "", name: "Stretch"))
        
        loadAd()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
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
        
        let routine = routines[indexPath.row]
        
        cell.routineNameLabel.text = routine.name
        let url = URL(string: (routine.imageURL))
        
        cell.routineImage.kf.setImage(with: url)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let routine = routines[indexPath.row]
        
        let stretchViewController = self.storyboard?.instantiateViewController(withIdentifier: "StretchViewController") as! StretchViewController
        stretchViewController.routine = routine
        
        self.navigationController?.pushViewController(stretchViewController, animated: true)
        
    }
    
    func loadAd(){
        /* Setup the bannerview */
        bannerView.adUnitID = "ca-app-pub-8223005482588566/6902691958"
        bannerView.rootViewController = self
        
        /* Request the new ad */
        let request = GADRequest()
        bannerView.load(request)
    }
}
