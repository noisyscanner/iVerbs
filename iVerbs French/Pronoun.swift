//
//  Pronoun.swift
//  iVerbs
//
//  Created by Brad Reed on 30/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation
import RealmSwift

/* Pronoun
 *
 * This is a model class for Pronouns.
 * These are part of language packs for iVerbs.
 * A Language has many Pronouns. Each Pronoun can belong to only one Language
 */
class Pronoun: Object, Model {
    
    // Stored properties. These are persisted in the local Realm database
    dynamic var id = 0            // Primary key
    dynamic var identifier = ""   // Used to identify a pronoun
    dynamic var displayName = ""  // What is displayed to the user in the Conjugation Table
    dynamic var order = 0         // Used to sort Pronouns in the Conjugation Table
    
    private let languages = LinkingObjects(fromType: Language.self, property: "pronouns")
    
    // Get the Language for this Pronoun
    var language: Language {
        return languages.first!
    }
    
    // MARK: Initialisation
    
    // Initialise Pronoun with data from API
    convenience required init(dict: [String: AnyObject]) {
        // Call parent initialiser
        self.init()
        
        // Assign properties, type-casting to the correct type
        self.id = dict["id"] as! Int
        self.identifier = dict["identifier"] as! String
        self.displayName = dict["displayName"] as! String
        self.order = dict["order"] as! Int
    }
    
    // Returns an array of Pronoun objects given a Dictionary of
    // data from the API. This Dictionary will contain a 'data' key,
    // which will be an array of Pronoun objects which can be created with the
    // above convenience initialiser
    class func pronounsWithDict(_ dict: [String: AnyObject]) -> [Pronoun] {
        
        // If the data is in the provided dictionary
        if let data = dict["data"] as? [[String: AnyObject]] {
            
            // Loops each element of the 'data' array as a dictionary
            // containing the pronoun's properties, and created a Pronoun
            // object.
            // Map collects each of these into an array of Pronouns - [Pronoun]
            return data.map { pronoun in
                return Pronoun(dict: pronoun)
            }
            
        }
        
        // If the correct data was not supplied, return an empty array
        return [Pronoun]()
    }
    
    // Given a Conjgation, return the string to be displayed to the user in 
    // the Conjugation table.
    //
    // This will usually be the same as the displayName property
    func displayNameForConjugation(_ conjugation: Conjugation?) -> String {
        if conjugation != nil {
            
            // When it is the special 'auxiliary verb' row,
            // return the infinitive form of the verb's helper verb
            if identifier == "aux" {
                // Auxilary verb
                return conjugation!.verb.helper.infinitive.lowercased()
            }
            
            /* In iVerbs French, conjugations that begin with a vowel
             * for the "je" pronoun should be shown with the prounoun as "j'"
             */
            if self.language.code == "fr" && self.identifier == "je" {
                // Get the first letter of the conjugation
                let firstLetter = (conjugation!.conjugation as NSString).substring(to: 1)
                
                
                // Check if the first letter of the conjugation is a vowel
                let vowels = "aeiou"
                if vowels.contains(firstLetter) {
                    return "j'"
                }
            }
            
        }
        
        // Return the default displayName for the pronoun by default
        return self.displayName.lowercased()
    }
}
