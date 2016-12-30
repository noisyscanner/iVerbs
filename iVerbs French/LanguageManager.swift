//
//  LanguageManager.swift
//  iVerbs French
//
//  Created by Brad Reed on 28/10/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation
import RealmSwift

class LanguageManager {
    
    // Install multiple languages
    class func installLanguages(_ languages: [Language], onCompletion: @escaping (_ installed: Int, _ error: Swift.Error?) -> Void) {
        var installedCount = 0 // Number of languages installed
        
        // Async
        let group = DispatchGroup()
        
        // Loop each language
        for language in languages {
            group.enter()
            language.install { error in
                if error != nil {
                    print("Error installing language '\(language.language)' - ", error!)
                } else {
                    // Increment installed counter
                    print("Language installed: ", language.language)
                    installedCount += 1
                }
                
                group.leave()

            }
            
        }
        
        group.notify(queue: DispatchQueue.main) {
            onCompletion(installedCount, nil) // TODO FIX
        }
    }
    
    class func cacheAvailableLanguages(_ onCompletion: @escaping (_ error: Swift.Error?) -> Void) {
        print("Fetching language list from API")
        
        // Get Language list from API
        let request = ApiRequest(path: "/languages", callback: { apiresponse in
            if apiresponse.succeeded {
                // Success
                if let data = apiresponse.data {
                    if let languageDicts = data["data"] as? [[String: AnyObject]] {
                        var languages: [Language] = []
                        
                        var langIDs = [Int]()
                        
                        // Loop language dictionaries and create new Language from each
                        for languageDict in languageDicts {
                            let langID = languageDict["id"] as! Int
                            langIDs.append(langID)
                            
                            // If the language already exists in the local db, don't recreate it
                            let query = Language.allLanguages.filter("id = \(langID)")
                            if query.count == 0 {
                                if let language = Language(dict: languageDict) {
                                    languages.append(language)
                                }
                            } else {
                                // If the language already exists, just update the version and save
                                let language = query.first!
                                
                                let newVersion = languageDict["version"] as! Int
                                if newVersion > language.latestVersion {
                                    RealmManager.realmWrite { _ in
                                        language.latestVersion = newVersion
                                    }
                                }
                            }
                        }
                        
                        RealmManager.realmWrite() { realm in
                            // Write new languages to Realm
                            realm.add(languages)
                            
                            // Remove old languages
                            self.removeOldLanguages(realm, langIDsAvailableOnline: langIDs)
                        }
                        
                        
                    } else {
                        // Invalid data from api
                        print("Languages not received from API: ", data)
                    }

                }
               
            } else {
                // Error
                print("Error fetching language list: ", apiresponse.error!)
            }
            
            onCompletion(apiresponse.error)
            
        })
        request.makeRequest()

    }
    
    // Checks the locally 'available' languages against those available
    // online and removed those that have not been installed by the user
    // but are no longer available for download
    // (must be called in a write transaction)
    class func removeOldLanguages(_ realm: Realm, langIDsAvailableOnline: [Int]) {
        
        // Loop locally cached 'available languages'
        // Those not installed but the app knows about
        for language in Language.availableLanguages {
            if !langIDsAvailableOnline.contains(language.id) {
                // Completely remove language from device
                realm.delete(language)
            }
        }
        
        
    }
    
}
