//
//  MainVC.swift
//  iVerbs
//
//  Created by Brad Reed on 18/01/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

// Import package for the show/hide language list
import LGSideMenuController

/*
 * This class is the container view for the verb list (VerbListController)
 * and the language list (LanguageSelectionVC) which can be shown by tapping
 * the globe icon in VerbListController's navigation bar,
 * or by swiping in from the left of the screen
 *
 * Functionality is provided by the 3rd party 'LGSideMenuController' CocoaPods package
 */
class MainVC: LGSideMenuController {
    
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
}
