//
//  Language.swift
//  iVerbs
//
//  Created by Brad Reed on 29/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation
import RealmSwift

// Represents a Language in iVerbs, installed or not
// If a Language is installed, it will have tenses, pronouns and verbs
// If not, the tenses, verbs and pronuns lists will be empty
class Language: Object, Model {
    
    // Stored properties
    dynamic var id = 0
    dynamic var code = ""
    dynamic var locale = ""
    dynamic var language = ""
    dynamic var version = 0
    dynamic var latestVersion = 0
    
    // Return the language name followed by its emoji flag
    var label: String {
        return language + " " + emojiFlag()
    }
    
    // Return Locale object
    var nsLocale: Locale {
        return Locale(identifier: locale)
    }
    
    // Many-to-one relationships
    var tenses = List<Tense>()
    var pronouns = List<Pronoun>()
    var verbs = List<Verb>()
    
    // Get the total count of Languages stored in the local Realm database
    // This includes installed Languages and Languages that have been cached
    // from the API as 'available for download'
    class var count: Int {
        return RealmManager.realm.objects (Language.self).count
    }
    
    // Get a list of verbs that the user has favourited for this Language
    var favouriteVerbs: Results<Verb> {
        return verbs.filter("favourite = true")
    }
    
    // Returns whether or not the Language has been installed on the device
    var installed: Bool {
        return version != 0
    }
    
    // Tells the Realm DBMS the name of the primary key field
    override static func primaryKey() -> String {
        return "id"
    }
    
    // MARK: Initialisation
    
    /// Init language with data from API, return nil on invalid data
    required convenience init?(dict: JSONDict) {
        var data = dict
        if let dataDict = dict["data"] as? JSONDict {
            data = dataDict
        }
        self.init()
        
        guard let id = data["id"] as? Int else { return nil }
        guard let code = data["code"] as? String else { return nil }
        guard let language = data["lang"] as? String else { return nil }
        guard let locale = data["locale"] as? String else { return nil }
        guard let latestVersion = data["version"] as? Int else { return nil }
        
        self.id = id
        self.code = code
        self.language = language
        self.locale = locale
        self.latestVersion = latestVersion
    }
    
    func installSchema(_ dict: JSONDict) {
        let data = dict["data"] as! JSONDict
        
        // Pronouns
        if let pronounDict = data["pronouns"] as? JSONDict {
            let pronouns = Pronoun.pronounsWithDict(pronounDict)
            RealmManager.realmWrite { _ in
                self.pronouns.append(contentsOf: pronouns)
            }
        }
        
        
        // Tenses
        if let tenseDict = data["tenses"] {
            let tenses = Tense.tensesWithDict(tenseDict as! NSDictionary)
            RealmManager.realmWrite { _ in
                self.tenses.append(contentsOf: tenses)
            }
        }
    }
    
    // MARK: Installation
    func install(_ onCompletion: @escaping (Swift.Error?) -> Void) {
        if installed {
            // Nothing to do if the language is already installed
            return
        }
        
        // Install the language...
        
        // Get the language schema from the API
        let request = ApiRequest(path: "/languages/" + code + "/schema") { response in
            if response.failed {
                print("Error fetching language schema: ", response.error!)
                onCompletion(response.error)
                
            } else {
                // Success
                print("Downloaded language schema for: ", self.code) // debug msg
                
                // Install schema to Realm
                self.installSchema(response.data!)
                
                // Install verbs
                self.downloadVerbs { error in
                    if error != nil {
                        print("Error fetching verbs for Language '\(self.code)' - ", error!)
                    } else {
                        print("Downloaded verbs: ", self.language)
                    }
                    
                    RealmManager.realmWrite { realm in
                        self.version = self.latestVersion
                        onCompletion(error)
                    }
                    
                }
            }
        }

        request.makeRequest()
    }
    
    func uninstall(_ onCompletion: @escaping () -> Void) {
        // 1. Remove all verbs and conjugations
        // 2. Remove tenses and pronouns
        // 3. Update latest version from API (if internet is on)
        // 4. Set version = 0
        // Keep core language info on device

        RealmManager.realmWrite { realm in
            self.version = 0
            
            realm.delete(self.verbs) // removes all conjugations too
            realm.delete(self.pronouns)
            realm.delete(self.tenses)
            
            onCompletion()
        }
    }
    
    // MARK: Fetching Languages
    
    class var noneInstalled: Bool {
        return self.count == 0 || installedLanguages.count == 0
    }
    
    class func findByCode(_ code: String) -> Language? {
        // Try find Language in Realm
        let languages = allLanguages.filter("code = '\(code)'")
        if languages.count > 0 {
            return languages.first!
        }
        return nil
    }
    
    class var allLanguages: Results<Language> {
        return RealmManager.realm.objects (Language.self)
    }
    
    class var availableLanguages: Results<Language> {
        return allLanguages.filter("version = 0")
    }
    
    class var installedLanguages: Results<Language> {
        return allLanguages.filter("version > 0")
    }
    
    class var outdatedLanguages: Results<Language> {
        return installedLanguages.filter("version < latestVersion")
    }
    
    // MARK: - Updates and installation
    
    // Returns whether or not there is a new version of the DB available
    var hasUpdate: Bool {
         return self.version < self.latestVersion
    }

    // MARK: Downloading Verbs
    
    func downloadVerbs(_ onCompletion: @escaping (Swift.Error?) -> Void) {
        // Download all verbs from API for a given Language
        
        let path = "/languages/" + code + "/verbs"
        let request = ApiRequest(path: path, callback: { response in
            if response.failed {
                // Request failed, pass error
                onCompletion(response.error)
                
            } else {
                // Success
                
                // Create Verb objects from API data
                let verbArray = response.data!["data"] as? [JSONDict]
                
                if verbArray != nil {
                    let verbs = List<Verb>()
                    
                    // Loop verbs array, create an array of Verb objects
                    for verbDict in verbArray! {
                        // If verbDict is invalid, verb = nil so not added
                        if let verb = Verb(dict: verbDict) {
                            verbs.append(verb)
                        }
                    }
                    
                    // Write verbs and conjugations to Realm
                    RealmManager.realmWrite { realm in
                        self.verbs.append(contentsOf: verbs)
                        
                    }
                    
                } else {
                    // No verbs... Odd? Display an error
                    iVerbs.displayError("No Verbs Found", message: "Please try again", cancelButtonTitle: "Okay")
                }
                
                // Call callback handler
                onCompletion(response.error)
                
            }
        })
        request.makeRequest()
    }
    
    func downloadNewVerbs(_ onCompletion: @escaping (Swift.Error?) -> Void) {
        // Download new verbs created later than the current version timestamp
        if hasUpdate {
            let url = "/languages/" + self.code + "/newverbs/" + String(self.version)
            
            ApiRequest(path: url) { response in
                if response.succeeded {
                    let verbArray = response.data!["data"] as? [JSONDict]
                    
                    if verbArray != nil {
                        let verbs = Verb.VerbsWithData(verbArray!)
                        
                        RealmManager.realmWrite { realm in
                            self.verbs.append(contentsOf: verbs)
                            self.version = self.latestVersion
                            onCompletion(nil)
                        }
                    } else {
                        print("Updated verbs array nil for lang: ", self.code)
                        onCompletion(response.error)
                    }
                } else {
                    print("Request failed for new verbs for ", self.code, "Error: ", response.error!)
                    onCompletion(response.error)
                }
            }.makeRequest()
        }
    }
    
    // MARK: - Fetching tenses
    func tenseForSection(_ section: Int) -> Tense? {
        let tenses = self.tenses.filter("order = \(section)")
        return tenses.first
    }
    
    // MARK: - Searching verbs
    
    func searchVerbs(_ query: String) -> Results<Verb> {
        // [c] means case insensitive
        let predicate = NSPredicate(format: "normalisedInfinitive CONTAINS[c] %@ OR english CONTAINS[c] %@ OR ANY conjugations.normalisedConjugation CONTAINS[c] %@", argumentArray:
            [query, query, query])
        return self.verbs.filter(predicate)
    }
    
    // MARK: - Emojis
    
    // Adapted from: https://bendodson.com/weblog/2016/04/26/emoji-flags-from-iso-3166-country-codes-in-swift/
    func emojiFlag() -> String {
        var string = ""
        var country = code.uppercased()
        for uS in country.unicodeScalars {
            if let scalar = UnicodeScalar(127397 + uS.value) {
                string.append(String(scalar))
            }
        }
        return string
    }
    
    

}
