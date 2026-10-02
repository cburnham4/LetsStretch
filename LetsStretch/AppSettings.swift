//
//  AppSettings.swift
//  LetsStretch
//

import Foundation

enum AppSettings {
    private static let restSecondsKey = "RestSecondsBetweenStretches"

    static let minRestSeconds = 1
    static let maxRestSeconds = 10
    static let defaultRestSeconds = 5

    /// Seconds to wait before each stretch starts (get-ready / transition time).
    static var restSecondsBetweenStretches: Int {
        get {
            let defaults = UserDefaults.standard
            if defaults.object(forKey: restSecondsKey) == nil {
                return defaultRestSeconds
            }
            let value = defaults.integer(forKey: restSecondsKey)
            return clamped(value)
        }
        set {
            UserDefaults.standard.set(clamped(newValue), forKey: restSecondsKey)
        }
    }

    private static func clamped(_ value: Int) -> Int {
        min(max(value, minRestSeconds), maxRestSeconds)
    }
}
