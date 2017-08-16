//
//  Utils.swift
//  LetsStretch
//
//  Created by Carl Burnham on 8/14/17.
//  Copyright © 2017 Carl Burnham. All rights reserved.
//

import Foundation

class DateHelper{

    
    public static func getDate(dateString: String) -> Date{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let date = dateFormatter.date(from: dateString)!
        return date
    }
    
}

class Utils{
    static func getSavedRoutines() -> [Routine]{
        if let data = UserDefaults.standard.object(forKey: "SavedRoutines") as? NSData {
            let routinesList = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [Routine]
            return routinesList
        }
        return [Routine]()
    }
    
    static func getSavedStretches() -> [Stretch]{
        if let data = UserDefaults.standard.object(forKey: "SavedStretches") as? NSData {
            let stretchList = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [Stretch]
            return stretchList
        }
        return [Stretch]()
    }
}
