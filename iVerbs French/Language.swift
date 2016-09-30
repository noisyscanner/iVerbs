//
//  Language.swift
//  Realm-Test
//
//  Created by Brad Reed on 29/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation
import RealmSwift

class Language: Object {
    dynamic var id = 0
    dynamic var code = ""
    dynamic var language = ""
    
    var verbs = List<Verb>()
    var tenses = List<Tense>()
    var pronouns = List<Pronoun>()
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    class func findByCode(code: String) -> Language? {
        // Try find Language in Realm
        let languages = RealmManager.realm.objects(Language).filter("code = '\(code)'")
        if languages.count > 0 {
            return languages[0]
        }
        return nil
    }
}