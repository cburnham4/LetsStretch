//
//  File.swift
//  LetsStretch
//
//  Created by Carl Burnham on 8/5/17.
//  Copyright © 2017 Carl Burnham. All rights reserved.
//

import Foundation

public class Routine: NSObject, NSCoding {
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.stretchKeys, forKey: "stretchKeys");
        aCoder.encode(self.imageURL, forKey: "imageURL");
        aCoder.encode(self.name, forKey: "name");
    }

    var stretchKeys : [String]
    var imageURL: String
    var name: String
    
    init(stretchKeys: [String], imageURL: String, name: String){
        self.stretchKeys = stretchKeys
        self.imageURL = imageURL
        self.name = name
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.stretchKeys = (aDecoder.decodeObject(forKey: "stretchKeys") as? [String])!;
        self.imageURL = (aDecoder.decodeObject(forKey: "imageURL") as? String)!;
        self.name = (aDecoder.decodeObject(forKey: "name") as? String)!;
    }
    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encode(self.stretchKeys, forKey: "stretchKeys");
//        aCoder.encode(self.imageURL, forKey: "imageURL");
//        aCoder.encode(self.name, forKey: "name");
//    }
}

public class Stretch: NSObject, NSCoding {
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name");
        aCoder.encode(self.instructions, forKey: "instructions");
        aCoder.encode(self.time, forKey: "time");
        aCoder.encode(self.key, forKey: "key");
        aCoder.encode(self.imageURL, forKey: "imageURL");
    }


    var name: String
    var instructions: String
    var time: Int
    var key: String
    var imageURL: String
    
    init(name: String, instructions: String, time: Int, key: String, imageURL: String) {
        self.name = name
        self.instructions = instructions
        self.time = time
        self.key = key
        self.imageURL = imageURL
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.name = (aDecoder.decodeObject(forKey: "name") as? String)!;
        self.instructions = (aDecoder.decodeObject(forKey: "instructions") as? String)!;
        self.time = (aDecoder.decodeInteger(forKey: "time"));
        self.key = (aDecoder.decodeObject(forKey: "key") as? String)!;
        self.imageURL = (aDecoder.decodeObject(forKey: "imageURL") as? String)!;
    }
    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encode(self.name, forKey: "name");
//        aCoder.encode(self.instructions, forKey: "instructions");
//        aCoder.encode(self.time, forKey: "time");
//        aCoder.encode(self.key, forKey: "key");
//        aCoder.encode(self.imageURL, forKey: "imageURL");
//        
//    }
}
