//
//  ApiResponse.swift
//  iVerbs
//
//  Created by Brad Reed on 22/12/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation
import Alamofire

typealias AlamoResponse = DataResponse<Any>

struct ApiResponse {
    
    var response: AlamoResponse
    var _error: Error?

    // Returns true if the request failed, otherwise false if it succeeded
    var failed: Bool {
        return error != nil || self.response.result.isFailure
    }
    
    // Returns true if the request succeeded, otherwise false if it failed
    var succeeded: Bool {
        return !failed
    }
    
    // If an error occured, return it
    var error: Error? {
        return _error != nil ? _error : self.response.result.error
    }
    
    // Get the data returned from the API, or nil if the request failed
    var data: [String: AnyObject]? {
        if succeeded {
            if let json = response.result.value as? [String: AnyObject] {
                return json
            }
        }
        return nil
    }
    
    // Create a new ApiResponse instance with an AlamoResponse instance
    init(response: AlamoResponse) {
        self.response = response
    }
    
    // Validate the response
    // Marked as mutating as it can modify the _error property of this structure
    mutating func validate() -> Bool {
        
        /*var passes = true // Set to false when validation fails
        
        
        if response.result.isSuccess {
            // Request succeeded, validate data
            
            if response.result.value != nil {
                // Data received from API...
                
                // Validate token
                if(!TokenValidator(apiResponse: self).validate()) {
                    passes = false
                    
                    _error = IVError.invalidToken
                    
                }
            } else {
                // No data received, error
                passes = false
                
                _error = IVError.noData
            }
        } else {
            // Request failed
            passes = false
            
            if let error = response.result.error {
                print("API request error: ", error)
            }
        }*/
        
//        return passes
        
        // New code, UNTESTED and won't work yet
        
        // Check response was success
        guard response.result.isSuccess else {
            if let error = response.result.error {
              print("API request error: ", error)
            }
            return false
        }
        
        // Check that data was returned
        guard response.result.value != nil else {
            _error = IVError.noData
            return false
        }
        
        // Validate token
        guard TokenValidator(apiResponse: self).validate() else {
            _error = IVError.invalidToken
            return false
        }
        
        return true

    }
    
}
