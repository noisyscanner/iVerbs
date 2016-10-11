//
//  FirstLanguagesVC.swift
//  iVerbs
//
//  Created by Brad Reed on 01/11/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import UIKit
import SCLAlertView
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class FirstLanguagesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var installedAll = false // Set to true when all languages are installed
    
    var alertView: SCLAlertView?
    var alertResponder: SCLAlertViewResponder?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnInstall: UIButton!
    
    // MARK: View
    override func viewDidLoad() {
//        self.tableView.allowsMultipleSelection = true
        
        // Give the 'Install' button a rounded corner style
        btnInstall.layer.cornerRadius = btnInstall.frame.size.height / 4
        btnInstall.clipsToBounds = true
    }
    
    // MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Language.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Only one section
        return "Available Languages"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the cell instance
        let cell = tableView.dequeueReusableCell(withIdentifier: "langCell", for: indexPath) as! iVerbsTintedCell
        
        let language = languageForRowAtIndexPath(indexPath)
        
        // Set the textLabel of the cell to the name of the language
        cell.textLabel!.text = language.language
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !installedAll {
            // Sort out the 'Install' button
            updateInstallBtn()
        }

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if !installedAll {
            // Update bar button
            updateInstallBtn()
        }

    }
    
    // MARK: Language Structure
    
    func languageForRowAtIndexPath(_ indexPath: IndexPath) -> Language {
        return Language.allLanguages[(indexPath as NSIndexPath).row]
    }
    
    // MARK: Navigation Bar and Buttons
    
    // Update the state of the 'Install' button to disable or enable it
    func updateInstallBtn() {
        if (tableView.indexPathsForSelectedRows?.count > 0) {
            btnInstall.isEnabled = true
        } else {
            btnInstall.isEnabled = false
        }
    }
    
    // User clicked 'Install'
    @IBAction func didClickInstall(_ sender: UIButton) {
        if (!installedAll) {
            btnInstall.isEnabled = false // Disable button
            btnInstall.setTitle("One Moment...", for: UIControlState())
            self.installSelectedLanguages()
        } else {
            // 'Continue' button
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let svc = appDelegate.splitViewController
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let langnc = storyboard.instantiateViewController(withIdentifier: "LanguageSelectionNC") as! UINavigationController
//            let langview = langnc.viewControllers.first! as! LanguageSelectionVC
            
            let mainVC = MainVC(menuView: langnc, splitViewController: svc!)
            
            // Fade new view onto screen
            UIView.transition(with: appDelegate.window!,
                duration: 0.5,
                options: UIViewAnimationOptions.transitionCrossDissolve,
                animations: { _ in
                    appDelegate.window?.rootViewController = mainVC
                },
                completion: nil)
            
        }
    }
    
    // MARK: Installation of languages
    
    func installSelectedLanguages() {
        let indexPaths = tableView.indexPathsForSelectedRows
        
        // If at least one language is selected...
        if indexPaths != nil {
            // Show loading alert
            showLoader()
            
            // Get array of selected languages: [Language]
            let selectedLanguages = indexPaths!.map { indexPath in
                return languageForRowAtIndexPath(indexPath)
            }
            
            // Get total languages count
            let total = selectedLanguages.count
            
            // Install languages
            LanguageManager.installLanguages(selectedLanguages) { count, error in
                
                // count is the number of successfully installed languages
                
                switch count {
                case 0:
                    // None were installed
                    self.showError("Could not install", subTitle: "Please check your Internet connection and try again.")
                    self.resetButton()
                case total:
                    // All installed
                    self.doneAllLanguages()
                default:
                    // One or more languages were installed, but not all
                    
                    // Show error alert to user
                    self.showError("Some languages could not be installed",
                        subTitle: "\(count) of \(total) languages were installed. Please try the others again later.")
                    
                    // Re-enable button and set title back to 'Install'
                    self.resetButton()
                }
            }
            
        }
    }
    
    func doneAllLanguages() {
        // All languages and verbs installed
        print("All Languages installed")
        
        // Show success alert
        showSuccess()
        
        installedAll = true
        btnInstall.setTitle("Continue", for: UIControlState())
        btnInstall.isEnabled = true
        tableView.reloadData()
    }
    
    fileprivate func resetButton() {
        btnInstall.setTitle("Install", for: UIControlState())
        btnInstall.isEnabled = true
    }
    
    // MARK: Alert views
    
    func showLoader() {
        if alertView != nil {
            dismissAlertView()
        }
        alertView = SCLAlertView()
//        alertView!.showCloseButton = false
        
        alertResponder = alertView!.showTitle(
            "One Moment Please",
            subTitle: "iVerbs is installing your chosen langugaes",
            duration: nil,
            completeText: nil,
            style: .wait,
            colorStyle: iVerbs.colour.toUInt(),
            colorTextButton: nil
        )
    }
    
    func showSuccess() {
        if alertView != nil {
            dismissAlertView()
        }
        alertView = SCLAlertView()
        alertResponder = alertView!.showSuccess("All Done",
            subTitle: "All selected languages have been downloaded and installed. Enjoy iVerbs!")
    }
    
    func showError(_ title: String, subTitle: String) {
        if alertView != nil {
            dismissAlertView()
        }
        
        alertView = SCLAlertView()
        alertResponder = alertView!.showError(title, subTitle: subTitle)
    }
    
    func dismissAlertView() {
        alertResponder?.close()
        alertResponder = nil
        alertView = nil
    }
    
}
