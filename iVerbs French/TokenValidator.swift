//
//  TokenValidator.swift
//  iVerbs
//
//  Created by Brad Reed on 28/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation

// Validates authenticity tokens received from the API
class TokenValidator {
    
    var response: HTTPURLResponse?
    var token: String?
    var data: Data?
    
    // Initialise the Token Validator with an Api Response
    init(apiResponse: ApiResponse) {
        // Get data from the API response
        data = apiResponse.response.data
        
        // Get the NSHTTPURLResponse
        response = apiResponse.response.response
        
        // Get token from header field and assign it to self._token
        // if it is present
        if response != nil {
            if let theToken = response!.allHeaderFields["iVerbs-Token"] {
                token = theToken as? String
            }
        }
    }
    
    // Validate the token and return true/false with the result
    func validate() -> Bool {
        // If any of the required data is missing, return false
        if token == nil || response == nil || data == nil {
            return false
        }
        
        // Use of ! is safe beyond this point since 
        // we verified that the variables are not nil
        
        let checkToken = calculateCorrectToken()
        
        // Check that the tokens match
        let valid = checkToken == token!
        
        if !valid {
            // Token mismatch, print debug message to console
            print("Invalid Token: \(checkToken) != \(token!)")
        }
        
        // Return a bool as to whether or not the token was valid
        return valid
    }
    
    // Calculate what the token received from the API *should* be
    fileprivate func calculateCorrectToken() -> String {
        // Get the JSON returned by the API as a string
        let jsonString = String(data: data!, encoding: String.Encoding.utf8)!
        
        // Appending the salt gives us our 'cipher'
        let cipher = jsonString + iVerbs.Api.salt
        
        // The calculated token is the SHA1 hash of the cipher
        // The sha1() method is provided by an extension to the String class
        // See Support/Extensions/SHA1.swift
        return cipher.sha1()
    }
    
}
