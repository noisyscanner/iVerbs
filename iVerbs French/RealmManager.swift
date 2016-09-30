//
//  RealmManager.swift
//  Realm-Test
//
//  Created by Brad Reed on 29/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    class var realm: Realm {
        return newInstance()
    }
    
    class func newInstance() -> Realm {
        var realm: Realm?
        setupRealm() // Set config vars and stuff
        
        do {
            realm = try Realm()
        } catch let error as NSError {
            print("Realm could not be instantiated: ", error)
            // TODO: throw an error
        }
        return realm!
    }
    
    private class func setupRealm() {
        // Set Realm configuration
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 4,
            migrationBlock: { migration, oldSchemaVersion in
                // The enumerateObjects:block: method iterates
                // over every 'Language' object stored in the Realm file
                if oldSchemaVersion < 2 {
                    migration.enumerate(Language.className()) { oldObject, newObject in
                        // Add the `verbs` property only to Realms with a schema version of 2
                        newObject!["verbs"] = List<Verb>()
                    }
                }
                if oldSchemaVersion < 3 {
                    migration.enumerate(Language.className()) { oldObject, newObject in
                        // Add the `tenses` property only to Realms with a schema version of 3
                        newObject!["tenses"] = List<Tense>()
                    }
                }
                if oldSchemaVersion < 4 {
                    migration.enumerate(Language.className()) { oldObject, newObject in
                        newObject!["pronouns"] = List<Pronoun>()
                    }
                }
        })
    }
}