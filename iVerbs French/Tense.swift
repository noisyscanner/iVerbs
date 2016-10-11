//
//  Tense.swift
//  iVerbs French
//
//  Created by Brad Reed on 30/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation
import RealmSwift

class Tense: Object {
    
    dynamic var id = 0
    dynamic var identifier = ""
    dynamic var displayName = ""
    dynamic var order = 0
    
    // This should just return one language
    fileprivate let languages = LinkingObjects(fromType: Language.self, property: "tenses")
    
    var language: Language {
        // Define "language" as the inverse relationship to Lanuages.Tenses
        return languages.first!
    }
    
    // MARK: Initialisation
    
    // Initialize Tense with data from API as Dictionary
    convenience init(dict: NSDictionary) {
        self.init()
        
        self.id = dict.object(forKey: "id") as! Int
        self.identifier = dict.object(forKey: "identifier") as! String
        self.displayName = dict.object(forKey: "displayName") as! String
        self.order = dict.object(forKey: "order") as! Int
    }
    
    // Return a list of Tense objects given a dictionary of info from the API
    class func tensesWithDict(_ dict: NSDictionary) -> [Tense] {
        
        if let data = (dict.object(forKey: "data") as? NSArray) {
            return data.map { pronoun in
                return Tense(dict: pronoun as! NSDictionary)
            }
        }
        
        // If the correct data was not supplied, return an empty array
        return [Tense]()
    }
    
}
