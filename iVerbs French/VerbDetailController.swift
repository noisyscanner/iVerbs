//
//  VerbDetailController.swift
//  iVerbs
//
//  Created by Brad Reed on 12/06/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import UIKit
import NightNight

class VerbDetailController: UITableViewController {

//    let bannerManager = BannerManager.shared
    
    // Heart button used to add verbs to favoruties list
    @IBOutlet weak var btnFavourite: UIBarButtonItem!
    
    // Two icon states for heart button
    let icnIsFave  = UIImage(named: "heartfilled")
    let icnNotFave = UIImage(named: "heartempty")
    
    override func viewDidLoad() {
        tableView.mixedBackgroundColor = MixedColor(normal: UIColor.groupTableViewBackground, night: iVerbs.Colour.dark)
        tableView.mixedSeparatorColor = MixedColor(normal: iVerbs.Colour.lightSep, night: iVerbs.Colour.darkSep)
        navigationController?.navigationBar.mixedBarTintColor = MixedColor(normal: iVerbs.colour, night: iVerbs.Colour.darkBlue)
        if let lblEnglish = self.tableView.tableHeaderView as? UILabel {
            lblEnglish.mixedTextColor = MixedColor(normal: UIColor.darkText, night: UIColor.lightText)
        }
        
    }
    
    // The verb that the view is displaying
    var verb: Verb? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    // MARK: Initialisation
    
    /*override func viewDidLoad() {
        bannerManager.setupBannerAds(viewController: self, sibling: tableView)
    }*/
    
    // Update the table to display the verb
    func configureView() {
        if verb != nil {
            self.navigationItem.title = verb!.infinitive
            if let lblEnglish = self.tableView.tableHeaderView as? UILabel {
                lblEnglish.text = verb!.english
            }
        }

        
        // Update 'Favourite' Bar button item
        updateFavouriteBtn()
        
        // Refresh table to show new verb data
        self.tableView.reloadData()
    }
    
    // MARK: - Table View Delegate
    
    /// Returns the number of sections in the table view
    /// AKA: The number of tenses in a language
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of tenses if the verb is set and 
        // the Language has been loaded properly...
        if verb != nil {
            return verb!.language.tenses.count
        }
        
        // By default we return 1
        // This one section will have an error message as the header
        // See tableView: titleForHeaderInSection:
        return 1
    }
    
    /// Returns the number of rows in a given section,
    /// AKA - the count of conjugations for this tense
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if verb != nil {
            if let tense = verb!.language.tenseForSection(section) {
                return verb!.conjugations.filter("tense_id = \(tense.id)").count
            }
        }
        
        return 0
    }
    
    /// Returns the title for a given section
    ///
    /// `tense.displayName`
    ///
    /// - returns: String
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if verb != nil {
            if let tense = verb!.language.tenseForSection(section) {
                return tense.displayName
            }
        }
        
        // By default return an message telling users to select a verb
        // iPad users will see this when they launch the app, as this 
        // 'Detail View' is already visible
        //
        // This will be showed to the user when the language or verb was not loaded
        return section == 0 ? "Select a verb" : ""
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create the cell, cast to SpeakingCell to allow it to be spoken
        let cell = tableView.dequeueReusableCell(withIdentifier: "VerbCell", for: indexPath) as! SpeakingCell
        
        // Set the cell's language, so it knows which language to speak the word in
        cell.language = verb!.language
        
        let pronoun = pronounForRowAtIndexPath(indexPath) // Get the pronoun
        let conjugation = conjugationForRowAtIndexPath(indexPath) // Get the relevant conjugated form
        let displayPronoun = pronoun?.displayNameForConjugation(conjugation) // Correctly formatted pronoun
        
        cell.textLabel!.text = displayPronoun // Left text
        cell.detailTextLabel!.text = conjugation?.conjugation // Right text
        
        
        // Show a chevron (>) on the "Passe Compose" row, indicating it can be tapped
        if pronoun?.identifier == "aux" && !verb!.isHelper {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let pronoun = pronounForRowAtIndexPath(indexPath) {
            
            if pronoun.identifier == "aux" && !verb!.isHelper {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                let vc = storyboard.instantiateViewController(withIdentifier: "VerbDetailController") as! VerbDetailController
                vc.verb = verb!.helper
                
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                // Speak the conjugation
                if let conjugation = conjugationForRowAtIndexPath(indexPath) {
                    conjugation.speak {
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                }
            }
        }
    }
    
    /*override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let pronoun = pronounForRowAtIndexPath(indexPath)
        if pronoun?.identifier == "aux" && !verb!.isHelper {
            return indexPath
        }
        return nil
    }*/
    
    // Cells cannot be edited
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Should show menu for 'Speak' and 'Copy' actions
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return (action == #selector(SpeakingCell.copyText(_:)) || action == #selector(SpeakingCell.speak(_:)))
    }
    
    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        // empty function - doesn't need to do anything, just needs to be defined
    }
    
    // MARK: - Cells
    
    // Get the pronoun for a given row in the table
    func pronounForRowAtIndexPath(_ indexPath: IndexPath) -> Pronoun? {
        if let tense = verb!.language.tenseForSection((indexPath as NSIndexPath).section) {
            
            // get conjugations for this tense in order
            // get list of pronouns,
            
            let conjugations = verb!.conjugations.filter("tense_id = \(tense.id)")
            let sorted = conjugations.sorted { $0.pronoun.order < $1.pronoun.order  }
            let pronoun_id = sorted[(indexPath as NSIndexPath).row].pronoun_id
            
            return verb!.language.pronouns.filter("id = \(pronoun_id)").first
        }
        return nil // Tense was not found
    }
    
    // Get the conjugation for the given row
    func conjugationForRowAtIndexPath(_ indexPath: IndexPath) -> Conjugation? {
        if let pronoun = pronounForRowAtIndexPath(indexPath) {
            if let tense = verb!.language.tenseForSection((indexPath as NSIndexPath).section) {
                return verb!.conjugations.filter("tense_id = \(tense.id) AND pronoun_id = \(pronoun.id)").first
            }
        }
        
        return nil
    }
    
    
    // MARK: IBActions
    
    @IBAction func didClickFavouriteButton(_ sender: UIBarButtonItem) {
        if verb != nil {
            // Update bar button
            updateFavouriteBtn(true)
            
            // Mark or unmark the verb as favourite
            verb!.toggleFavourite() {
                // Update MasterViewControlller (Verb List)
                let nc = self.splitViewController?.viewControllers.first as? UINavigationController
                let vlc = nc?.viewControllers.first as? VerbListController
                vlc?.reloadLanguage()
            }
        }
    }
    
    
    @IBAction func didClickSpeakButton(_ sender: UIBarButtonItem) {
        if verb != nil {
            // Speak verb
            let speaker = Speaker(language: verb!.language)
            speaker.speak(verb!.infinitive)
        }
    }
    
    
    
    
    // Update the state of the 'Favourite' button
    fileprivate func updateFavouriteBtn(_ inverse: Bool = false) {
        if verb != nil {
            var condition = verb!.favourite // true if the verb has been 'favourited'
            
            // When the user taps the button, this method is called with the 'inverse'
            // option to 'flip' the polarity of the button, BEFORE updating it in the database
            //
            // This is because updating the database could be slower than
            if inverse {
                condition = !condition
            }
            
            btnFavourite.image = condition ? icnIsFave : icnNotFave
        }
    }
    

}

