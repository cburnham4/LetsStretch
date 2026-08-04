//
//  APIRequests.swift
//  LetsStretch
//
//  Created by Carl Burnham on 8/5/17.
//  Copyright © 2017 Carl Burnham. All rights reserved.
//

import Foundation

class APIRequests {

    /// Static content hosted in this repo (replaces Firebase Realtime Database).
    static let contentURL = URL(string:
        "https://raw.githubusercontent.com/cburnham4/LetsStretch/master/content/data/content.json"
    )!

    static var routines = [Routine]()
    static var stretches = [Stretch]()

    private static var cachedRoot: [String: Any]?
    private static var inFlightWaiters: [(Bool) -> Void]?

    /// Fetches (or reuses) the shared content.json payload.
    private static func loadContent(forceRefresh: Bool = false, completion: @escaping (Bool) -> Void) {
        if !forceRefresh, cachedRoot != nil {
            completion(true)
            return
        }

        if var waiters = inFlightWaiters {
            waiters.append(completion)
            inFlightWaiters = waiters
            return
        }
        inFlightWaiters = [completion]

        var request = URLRequest(url: contentURL)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 30

        URLSession.shared.dataTask(with: request) { data, _, error in
            let waiters = inFlightWaiters ?? []
            inFlightWaiters = nil

            guard error == nil,
                  let data = data,
                  let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async {
                    waiters.forEach { $0(false) }
                }
                return
            }

            cachedRoot = root
            parseRoutines(from: root)
            parseStretches(from: root)

            DispatchQueue.main.async {
                waiters.forEach { $0(true) }
            }
        }.resume()
    }

    private static func parseRoutines(from root: [String: Any]) {
        routines = []
        guard let routinesDict = root["Routines"] as? [String: Any] else { return }

        for name in routinesDict.keys.sorted() {
            guard let value = routinesDict[name] as? [String: Any],
                  let stretchKeys = value["Stretches"] as? [String],
                  let imageUrl = value["downloadURL"] as? String else { continue }
            routines.append(Routine(stretchKeys: stretchKeys, imageURL: imageUrl, name: name))
        }
    }

    private static func parseStretches(from root: [String: Any]) {
        stretches = []
        guard let stretchesDict = root["Stretches"] as? [String: Any] else { return }

        for name in stretchesDict.keys.sorted() {
            guard let value = stretchesDict[name] as? [String: Any],
                  let instruction = value["instructions"] as? String,
                  let imageUrl = value["downloadURL"] as? String else { continue }
            let time = (value["time"] as? Int)
                ?? (value["time"] as? NSNumber)?.intValue
                ?? 30
            stretches.append(
                Stretch(name: name, instructions: instruction, time: time, key: name, imageURL: imageUrl)
            )
        }
    }

    static func getRoutines(callback: @escaping (_ success: Bool) -> ()) {
        loadContent { success in
            callback(success)
        }
    }

    public static func getStretches(callback: @escaping (_ success: Bool) -> ()) {
        loadContent { success in
            callback(success)
        }
    }

    public static func getDateUpdated(callback: @escaping (_ date: String) -> ()) {
        loadContent { success in
            let date = (cachedRoot?["Updated"] as? String) ?? "00/00/0000"
            callback(success ? date : "00/00/0000")
        }
    }
}
