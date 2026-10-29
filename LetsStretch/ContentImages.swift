//
//  ContentImages.swift
//  LetsStretch
//
//  Resolves stretch/routine art from the app bundle first, with network as fallback.
//

import UIKit
import Kingfisher

enum ContentImages {

    /// Default art when a stretch/routine image is missing or fails to load.
    static var fallbackPlaceholder: UIImage? {
        UIImage(named: "standing_yoga_stretch")
    }

    /// Maps a remote content downloadURL to a file inside the bundled `content/` folder.
    /// Example remote path fragment `…/content/images/stretches/hamstring-left.png?v=…`
    /// → `Bundle…/content/images/stretches/hamstring-left.png`
    static func bundledFileURL(forRemoteURLString remote: String) -> URL? {
        guard let remoteURL = URL(string: remote) else { return nil }
        let path = remoteURL.path
        guard let marker = path.range(of: "/content/") else { return nil }
        let relative = String(path[marker.upperBound...])
        guard !relative.isEmpty else { return nil }

        let local = Bundle.main.bundleURL
            .appendingPathComponent("content", isDirectory: true)
            .appendingPathComponent(relative)
        return FileManager.default.fileExists(atPath: local.path) ? local : nil
    }

    static func bundledImage(forRemoteURLString remote: String) -> UIImage? {
        guard let url = bundledFileURL(forRemoteURLString: remote) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    /// Load into an image view: local bundle first, then optional Kingfisher network fetch.
    /// On total failure, shows `placeholder` (defaults to standing yoga art).
    static func load(
        into imageView: UIImageView,
        remoteURLString: String,
        placeholder: UIImage? = ContentImages.fallbackPlaceholder
    ) {
        imageView.kf.cancelDownloadTask()

        if let local = bundledImage(forRemoteURLString: remoteURLString) {
            imageView.image = local
            return
        }

        guard let url = URL(string: remoteURLString), !remoteURLString.isEmpty else {
            imageView.image = placeholder
            return
        }

        imageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.2))]
        ) { result in
            if case .failure = result {
                imageView.image = placeholder
            }
        }
    }
}
