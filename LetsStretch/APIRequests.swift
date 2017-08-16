//
//  APIRequests.swift
//  LetsStretch
//
//  Created by Carl Burnham on 8/5/17.
//  Copyright © 2017 Carl Burnham. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

class APIRequests{
    
    static var routines = [Routine]()
    static var stretches = [Stretch]()
    
    static func getRoutines(callback: @escaping (_ success: Bool) -> ()){
        print("Get routines ")
        let dbRef = Database.database().reference().child("Routines")

        routines = [Routine]()
        
        dbRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.childrenCount.description)
            
            let children = snapshot.children
            
            // Get user value
            while let dataSnap = children.nextObject() as? DataSnapshot{
                print(dataSnap.key)
                let name = dataSnap.key
                let value = dataSnap.value as? NSDictionary
                let stretches = value?["Stretches"] as! [String]
                let imageUrl = value?["downloadURL"] as! String
                
                routines.append(Routine(stretchKeys: stretches, imageURL: imageUrl, name: name))
            }
            print(snapshot.childrenCount.description)
            DispatchQueue.main.async(execute: {
                callback(true)
            })


        }) { (error) in
            print("Error" +  error.localizedDescription)
            DispatchQueue.main.async(execute: {
                callback(false)
            })

        }
        print("Try to get routines bottom")
        
 
    }
    
    public static func getStretches(callback: @escaping (_ success: Bool) -> ()){
        let dbRef = Database.database().reference().child("Stretches")
        
        stretches = [Stretch]()
        
        dbRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.childrenCount.description)
            
            let children = snapshot.children
            
            // Get user value
            while let dataSnap = children.nextObject() as? DataSnapshot{
                let name = dataSnap.key
                let value = dataSnap.value as? NSDictionary
                let instruction = value?["instructions"] as! String
                let imageUrl = value?["downloadURL"] as! String
                let time = value?["time"] as! Int
                
                stretches.append(Stretch(name: name, instructions: instruction, time: time, key: name, imageURL: imageUrl))
                
                
            }
            print(snapshot.childrenCount.description)
            DispatchQueue.main.async(execute: {
                callback(true)
            })
            
            
        }) { (error) in
            print("Error" +  error.localizedDescription)
            DispatchQueue.main.async(execute: {
                callback(false)
            })
            
        }
    }
    
    public static func getDateUpdated(callback: @escaping (_ date: String) -> ()){
        let dbRef = Database.database().reference().child("Updated")
        
        dbRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.childrenCount.description)
            
            let dateUpdated = snapshot.value as! String
            
            
            print(dateUpdated)
            DispatchQueue.main.async(execute: {
                callback(dateUpdated)
            })
            
            
        }) { (error) in
            print("Error" +  error.localizedDescription)
            DispatchQueue.main.async(execute: {
                callback("00/00/0000")
            })
            
        }

    }

}
