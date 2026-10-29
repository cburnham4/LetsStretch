//
//  APIRequests.swift
//  LetsStretch
//
//  Created by Carl Burnham on 8/5/17.
//  Copyright © 2017 Carl Burnham. All rights reserved.
//

import Foundation

class APIRequests {

    /// Static content hosted in this repo (optional refresh; app ships a bundled copy).
    static let contentURL = URL(string:
        "https://raw.githubusercontent.com/cburnham4/LetsStretch/master/content/data/content.json"
    )!

    static var routines = [Routine]()
    static var stretches = [Stretch]()

    private static var cachedRoot: [String: Any]?
    private static var inFlightWaiters: [(Bool) -> Void]?

    // MARK: - Bundled defaults

    /// `content/data/content.json` copied into the app bundle via the `content` folder reference.
    static func loadBundledRoot() -> [String: Any]? {
        let candidates: [URL?] = [
            Bundle.main.url(forResource: "content", withExtension: "json", subdirectory: "content/data"),
            Bundle.main.bundleURL
                .appendingPathComponent("content/data/content.json", isDirectory: false)
        ]
        for candidate in candidates {
            guard let url = candidate,
                  FileManager.default.fileExists(atPath: url.path),
                  let data = try? Data(contentsOf: url),
                  let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                continue
            }
            return root
        }
        return nil
    }

    private static func applyRoot(_ root: [String: Any]) {
        cachedRoot = root
        parseRoutines(from: root)
        parseStretches(from: root)
    }

    /// Ensures routines/stretches are available without the network.
    /// Prefers previously archived UserDefaults data, then the bundled content.json.
    @discardableResult
    static func ensureSeededContent() -> Bool {
        if !routines.isEmpty && !stretches.isEmpty {
            return true
        }

        let savedRoutines = Utils.getSavedRoutines()
        let savedStretches = Utils.getSavedStretches()
        if !savedRoutines.isEmpty && !savedStretches.isEmpty {
            routines = savedRoutines
            stretches = savedStretches
            return true
        }

        if let root = loadBundledRoot() {
            applyRoot(root)
            return !routines.isEmpty
        }
        return false
    }

    /// Persist current in-memory content for next cold start.
    static func archiveCurrentContent() {
        let defaults = UserDefaults.standard
        let routinesData = NSKeyedArchiver.archivedData(withRootObject: routines)
        let stretchesData = NSKeyedArchiver.archivedData(withRootObject: stretches)
        defaults.set(routinesData, forKey: "SavedRoutines")
        defaults.set(stretchesData, forKey: "SavedStretches")
        if let updated = cachedRoot?["Updated"] as? String {
            defaults.setValue(updated, forKey: "DateUpdated")
        }
    }

    // MARK: - Network (optional refresh)

    /// Fetches (or reuses) the shared content.json payload.
    /// On network failure, falls back to bundled JSON so callers still get content.
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

            if error == nil,
               let data = data,
               let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                applyRoot(root)
                DispatchQueue.main.async {
                    waiters.forEach { $0(true) }
                }
                return
            }

            // Network failed — keep / seed offline content rather than going blank.
            let seeded: Bool
            if cachedRoot != nil || (!routines.isEmpty && !stretches.isEmpty) {
                seeded = true
            } else if let bundled = loadBundledRoot() {
                applyRoot(bundled)
                seeded = !routines.isEmpty
            } else {
                seeded = ensureSeededContent()
            }

            DispatchQueue.main.async {
                waiters.forEach { $0(seeded) }
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
        // Always attempt network so bundled seeding does not block optional refresh.
        loadContent(forceRefresh: true) { _ in
            if let date = cachedRoot?["Updated"] as? String {
                callback(date)
                return
            }
            if let bundled = loadBundledRoot(), let date = bundled["Updated"] as? String {
                if routines.isEmpty || stretches.isEmpty {
                    applyRoot(bundled)
                }
                callback(date)
                return
            }
            callback("00/00/0000")
        }
    }
}
