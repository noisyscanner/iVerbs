//
//  VerbListController.swift
//  iVerbs
//
//  Created by Brad Reed on 12/06/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import UIKit
import RealmSwift
import LGSideMenuController
import NightNight

// To identify whether the verb list
// is being sorted by Infinitive or English form
enum VerbListOrder {
    case infinitive
    case english
}

class VerbListController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating {
    
    // Language should always be set before the view appears on screen
    var language: Language? {
        // When the language is set, update the title of the view
        // If the language is not loaded, default to 'iVerbs'
        didSet {
            // Language.label for emoji support too! ☺️
            self.navigationItem.title = language?.label ?? "iVerbs"
        }
    }
    
    // Reference to the parent MainVC controller, 
    // so we can show and hide the Language List View from this controller
    var delegate: MainVC!
    
    // Search controller
    let searchController = UISearchController(searchResultsController: nil)
    
    // This will be populated with search results when the user is searching
    var filteredVerbs: Results<Verb>?
    
    var order = VerbListOrder.infinitive // Default order
    
    // Return true if the user is currently searching, else false
    var userIsSearching: Bool {
        return searchController.isActive && searchController.searchBar.text != ""
    }
    
    // For sectioning the table view
    let collation = UILocalizedIndexedCollation.current() as UILocalizedIndexedCollation
    
    var sections: [Section] {
        // return if already initialized
        if _sections != nil {
            return self._sections!
        }
        
        if language == nil {
            return []
        }
        
        // Get the sort order
        let sortSelector = Selector(order == .infinitive ? "sortNormalisedInfinitive" : "sortEnglish")
        
        // Find each verb's section
        let sortedVerbs: [Verb] = language!.verbs.map { verb in
            verb.section = self.collation.section(for: verb, collationStringSelector: sortSelector)
            return verb
        }
        
        // Create sections array and fill it with empty sections
        var sections = [Section]()
        for _ in 0..<self.collation.sectionIndexTitles.count {
            sections.append(Section())
        }
        
        // put each verb in a section
        for verb in sortedVerbs {
            sections[verb.section!].addVerb(verb)
        }
        
        // sort each section alphabetically
        _sections = sections.enumerated().map { (index, section) in
            var newSection = section
            newSection.verbs = self.collation.sortedArray(from: section.verbs, collationStringSelector: sortSelector) as! [Verb]
            newSection.title = self.collation.sectionTitles[index]
            
            return newSection
        }
        
        
        // If the user has favourite verbs, show these at the top
        if language!.favouriteVerbs.count > 0 {
            insertFavouritesSection()
        }
        
        return _sections!
        
    }
    var _sections: [Section]?
    
    // Add favourites section to top of table view
    fileprivate func insertFavouritesSection() {
        if _sections != nil {
            var favouriteSection = Section()
            favouriteSection.title = "♡"
            favouriteSection.verbs = Array(language!.favouriteVerbs) // TODO: this seems bait
            
            _sections!.insert(favouriteSection, at: 0)
        }
    }

    // Required to implement this
    // No need to override default behaviour so call super
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        // Night mode colours
        let mixedbg = MixedColor(normal: UIColor.groupTableViewBackground, night: iVerbs.Colour.dark)
        view.mixedBackgroundColor = mixedbg
        tableView.mixedBackgroundColor = mixedbg
        tableView.mixedSeparatorColor = MixedColor(normal: iVerbs.Colour.lightSep, night: iVerbs.Colour.darkSep)
        navigationController?.navigationBar.mixedBarTintColor = MixedColor(normal: iVerbs.Colour.lightBlue, night: iVerbs.Colour.darkBlue)
        searchController.searchBar.mixedBarTintColor = MixedColor(normal: iVerbs.Colour.lightBlue, night: iVerbs.Colour.darkBlue)
        
        searchController.searchBar.mixedKeyboardAppearance = MixedKeyboardAppearance(normal: .light, night: .dark)
        
        
        tableView.tintColor = iVerbs.Colour.lightBlue
        tableView.sectionIndexBackgroundColor = UIColor.black
        
        // Set up search controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        
        
//        reloadLanguage()
    }

    override func viewWillAppear(_ animated: Bool) {
//        tableView.clearsSelectionOnViewWillAppear = self.splitViewController?.collapsed ?? true
        
        reloadLanguage()
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // If a language hass not been loaded yet...
        if language == nil {
            // If only one language is installed, load that by default
            // Otherwise, show the language selector
            
            let installedLangs = Language.installedLanguages
            if installedLangs.count == 1 {
                loadLanguage(installedLangs.first)
            } else {
                self.delegate?.showLeftView(animated: true, completionHandler: nil)
            }
        }
    }
    
    func loadLanguage(_ language: Language?) {
        self.language = language
        self.reloadLanguage()
    }
    
    func reloadLanguage() {
        _sections = nil // Force sections to be re-loaded
        tableView.reloadData()
    }
    
    // MARK: IBActions

    // Switch the verb list ordering. Order by Infinitive or English translation
    @IBAction func reorderVerbs(_ sender: UIBarButtonItem) {
        // Reorder the verb list (flip it, essentially)
        order = (order == .infinitive) ? .english : .infinitive
        
        reloadLanguage()
        
        tableView.reloadSectionIndexTitles()
    }

    // Open the language seletion list by tapping the globe icon
    @IBAction func didTapGlobe(_ sender: UIBarButtonItem) {
        self.delegate.showLeftView(animated: true, completionHandler: nil)
    }
    

    // MARK: Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVerb" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let verb: Verb
                if userIsSearching {
                    verb = filteredVerbs![indexPath.row]
                } else {
                    verb = getVerbAtIndexPath(indexPath)
                }
                
                let controller = (segue.destination as! UINavigationController).topViewController as! VerbDetailController
                controller.verb = verb
                
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true

                
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        if userIsSearching {
            return 1
        }
        
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userIsSearching {
            return filteredVerbs!.count
        }
        
        return self.sections[section].verbs.count
    }
    
    // section headers: appear above each `UITableView` section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // do not display empty sections
        if !userIsSearching {
            let section = self.sections[section]
            if section.verbs.count > 0 {
                return section.title
            }
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let v = view as! UITableViewHeaderFooterView
        v.backgroundView?.mixedBackgroundColor = MixedColor(normal: UIColor.groupTableViewBackground, night: iVerbs.Colour.darkTable)
        v.textLabel?.mixedTextColor = MixedColor(normal: UIColor.darkText, night: UIColor.lightText)
    }
    
    /*func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }*/
    
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if userIsSearching {
            return 0
        }
        
        return self.collation.section(forSectionIndexTitle: index)
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if userIsSearching {
            return nil
        }
        
        return self.collation.sectionIndexTitles
    }
    
    // Get the cell instance
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VerbCell", for: indexPath) as! VerbListCell
        cell.language = language

        let verb: Verb
        if userIsSearching {
            verb = filteredVerbs![indexPath.row]
        } else {
            verb = getVerbAtIndexPath(indexPath)
        }

        if order == .infinitive {
            cell.textLabel!.text = verb.infinitive
            cell.detailTextLabel!.text = verb.english
        } else {
            cell.detailTextLabel!.text = verb.infinitive
            cell.textLabel!.text = verb.english
        }
        
        return cell
    }
    
    // Called when the user taps a verb in the list
    /*override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "showVerb", sender: tableView.cellForRow(at: indexPath))
    }*/

    // Verbs may not be deleted from the list
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Should show menu for 'Speak' and 'Copy' actions
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return (action == #selector(SpeakingCell.copy(_:)) || action == #selector(SpeakingCell.copy(_:)))
    }
    
    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        // empty function - doesn't need to do anything, just needs to be defined
    }
    
    func getVerbAtIndexPath(_ indexPath: IndexPath) -> Verb {
        return sections[indexPath.section].verbs[indexPath.row]
    }
    
    // MARK: Searching
    
    func filterVerbsForSearchText(_ searchText: String) {
        if (language != nil) {
            let noAccents = searchText.folding(options: .diacriticInsensitive, locale: language!.nsLocale)
            filteredVerbs = language!.searchVerbs(noAccents)
        }
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterVerbsForSearchText(searchController.searchBar.text!)
    }
    
    
}
