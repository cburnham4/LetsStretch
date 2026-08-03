//
//  AdBannerHelper.swift
//  LetsStretch
//

import UIKit
import GoogleMobileAds

enum AdUnits {
    static let homeBanner = "ca-app-pub-8223005482588566/6902691958"
    static let stretchBanner = "ca-app-pub-8223005482588566/2963446943"
}

extension UIViewController {
    /// Creates a programmatic BannerView inside a storyboard container.
    /// GoogleMobileAds.BannerView cannot be reliably instantiated from Interface Builder.
    @discardableResult
    func installBannerAd(
        in container: UIView?,
        adUnitID: String,
        delegate: BannerViewDelegate? = nil
    ) -> BannerView? {
        guard let container else {
            print("Ad banner container outlet is nil")
            return nil
        }

        container.subviews.forEach { $0.removeFromSuperview() }
        container.backgroundColor = .clear

        let width = max(container.bounds.width, view.bounds.width, 320)
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: width)
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = adUnitID
        banner.rootViewController = self
        banner.delegate = delegate
        banner.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            banner.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            banner.widthAnchor.constraint(equalToConstant: adSize.size.width),
            banner.heightAnchor.constraint(equalToConstant: adSize.size.height)
        ])

        banner.load(Request())
        return banner
    }
}
