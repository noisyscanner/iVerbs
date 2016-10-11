//
//  ApiManager.swift
//  Realm-Test
//
//  Created by Brad Reed on 28/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation
import RealmSwift
//import SwiftyJSON

//typealias ServiceResponse = (JSON?, NSError?) -> Void
//typealias APICallback = (JSON?, NSError?) -> Void

class ApiManager: NSObject {
    static let sharedInstance = ApiManager()
    
    /*func downloadVerbs(language: Language, onCompletion: (NSError?) -> Void) {
        // Download all verbs from API for a given Language
        let verbs = List<Verb>()
        
        self.makeHTTPGetRequest("/languages/" + language.code + "/verbs", onCompletion: { json, error in
            if error == nil && json != nil {
                var data: JSON
                if json!["data"] != nil {
                    data = json!["data"]
                } else {
                    data = json!
                }
                
                // Main thread for Realm stuff
                dispatch_async(dispatch_get_main_queue(), {
                    for (_, verbJson): (String, JSON) in data {
                        let verb = Verb()
                        verb.id = verbJson["id"].int!
                        verb.english = verbJson["english"].string!
                        verb.infinitive = verbJson["infinitive"].string!
                        verb.normalisedInfinitive = verbJson["normalisedInfinitive"].string!
                        verb.helper_id = verbJson["helper_id"].int!
                        
                        // Sort out conjugations
                        let conjugations = verbJson["conjugations"]["data"].array
                        
                        for object in conjugations! {
                            let conjugation = Conjugation()
                            
                            conjugation.conjugation = object["conjugation"].string!
                            conjugation.pronoun_id = object["pronoun_id"].int!
                            conjugation.tense_id = object["tense_id"].int!
                            
                            verb.conjugations.append(conjugation)
                        }
                        
                        verbs.append(verb)
                    }
                    // Try write verbs to Realm
                    RealmManager.realmWrite() { realm in
                        language.verbs.appendContentsOf(verbs)
                    }
                    onCompletion(error)
                })

            } else {
                // Error with request
//                print("API Error: ", error)
//                iVerbs.displayError(error?.localizedDescription, message: error?.localizedFailureReason, cancelButtonTitle: "Dismiss")
                onCompletion(error)
            }
        })
    }*/
    
    
    /*func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
        let url = iVerbs.Api.baseURL + path
        print("Making request to: ", url)
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            if error != nil {
                // Error with request
                onCompletion(nil, error)
            }
            if data != nil {
                let json: JSON = JSON(data: data!) // TODO: Validate JSON data is valid
                
                // Validate token
                if(!TokenValidator(data: data, response: response).validate()) {
                    let error = NSError(domain: "iVerbsErrorDomain", code: -2001, userInfo: [
                        NSLocalizedDescriptionKey: "Request Failed",
                        NSLocalizedRecoverySuggestionErrorKey: "Try again",
                        NSLocalizedFailureReasonErrorKey: "Invalid token from API"
                    ])
                    onCompletion(nil, error) // We pass nil as the data we are not interested in since it's invalid
                } else {
                    onCompletion(json, nil) // Nil error
                }
            } else {
                // No data received, error
                let error = NSError(domain: "iVerbsErrorDomain", code: -2002, userInfo: [
                    NSLocalizedDescriptionKey: "Request Failed",
                    NSLocalizedRecoverySuggestionErrorKey: "Try again",
                    NSLocalizedFailureReasonErrorKey: "No data received from API"
                    ])
                onCompletion(nil, error) // We pass nil as the data we are not interested in since it's invalid
            }
        })
        task.resume()
    }*/
}