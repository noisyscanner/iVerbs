//
//  Tense.swift
//  Realm-Test
//
//  Created by Brad Reed on 30/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation
import RealmSwift

class Tense: Object {
    
    dynamic var id = 0
    dynamic var lang = ""
    dynamic var identifier = ""
    dynamic var displayName = ""
    dynamic var order = 0
    
    var language: Language {
        // Realm doesn't persist this property because it only has a getter defined
        // Define "language" as the inverse relationship to Lanuages.Tenses
        let languages = linkingObjects(Language.self, forProperty: "tenses")
        return languages[0]
    }
}