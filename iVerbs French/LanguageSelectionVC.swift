//
//  LanguageSelectionVC.swift
//  iVerbs
//
//  Created by Brad Reed on 30/12/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import UIKit
import SCLAlertView
import NightNight

/**
 * View controller to manage the 'language selection' view,
 * which can be shown by tapping the globe icon or swiping
 * onto the screen from the left when the verb list is on screen
 */
class LanguageSelectionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var langList: UITableView! // Language list table view
    @IBOutlet weak var btnEdit: UIBarButtonItem! // 'Edit' button at bottom of table view
    
    // Reference to the containing MainVC instance
    var delegate: MainVC?
    
    // The refresh control used when a user pulls down the table view to refresh it
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(LanguageSelectionVC.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = iVerbs.Colour.lightBlue
        
        return refreshControl
    }()
    
    // Called when the view loads, before it comes on screen
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up night mode colours
        self.navigationController?.navigationBar.mixedBarTintColor = MixedColor(normal: iVerbs.Colour.lightBlue, night: iVerbs.Colour.darkNav)
        langList.mixedBackgroundColor = MixedColor(normal: UIColor.white, night: iVerbs.Colour.dark)
        langList.mixedSeparatorColor = MixedColor(normal: iVerbs.Colour.lightSep, night: iVerbs.Colour.darkSep)
        
        // Add the refresh control to the language list table view
        self.langList.addSubview(self.refreshControl)
        
        checkForUpdates()
    }
    
    // Check for updates - update the local language cache
    fileprivate func checkForUpdates() {
        LanguageManager.cacheAvailableLanguages { _ in
            let outdatedLanguages = Language.outdatedLanguages
            
            if outdatedLanguages.count > 0 {
                self.langList.reloadData()
                
                let alert = SCLAlertView()
                
//                alert.showCloseButton = true
                
                let _ = alert.addButton("Update", target:self, selector:#selector(LanguageSelectionVC.updateAll))
                
                let _ = alert.showInfo("Updates Available",
                    subTitle: "One or more languages have updates available for download",
                    closeButtonTitle: "Dismiss",
                    duration: 0,
                    colorStyle: 0x123456,
                    colorTextButton: 0xFFFFFF)
            }
        }
    }
    
    /*
     * Called when the user taps 'Update All'.
     * Update all languages that need it, complete with cell animations
     */
    func updateAll() {
        // Get list of cells visible on screen
        let cells = langList.visibleCells as! [LanguageListCell]
        
        for language in Language.outdatedLanguages {
            
            // Get cell instance for the given language (optional)
            let cell = cells.filter { cell in
                return cell.language == language
            }.first
            
            // If the cell was found, start its loading animation
            if cell != nil {
                cell!.startAnimatingRow()
            }
            
            // Update the language
            language.downloadNewVerbs { _ in
                // Language updated, stop animations on cell and update state
                if cell != nil {
                    cell!.updateCell()
                    cell!.stopAnimatingRow()
                }
            }
        }
    }
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return Language.installedLanguages.count
        case 1:
            return Language.availableLanguages.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Language.availableLanguages.count > 0 ? 2 : 1;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Installed"
        case 1:
            return "Available for Download"
        default:
            return nil
        }
    }
    
    // Add night mode runctionality to the header view before it is displayed
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let v = view as! UITableViewHeaderFooterView
        v.textLabel?.mixedTextColor = MixedColor(normal: UIColor.darkText, night: UIColor.white)
        v.backgroundView?.mixedBackgroundColor = MixedColor(normal: UIColor.groupTableViewBackground, night: iVerbs.Colour.darkTable)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "langCell", for: indexPath) as! LanguageListCell
        
        let language = languageForIndexPath(indexPath)
        cell.language = language
        
        cell.btnUpdate.addTarget(self, action: #selector(LanguageSelectionVC.didTapUpdate(_:)), for: .touchUpInside)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Get language
        let language = languageForIndexPath(indexPath)
        
        // If the language that the cell is displaying is installed, return false
        // Otherwise return false
        return language.installed 
    }
    
    // Return if the row can be tapped (if the language is installed)
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let language = languageForIndexPath(indexPath)
        return language.installed ? indexPath : nil // If the language is installed it can be tapped
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = languageForIndexPath(indexPath)
        
        if language.installed {
            delegate?.vlc?.loadLanguage(language)
            delegate?.hideLanguageList()
        }
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        // Get the relevant language
        let language = languageForIndexPath(indexPath)
        
        // If the language is installed, show a delete button. Otherwise nothing.
        return language.installed ? .delete : .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete language
            let language = languageForIndexPath(indexPath)
            language.uninstall {
                if language == self.delegate?.vlc?.language {
                    // Language was loaded, unload it
                    self.delegate?.vlc?.loadLanguage(nil)
                }
                
                self.reloadAllSections()
                if self.numberOfSections(in: tableView) <= 1 {
                    self.stopEditing()
                }
                
                print("Language uninstalled: ", language.language)
            }
        }
    }
    
    
    @IBAction func didTapEdit(_ sender: UIBarButtonItem) {
        if langList.isEditing {
            stopEditing()
        } else {
            startEditing()
        }
    }
    
    func startEditing() {
        btnEdit.title = "Done"
        langList.setEditing(true, animated: true)
    }
    
    func stopEditing() {
        btnEdit.title = "Edit"
        langList.setEditing(false, animated: true)
    }
    
    func didTapUpdate(_ sender: UIButton) {
        let cell = sender.superview?.superview as! LanguageListCell
        let language = cell.language
        
        if language != nil {
            cell.startAnimatingRow()
            
            if language!.installed {
                // Update language
                language!.downloadNewVerbs { error in
                    if error == nil {
                        print("Language updated: ", language!.language)
                        
                    } else {
                        let title = "Error updating language"
                        iVerbs.displayError(title, message: error!.localizedDescription)
                        print(title, error!)
                    }
                    
                    cell.updateCell()
                    cell.stopAnimatingRow()
                }
            } else {
                // Install language
                language!.install { error in
                    if error == nil {
                        print("Language installed: ", language!.language)
                        
                    } else {
                        let title = "Error installing language"
                        iVerbs.displayError(title, message: error!.localizedDescription)
                        print(title, error!)
                    }
                    
                    cell.updateCell()
                    cell.stopAnimatingRow()

                    self.reloadAllSections()
                }
            }
        }

        
    }
    
    // MARK: Refreshing & Updating Table View
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        LanguageManager.cacheAvailableLanguages() { _ in
            self.langList.reloadData()
            refreshControl.endRefreshing()
        }
    }
    
    func reloadAllSections() {
        let oldNumSections = langList.numberOfSections
        let newNumSections = numberOfSections(in: langList)
        if oldNumSections == newNumSections {
            let range = NSMakeRange(0, newNumSections)
            let indexSet = IndexSet(integersIn: range.toRange() ?? 0..<0)
            langList.reloadSections(indexSet, with: .automatic)
        } else {
            langList.reloadData()
        }
    }
    
    
    // MARK: Model
    
    func languageForIndexPath(_ indexPath: IndexPath) -> Language {
        let languages = (indexPath as NSIndexPath).section == 0
            ? Language.installedLanguages
            : Language.availableLanguages
        
        return languages[(indexPath as NSIndexPath).row]
    }
    
    // MARK: Storyboard
    
    @IBAction func tapCog() {
        if let svc = storyboard?.instantiateViewController(withIdentifier: "settingsController") as? SettingsController {
            self.delegate?.nvc?.pushViewController(svc, animated: true)
        }
    }
    
}
