//
//  AppDelegate.swift
//  iVerbs French
//
//  Created by Brad Reed on 12/06/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import UIKit
import LGSideMenuController
import NightNight

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var splitViewController: UISplitViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        splitViewController = self.window!.rootViewController as? UISplitViewController
        splitViewController?.delegate = self
        splitViewController?.preferredDisplayMode = .allVisible

        UINavigationBar.appearance().mixedBarTintColor = MixedColor(normal: iVerbs.Colour.lightBlue, night: iVerbs.Colour.darkNav)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white
        ]
        
        let uibbi = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        uibbi.tintColor = UIColor.white
        
        // Add 'Speak' menu item
        let menu = UIMenuController.shared
        let speakaction = UIMenuItem(title: "Speak", action: #selector(SpeakingCell.speak(_:)))
        
        var newItems = menu.menuItems ?? [UIMenuItem]()
        newItems.append(speakaction)
        menu.menuItems = newItems
        
        if Language.noneInstalled { // No languages are installed
            
            // Show the setup storyboard
            let storyboard = UIStoryboard(name: "FirstLaunch", bundle: nil)
            let firstvc = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController")
            
            self.window!.makeKeyAndVisible()
            self.window!.rootViewController?.present(firstvc, animated: true, completion: nil)
            
        } else {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let langnc = storyboard.instantiateViewController(withIdentifier: "LanguageSelectionNC") as! UINavigationController
            
            let mainVC = MainVC(menuView: langnc, splitViewController: self.splitViewController!)
            
            self.window!.makeKeyAndVisible()
            self.window!.rootViewController = mainVC
            
        }
        
        if let nightMode = SettingManager.sharedInstance.get("night") {
            // Night mode setting exists
            NightNight.theme = nightMode.on ? .night : .normal
        } else {
            // Doesn't exist, default is normal theme
            NightNight.theme = .normal
        }
        
        return true
    }

    
    // MARK: Split View Controller
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? VerbDetailController else { return false }
        if topAsDetailController.verb == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    
}
