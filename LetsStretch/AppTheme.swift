//
//  AppTheme.swift
//  LetsStretch
//

import UIKit

enum AppTheme {
    static let background = UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1) // warm off-white
    static let surface = UIColor.white
    static let ink = UIColor(red: 0.14, green: 0.13, blue: 0.12, alpha: 1)
    static let inkSecondary = UIColor(red: 0.40, green: 0.37, blue: 0.34, alpha: 1)
    static let accent = UIColor(red: 0.91, green: 0.42, blue: 0.20, alpha: 1) // coral-orange
    static let accentSoft = UIColor(red: 0.95, green: 0.86, blue: 0.78, alpha: 1)
    static let separator = UIColor(red: 0.90, green: 0.87, blue: 0.83, alpha: 1)

    static func applyGlobalAppearance() {
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = background
        nav.titleTextAttributes = [
            .foregroundColor: ink,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        nav.largeTitleTextAttributes = [
            .foregroundColor: ink,
            .font: UIFont.systemFont(ofSize: 28, weight: .bold)
        ]
        nav.shadowColor = .clear

        let navBar = UINavigationBar.appearance()
        navBar.standardAppearance = nav
        navBar.scrollEdgeAppearance = nav
        navBar.compactAppearance = nav
        navBar.tintColor = accent

        UITableView.appearance().backgroundColor = background
        UITableViewCell.appearance().backgroundColor = .clear
    }

    /// Maps routine names to bundled asset names.
    static func routineIconName(for routineName: String) -> String? {
        switch routineName {
        case "Back Stretches": return "routine_back"
        case "Full Body": return "routine_full_body"
        case "Leg Stretches": return "routine_legs"
        case "Morning Stretches": return "routine_morning"
        case "Desk Reset": return "routine_desk"
        case "Calf & Achilles": return "routine_calf"
        default: return nil
        }
    }
}
