//
//  SettingsController.swift
//  iVerbs
//
//  Created by Brad Reed on 27/07/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import UIKit
import RealmSwift
import StoreKit
import SwiftSpinner
import NightNight

class SettingsController: UITableViewController, SettingsDelegate {
    
    var productRepo = ProductRepo()
    let manager = SettingManager()
    var links = ["iverbs.co.uk", "bradreed.co.uk"]
    
    
    /**
     * EXTRAS (self.products)
     * [Disable iAds    [Buy]  ]
     * [Restore Purchases      ]
     * [Enter Promo Code       ]
     *
     * SETTINGS (self.settings)
     * [ ( Night Mode    (O| ) ]
     */
    
    /* Needs to:
     * - Get price of "Disable iAds" from iTunes on viewDidLoad, retain
     * - Provide settings for:
         - Check for updates manual/auto
     * - Donate button
     * - Links to websites
     *
     */
    
    // MARK: View methods
    
    // Allows for dynamic row height
    override func viewDidLoad() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 55.0 // standard cell height
        
        // Night mode
        tableView.mixedBackgroundColor = MixedColor(normal: UIColor.groupTableViewBackground, night: iVerbs.Colour.darkTable)
        tableView.mixedSeparatorColor = MixedColor(normal: iVerbs.Colour.lightSep, night: iVerbs.Colour.darkSep)

        // Add refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(SettingsController.reloadPricing), for: .valueChanged)
        
        // Add notification center observers for the Disable Ads switch
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsController.purchased(_:)),
                                               name: NSNotification.Name(rawValue: StoreManager.StoreManagerPurchaseNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsController.failed(_:)),
                                               name: NSNotification.Name(rawValue: StoreManager.StoreManagerFailureNotification),
                                               object: nil)
        
        // Load settings and pricing info for disabling ads
        if (productRepo.products.count == 0) {
            reloadPricing()
        }
        
        // Finish old transactions
    }
    
    // MARK: Store Stuff
    
    // Reload the price of the "Disable Ads" setting
    func reloadPricing() {
        
        productRepo.refreshProducts { success, products in
            if success {
                self.tableView.reloadData()
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
    
    // Called when a purchase has been made
    func purchased(_ notification: Notification) {
        hideSpinner()
        
        // Hide the banner
        if let lvc = navigationController?.viewControllers.first as? LanguageSelectionVC {
            let mainVC = lvc.delegate
            mainVC?.removeBannerView()
        }
        
        
        showSpinner(text: "Purchase successful!\nThank you for supporting iVerbs.", interval: 1)
    }
    
    /**
     Called when a purchase failed
     Shows a "Purchase Failed" notice and optionally an error message
     Alert displays for 2 seconds, and then disappears before refreshing the table
    */
    func failed(_ notification: Notification) {
        var errorText = "Purchase Failed\n"
        if notification.object != nil {
            errorText += notification.object as! String
        }
        showSpinner(text: errorText, interval: 2)
        
        tableView.reloadData() // Updates switches, TODO: neccesary?
    }
    
    /// Shows a loading spinner overlaying the main view
    private func showSpinner(text: String) {
        SwiftSpinner.show(text)
    }
    
    // Show spinner for a given amount of time before hiding it
    private func showSpinner(text: String, interval: TimeInterval) {
        showSpinner(text: text)
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(hideSpinner), userInfo: nil, repeats: false)
    }
    
    @objc private func hideSpinner() {
        SwiftSpinner.hide()
    }

    
    // MARK: Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if productRepo.products.count > 0 {
            return 4
        } else {
            return 3 // No need for the IAP section
        }
        
        
        // Sections: "EXTRAS" (aka purchases), "Restore and Donate", "Settings", "Links"
        
//        return SettingManager.sharedInstance.groupCount
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of settings in a group
        switch section {
        case 0:
            // SECTION 1: EXTRAS
            return productRepo.products.count // Return number of purchasable products, or zero by default
        case 1:
            // SECTION 2: Restore purchases (and promo code TODO)
            return 1
        case 2:
            // SECTION 3: SETTINGS
            return manager.settings.count
        case 3:
            // SECTION 4: LINKS
            return links.count
        default:
            return 0
        }
//        return settings[section].settings.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Title for each setting group
        switch section {
        case 0:
            return productRepo.products.count > 0 ? "Support iVerbs" : nil
        case 1:
            return nil // No title
        case 2:
            return "Settings"
        default:
            return nil
        }

    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        // Add a copyright notice to the bottom of the last settings group
        if section == tableView.numberOfSections - 1 {
            // Last section
            return "(C) Brad Reed 2014 - 2016"
        }
        return nil
//        return settings[section].subTitle ?? nil
    }
    
    // Only allow the links to be selected
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.section != 2 ? indexPath : nil
    }
    
    // Get cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if indexPath.section == 0 {
            // Support iVerbs cells, AKA Disable Adverts
            let iadCell = tableView.dequeueReusableCell(withIdentifier: "IapSettingCell", for: indexPath) as! IapSettingCell
            
            // Extra iAd row setup
            iadCell.product = productRepo.products[indexPath.row]
            
            cell = iadCell
            
        } else if indexPath.section == 2 {
            // Settings
            
            let setting = self.tableView(tableView, settingForRowAtIndexPath: indexPath)
            var settingCell: SettingCell
            
            if setting?.identifier == "speechrate" {
                settingCell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath) as! SliderCell
            } else {
                settingCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            }
            
            
            settingCell.setting = setting
            cell = settingCell as! UITableViewCell
        } else {
            // Web links and the restore purchase thing
            cell = tableView.dequeueReusableCell(withIdentifier: "LinkCell", for: indexPath) as! iVerbsTintedCell
            
            if indexPath.section == 1 {
                // iap restore
                if indexPath.row == 0 {
                    // Restore purchases
                    cell.textLabel?.text = "Restore Purchases"
//                } else if indexPath.row == 1 {
                    // Promo code
                }
            } else if indexPath.section == 3 {
                // Web links
                cell.textLabel?.text = links[indexPath.row]
            }
            
        }
        
        
        return cell
    }
    
    // Open links at bottom, and handle restore purchases
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            // IAPs
            let product = productRepo.products[indexPath.row]
            showSpinner(text: "Buying\nPlease wait...")
            ProductRepo.store.buyProduct(productModel: product)
        case 1:
            // IAP restore
//            showSpinner(text: "Restoring\nPlease wait...")
//            ProductRepo.store.restorePurchases()
            if let lvc = navigationController?.viewControllers.first as? LanguageSelectionVC {
                let mainVC = lvc.delegate
                mainVC?.removeBannerView()
            }
        case 3:
            // Link cell
            let link = links[indexPath.row]
            if let url = URL(string: "http://" + link) {
                UIApplication.shared.openURL(url)
            }
        default:
            break
        }
        
    }
    
    // MARK: Setting switch delegate functions
    
    // Calls the delegate method for the correct cell when the control switched/changed
    @IBAction func didSwitchSetting(_ sender: AnyObject) {
        if let cell = sender.superview??.superview as? UITableViewCell {
            if let indexPath = tableView.indexPath(for: cell) {
                var value: Float = 0.0
                if sender is UISlider {
                    value = (sender as! UISlider).value
                    
                    let speaker = Speaker(locale: "en")
                    speaker.speechRate = value
                    speaker.speak("iVerbs")
                } else if sender is UISwitch {
                    value = sender.isOn! ? 1.0 : 0.0 // switch, boolean still stored as float
                }
                
                tableView(self.tableView, settingSwitchedAtIndexPath: indexPath, value: value)
            }
        }
    }
    
    
    
}
