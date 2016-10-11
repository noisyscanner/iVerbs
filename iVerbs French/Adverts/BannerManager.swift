//
//  BannerManager.swift
//  iVerbs
//
//  Created by Brad Reed on 08/10/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import Foundation
import GoogleMobileAds

class BannerManager: NSObject, GADBannerViewDelegate {
    var bannerView: GADBannerView = GADBannerView()
    
    static let shared = BannerManager()
    
    override init() {
//        banner.rootViewController = self
        super.init()
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.delegate = self
        
        let request: GADRequest = GADRequest()
        request.testDevices = ["cd8fbfc74425189d3c4e7cb7ff317690"] // My iPhone
        bannerView.load(request)
    }
    
    func setupBannerAds(viewController: UIViewController, container: UIView) -> GADBannerView {
//        let view = viewController.view!
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.rootViewController = viewController
        
        bannerView.frame.origin = CGPoint(x: 0, y: 0)
        container.addSubview(bannerView)
        container.hideView()
//        view.addSubview(bannerView)
        
        /*let widthConstraint = NSLayoutConstraint(item: bannerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
        view.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: bannerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        view.addConstraint(heightConstraint)
        
        let horizontalConstraint = NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        
        let bottomConstraint = NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint)
        
        let c = NSLayoutConstraint(item: sibling, attribute: .bottom, relatedBy: .equal, toItem: bannerView, attribute: .top, multiplier: 1, constant: 0)
        c.priority = 1000
        view.addConstraint(c)*/
        
//        bannerView.hideView() // hidden by default
        
        return bannerView
    }
    
    // MARK: - GADBannerViewDelegate
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        print("adViewDidReceiveAd: Banner loaded")
        guard let container = bannerView.superview else { return }
        
        if container.isHidden {
            container.alpha = 0
            container.showView()
            
            UIView.animate(withDuration: 1, animations: {
                container.alpha = 1
            })
        }
    }
    
    /*// Tells the delegate an ad request failed.
     func adView(bannerView: GADBannerView!,
     didFailToReceiveAdWithError error: GADRequestError!) {
     print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
     }
     
     /// Tells the delegate that a full screen view will be presented in response
     /// to the user clicking on an ad.
     func adViewWillPresentScreen(bannerView: GADBannerView!) {
     print("adViewWillPresentScreen")
     }
     
     /// Tells the delegate that the full screen view will be dismissed.
     func adViewWillDismissScreen(bannerView: GADBannerView!) {
     print("adViewWillDismissScreen")
     }
     
     /// Tells the delegate that the full screen view has been dismissed.
     func adViewDidDismissScreen(bannerView: GADBannerView!) {
     print("adViewDidDismissScreen")
     }
     
     /// Tells the delegate that a user click will open another app (such as
     /// the App Store), backgrounding the current app.
     func adViewWillLeaveApplication(bannerView: GADBannerView!) {
     print("adViewWillLeaveApplication")
     }*/
    
}
