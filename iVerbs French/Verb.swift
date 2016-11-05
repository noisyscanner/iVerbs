//
//  Verb.swift
//  iVerbs
//
//  Created by Brad Reed on 29/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation
import RealmSwift

class Verb: Object {
    dynamic var id = 0
    dynamic var english = ""
    dynamic var infinitive = ""
    dynamic var normalisedInfinitive = ""
    dynamic var helper_id = 0
    dynamic var favourite = false
    dynamic var isHelper = false
    
    // sectionIndex: Int
    //
    // Section ID in the verb list UITableView 
    // Not persisted as it is generated at runtime
    // Ignored property, see below
    //
    var section: Int? = 0
    
    // LinkingObjects() in this version of Realm must be done first, THEN use first!
    fileprivate let languages = LinkingObjects(fromType: Language.self, property: "verbs")
    
    var language: Language {
        // Get the language that the verb is for
        return languages.first!
    }
    
    // In the French lanauage, verbs that begin with "se" are 'reflexive'
    // Eg. "Se doucher" (to shower)
    // The "se" should be ignored when sorting, so "se doucher" should appear 
    // under the D section, not S
    var reflexive: Bool {
        get {
            if self.language.code == "fr" {
                // Is French language
                
                return self.normalisedInfinitive.characters.count >= 3 &&
                    self.normalisedInfinitive.substring(to: self.normalisedInfinitive.characters.index(self.normalisedInfinitive.startIndex, offsetBy: 3)) == "se "
            }
            return false
        }
    }
    
    var helper: Verb {
        return RealmManager.realm.objects(Verb.self).filter("id = \(helper_id)").first!
        
    }
    
    var sortNormalisedInfinitive: String {
        return reflexive ? (normalisedInfinitive as NSString).substring(from: 3) : normalisedInfinitive
    }
    
    var sortEnglish: String {
        let nsenglish = english as NSString
        return (nsenglish.substring(to: 2) == "To") ? nsenglish.substring(from: 3) : nsenglish as String
    }
    
    var conjugations = List<Conjugation>()
    
    override static func ignoredProperties() -> [String] {
        return ["section"]
    }

    override static func primaryKey() -> String {
        return "id"
    }
    
    
    /// Create new verb with data from API,
    /// returns nil if data was invalid
    convenience init?(dict: JSONDict) {
        self.init()
        
        // Validate given data
        guard let id = dict["id"] as? Int else { return nil }
        guard let english = dict["e"] as? String else { return nil }
        guard let infinitive = dict["i"] as? String else { return nil }
        guard let normalisedInfinitive = dict["ni"] as? String else { return nil }
        guard let helper_id = dict["hid"] as? Int else { return nil }
        guard let isHelper = dict["ih"] as? Bool else { return nil }
        guard let conjugations = (dict["conjugations"] as? JSONDict)?["data"] as? [JSONDict] else { return nil }
        
        self.id = id
        self.english = english
        self.infinitive = infinitive
        self.normalisedInfinitive = normalisedInfinitive
        self.helper_id = helper_id
        self.isHelper = isHelper
        
        // Sort out conjugations
        for object in conjugations {
            if let conjugation = Conjugation(dict: object) {
                // If conjugation is nil, the data is invalid so don't create it
                self.conjugations.append(conjugation)
            }
        }
        
    }
    
    // MARK: Init
    
    class func VerbsWithData(_ dicts: [JSONDict]) -> [Verb] {
        // Loop verbs array, create an array of Verb objects
        var verbs = [Verb]()
        
        for verbDict in dicts {
            let id = verbDict["id"] as! Int
            
            // If the verb already exists, delete it so it can
            // be replaced with the newer verb
            let query = RealmManager.realm.objects (Verb.self).filter("id = \(id)")
            if query.count > 0  {
                RealmManager.realmWrite { realm in
                    realm.delete(query)
                }
            }
            
            // Create verb object from dictionary and appent to array
            // If data is invalid, verb = nil so is not added
            if let verb = Verb(dict: verbDict) {
                verbs.append(verb)
            }
            
        }
        
        return verbs
    }
    
    // MARK: Favourite
    
    func toggleFavourite(_ onCompletion: @escaping () -> Void) {
        RealmManager.realmWrite { realm in
            self.favourite = !self.favourite
            onCompletion()
        }
    }

}
