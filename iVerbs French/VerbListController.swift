//
//  MasterViewController.swift
//  iVerbs
//
//  Created by Brad Reed on 12/06/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import UIKit
import RealmSwift
import LGSideMenuController

// To identify whether the verb list
// is being sorted by Infinitive or English form
enum VerbListOrder {
    case Infinitive
    case English
}

class MasterViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating {
    
    // Language should always be set before the view appears on screen
    var language: Language? {
        // When the language is set, update the title of the view
        // If the language is not loaded, default to 'iVerbs'
        didSet {
            self.navigationItem.title = language?.language ?? "iVerbs"
        }
    }
    
    // Reference to the parent MainVC controller, 
    // so we can show and hide the Language List View from this controller
    var delegate: MainVC!
    
    // Search controller
    let searchController = UISearchController(searchResultsController: nil)
    
    // This will be populated with search results when the user is searching
    var filteredVerbs: Results<Verb>?
    
    var order = VerbListOrder.Infinitive // Default order
    
    // Return true if the user is currently searching, else false
    var userIsSearching: Bool {
        return searchController.active && searchController.searchBar.text != ""
    }
    
    // For sectioning the table view
    let collation = UILocalizedIndexedCollation.currentCollation() as UILocalizedIndexedCollation
    
    var sections: [Section] {
        // return if already initialized
        if _sections != nil {
            return self._sections!
        }
        
        if language == nil {
            return []
        }
        
        // Get the sort order
        let sortSelector = Selector((order == .Infinitive) ? "sortNormalisedInfinitive" : "sortEnglish")
        
        // Find each verb's section
        let sortedVerbs: [Verb] = language!.verbs.map { verb in
            verb.section = self.collation.sectionForObject(verb, collationStringSelector: sortSelector)
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
        sections = sections.enumerate().map { (index, var section) in
            section.verbs = self.collation.sortedArrayFromArray(section.verbs, collationStringSelector: sortSelector) as! [Verb]
            section.title = self.collation.sectionTitles[index]
            
            return section
        }
        
        _sections = sections
        
        // If the user has favourite verbs, show these at the top
        if language!.favouriteVerbs.count > 0 {
            insertFavouritesSection()
        }
        
        return _sections!
        
    }
    var _sections: [Section]?
    
    // Add favourites section to top of table view
    private func insertFavouritesSection() {
        if _sections != nil {
            var favouriteSection = Section()
            favouriteSection.title = "♡"
            favouriteSection.verbs = Array(language!.favouriteVerbs)
            
            _sections!.insert(favouriteSection, atIndex: 0)
        }
    }
    
    // Initialise with Language
    init(language: Language?) {
        self.language = language
        super.init(nibName: "SearchController", bundle: NSBundle.mainBundle())
    }

    // Required to implement this
    // No need to override default behaviour so call super
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tintColor = iVerbs.colour
        
        // Set up search controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        reloadLanguage()
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController?.collapsed ?? true
        
        reloadLanguage()
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        // If a language hass not been loaded yet...
        if language == nil {
            // If only one language is installed, load that by default
            // Otherwise, show the language selector
            
            let installedLangs = Language.installedLanguages
            if installedLangs.count == 1 {
                loadLanguage(installedLangs.first)
            } else {
                self.delegate?.showLeftViewAnimated(true, completionHandler: nil)
            }
        }
    }
    
    func loadLanguage(language: Language?) {
        self.language = language
        self.reloadLanguage()
    }
    
    func reloadLanguage() {
        _sections = nil // Force sections to be re-loaded
        tableView.reloadData()
    }
    
    // MARK: IBActions

    // Switch the verb list ordering. Order by Infinitive or English translation
    @IBAction func reorderVerbs(sender: UIBarButtonItem) {
        // Reorder the verb list (flip it, essentially)
        order = (order == .Infinitive) ? .English : .Infinitive
        
        reloadLanguage()
        
        tableView.reloadSectionIndexTitles()
    }

    // Open the language seletion list by tapping the globe icon
    @IBAction func didTapGlobe(sender: UIBarButtonItem) {
        self.delegate.showLeftViewAnimated(true, completionHandler: nil)
    }
    
    // Activate the search bar by tapping the magnifying glass icon
    @IBAction func didTapSearch(sender: UIBarButtonItem) {
        searchController.searchBar.becomeFirstResponder()
    }
    

    // MARK: Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let verb: Verb
                if userIsSearching {
                    verb = filteredVerbs![indexPath.row]
                } else {
                    verb = getVerbAtIndexPath(indexPath)
                }
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.verb = verb
                
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if userIsSearching {
            return 1
        }
        
        return self.sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userIsSearching {
            return filteredVerbs!.count
        }
        
        return self.sections[section].verbs.count
    }
    
    // section headers: appear above each `UITableView` section
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        // do not display empty sections
        if !userIsSearching {
            let section = self.sections[section]
            if section.verbs.count > 0 {
                return section.title
            }
        }
        
        return ""
    }
    
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if userIsSearching {
            return 0
        }
        
        return self.collation.sectionForSectionIndexTitleAtIndex(index)
    }
    
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if userIsSearching {
            return nil
        }
        
        return self.collation.sectionIndexTitles
    }
    
    // Get the cell instance
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VerbCell", forIndexPath: indexPath) as! VerbListCell
        cell.language = language

        let verb: Verb
        if userIsSearching {
            verb = filteredVerbs![indexPath.row]
        } else {
            verb = getVerbAtIndexPath(indexPath)
        }

        if order == .Infinitive {
            cell.textLabel!.text = verb.infinitive
            cell.detailTextLabel!.text = verb.english
        } else {
            cell.detailTextLabel!.text = verb.infinitive
            cell.textLabel!.text = verb.english
        }
        
        return cell
    }

    // Verbs may not be deleted from the list
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    // Should show menu for 'Speak' and 'Copy' actions
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return (action == Selector("copy:") || action == Selector("speak:"))
    }
    
    override func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        // empty function - doesn't need to do anything, just needs to be defined
    }
    
    func getVerbAtIndexPath(indexPath: NSIndexPath) -> Verb {
        return sections[indexPath.section].verbs[indexPath.row]
    }
    
    // MARK: Searching
    
    func filterVerbsForSearchText(searchText: String) {
        if (language != nil) {
            filteredVerbs = language!.searchVerbs(searchText)
        }
        
        tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterVerbsForSearchText(searchController.searchBar.text!)
    }
    
    
}
