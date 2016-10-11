//
//  ApiRequest.swift
//  iVerbs
//
//  Created by Brad Reed on 22/12/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation
import Alamofire

// Shortcut for referring to the API Callback type
typealias ApiCallback = (ApiResponse) -> Void

// Represents a request to be made to the iVerbs API
class ApiRequest {
    
    var path: String // The relative path to make the request to eg. '/languages'
    var method: HTTPMethod // The HTTP method used to make the request
    var callback: ApiCallback // A callback to be called when the request completes (see above typealias)
    
    var manager: SessionManager! // For API requests
    
    // If this is set to true, the API will return an invalid authenticity token with the response
    // Used for testing
    var generateInvalidToken = false
    
    // Get the absolute URL for the request
    var url: String {
        var url = iVerbs.Api.baseURL + path
        
        // If ?invalidToken=true is appended to the URL, the API
        // will return an invalid token.
        // This is useful for testing the token validator
        if generateInvalidToken {
            url += "?invalidToken=true"
        }
        
        return url
    }
    
    // Create a new API Request instance
    // Currently not used, the below convenience initialiser delegates to this method
    // In the future it may be required that we use POST or other HTTP methods
    init(path: String, method: HTTPMethod, callback: @escaping ApiCallback) {
        self.path = path
        self.method = method
        self.callback = callback
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        manager = SessionManager(configuration: configuration)
    }
    
    // Convenience init for GET request
    convenience init(path: String, callback: @escaping ApiCallback) {
        self.init(path: path, method: .get, callback: callback)
    }
    
    // Make the request and call the callback function on completion
    func makeRequest() {
        // Create request instance with 3rd party Alamofire networking library


//        let request = manager!.request(method, url, encoding: .json, headers: nil)
//        let request = manager!.request(url, method: HTTPMethod.get, parameters: nil, encoding: .json, headers: nil)
        let request = manager.request(url, method: method, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        
        print("Making request to:", url) // Log to console
        
        // Called when the request finishes. Gets the JSON from the response
        request.responseJSON { response in
            
            // ApiResponse is a wrapper around the Alamofire Response object
            var apiresponse = ApiResponse(response: response)
            let _ = apiresponse.validate() // Validate response from API TODO: Do something with the result ???
            
            self.callback(apiresponse)
        }
    }
    
}
