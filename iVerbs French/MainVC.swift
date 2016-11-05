//
//  MainVC.swift
//  iVerbs
//
//  Created by Brad Reed on 18/01/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

// Import package for the show/hide language list
import LGSideMenuController
import GoogleMobileAds

/*
 * This class is the container view for the verb list (VerbListController)
 * and the language list (LanguageSelectionVC) which can be shown by tapping
 * the globe icon in VerbListController's navigation bar,
 * or by swiping in from the left of the screen
 *
 * Functionality is provided by the 3rd party 'LGSideMenuController' CocoaPods package
 */
class MainVC: LGSideMenuController, GADBannerViewDelegate {
    
    var cview: UIView?
    var bannerView: GADBannerView?
    var bannerLoaded = false
    
    // The two contained view controllers
    var llvc: LanguageSelectionVC? // llvc is short for LanguageListViewController
    var vlc: VerbListController? // vlc is short for VerbListController
    
    // The navigation controller
    var nvc: UINavigationController?
    
    // MARK: Initialisation
    
    /* Initialise MainVC instance.
     *
     * PARAMS:
     * menuView: View Controller for Language List
     * splitViewController: Instance of UISplitViewController (this is the root view controller for the app)
     */
    init(menuView: UINavigationController, splitViewController: UISplitViewController) {
        
        // Call parent initialiser, passing splitViewController as the root view controller for the app
        super.init(rootViewController: splitViewController)
        
        // Add the banner to the bottom of the view
        insertBannerView()
        
        // Status bar fix
        self.leftViewStatusBarVisibleOptions = LGSideMenuStatusBarVisibleOptions.onAll
        self.leftViewStatusBarStyle = .lightContent
        
        // Set width of view
        menuView.view.frame.size.width = 300.0
        
        self.nvc = menuView
        self.llvc = menuView.viewControllers.first! as? LanguageSelectionVC
        
        // This lets LanguageSelectionVC access this class's methods and properties
        llvc!.delegate = self
        
        // Tell LGSideMenuController to enable the 'left view' - a hideable menu on the left
        // that can be shown by swiping from the left of the screen in the VerbListController
        // or tapping the globe icon
        setLeftViewEnabledWithWidth(
            300.0,
            presentationStyle: .slideAbove, // The animation and effect used to display the menu
            alwaysVisibleOptions: LGSideMenuAlwaysVisibleOptions()) // Menu should not be always visible on any device
        
        // Add the view of the language list view navigation controller to the container view
        self.leftView().addSubview(menuView.view)
        
        
        // Get the VerbListController (Verb List)...
        
        // NavigationController in storyboard, this precedes the VerbListController (Verb List)
        let nc = splitViewController.viewControllers.first as! UINavigationController
        let vlc = nc.viewControllers.first as! VerbListController
        
        // This allows us to get a reference to this MainVC instance from inside VerbListController
        vlc.delegate = self
        
        // Store the VerbListController instance as a property of this MainVC instance
        self.vlc = vlc
        
    }
    
    // The below two methods must be implemented
    // Since we don't really need to do anything, just call the super methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    // MARK: Showing and hiding language list
    
    // Show the language list
    func showLanguageList() {
        self.showLeftView(animated: true, completionHandler: nil)
    }
    
    // Hid the language list
    func hideLanguageList() {
        self.hideLeftView(animated: true, completionHandler: nil)
    }
    
    // MARK: - ADVERTS
    
    /**
     Add banner view to the bottom of the container
      UNLESS they have disabled them
     */
    func insertBannerView() {
        let product = Product.findBy(identifier: ProductRepo.DisableAds)
        
        // If the product has NOT been purchasaed, or does not exist, show the banner
        if !(product?.purchased ?? false) {
            // Ads not disabled, so create it and set it up
            
            bannerView = GADBannerView()
//            bannerView!.frame.origin.y = rootViewController.view.frame.size.height
            bannerView!.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            bannerView!.translatesAutoresizingMaskIntoConstraints = false
            bannerView!.adSize = kGADAdSizeSmartBannerPortrait
            bannerView!.rootViewController = self
            bannerView!.delegate = self
            
            // Request add for the banner
            let request: GADRequest = GADRequest()
            request.testDevices = ["cd8fbfc74425189d3c4e7cb7ff317690"] // My iPhone
            bannerView!.load(request)
            
            // Add to view
            view.addSubview(bannerView!)
            
            view.layoutSubviews()
        }
    }
    
    /**
     Remove banner view from superview
     */
    func removeBannerView() {
        if bannerView != nil {
            bannerView!.removeFromSuperview()
            bannerLoaded = false
            bannerView = nil
            
            // Update layout of other views now banner has been removed
            view.layoutSubviews()
        }
    }
    
    override func viewDidLayoutSubviews() {
        updatePositions()
    }
    
    func updatePositions() {
        var origin: CGFloat = 0
        
        if bannerView != nil {
            if bannerLoaded {
                // Resize rootViewController to height - 50
                origin = rootViewController.view.window!.frame.size.height - bannerView!.frame.size.height
                rootViewController.view.frame.size.height = origin
            } else {
                // No banner loaded (yet)
                rootViewController.view.frame.size.height = rootViewController.view.window!.frame.size.height
            }
            // Reposition and resize banner to be at bottom of rootViewController
            bannerView!.frame.origin.y = origin
            bannerView!.frame.size.width = rootViewController.view.frame.size.width
        }
    }
    
    // MARK: - GADBannerViewDelegate
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        print("adViewDidReceiveAd: Banner loaded")
        bannerLoaded = true
        updatePositions()
    }
}
