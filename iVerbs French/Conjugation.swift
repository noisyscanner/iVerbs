//
//  Conjugation.swift
//  iVerbs
//
//  Created by Brad Reed on 03/10/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation
import RealmSwift

// Represents a Conjugation for a given Verb for a particular Tense and Pronoun
class Conjugation: Object, Model, Speaks {
    
    // Stored properties
    dynamic var tense_id = 0
    dynamic var pronoun_id = 0
    dynamic var conjugation = ""
    dynamic var normalisedConjugation = "" // No accents, lowercase
    
    var textToSpeak: String {
        return self.conjugation
    }
    
    // Return a list of verbs associated with this conjugation
    // Should just be the one
    fileprivate let verbs = LinkingObjects(fromType: Verb.self, property: "conjugations")
    
    var verb: Verb {
        return verbs.first!
    }
    
    var language: Language? {
        return verb.language
    }
    
    // Get the Pronoun instance for the related Pronoun
    var pronoun: Pronoun {
        return verb.language.pronouns.filter("id = \(pronoun_id)").first!
    }
    
    // Get the Tense instance for the Conjugation's Tense
    var tense: Tense {
        return verb.language.tenses.filter("id = \(tense_id)").first!
    }
    
    
    // Create Conjugation instance with Dictionary from API
    // Return nil if the data is invalid
    required convenience init?(dict: JSONDict) {
        self.init()
        
        // Validate data
        guard let conjugation = dict["c"] as? String else { return nil }
        guard let normalisedConjugation = dict["nc"] as? String else { return nil }
        guard let pid = dict["pid"] as? Int else { return nil }
        guard let tid = dict["tid"] as? Int else { return nil }
        
        // Short keys
        self.conjugation = conjugation
        self.normalisedConjugation = normalisedConjugation
        self.pronoun_id = pid
        self.tense_id = tid
        
    }
    
    
}
