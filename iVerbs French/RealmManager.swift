//
//  RealmManager.swift
//  iVerbs
//
//  Created by Brad Reed on 29/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation
import RealmSwift

// Used to manage the Realm database.
// Contains methods to initialise the Realm database,
// and get a singleton which can be accessed from anywhere in the app
class RealmManager {
    
    // Property to store the Realm instance
    fileprivate static var _realm: Realm?
    
    // Computed property to access the Realm instance
    // If Realm has already been initialised (_realm is not nil),
    // return _realm.
    // Otherwise, initialise Realm and
    class var realm: Realm {
        
        if _realm == nil {
            // Realm has not been initialised yet
            
            setupRealm() // Set config vars and stuff
            
            // Catch potential errors
            do {
                _realm = try Realm()
            } catch let error {
                // Error initialising Realm, display error
                print("Realm could not be instantiated: ", error)
                iVerbs.displayError("Database Error", message: "Please make sure you have enough free space")
            }
            
        }
        
        // Return the Realm instance
        return _realm!
    }
    
    fileprivate class func setupRealm() {
        // Set Realm configuration
        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: 1)
    }
    
    /* Perform a Realm 'write transaction' using the given block
     *
     * Explanation:
     * All write operations done with Realm must be done within
     * a 'write transaction', and all Realm queries must be done
     * on the main thread, so this function does both of those things for us.
     *
     * This method simplifies the process so we can do something
     * like the following elsewhere in the code:
     * 
     * RealmManager.realmWrite { realm in
     *   realm.add(SomeObject) // Add SomeObject to the database
     * }
     *
     */
    class func realmWrite(_ block: @escaping (_ realm: Realm) -> Void) {
        DispatchQueue.main.async { // Perform on main thread
            // realm.write could throw an exception, so do
            // within a do..try..catch block to handle errors
            do {
                try realm.write {
                    block(realm)
                }
            } catch let error {
                // An error occured, print error to console
                // and display error message to user in pop-up box
                
                print("Could not write to Realm: ", error)
                iVerbs.displayError("Database Error", message: "Please make sure you have enough free space")
            }
        }
    }
    
}
