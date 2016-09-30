//
//  TokenValidator.swift
//  Realm-Test
//
//  Created by Brad Reed on 28/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation

class TokenValidator {
    
    var _response: NSHTTPURLResponse?
    var _token: String?
    var _data: NSData?
    
    init(data: NSData?, response: NSURLResponse?) {
        if let httpUrlResponse = response as? NSHTTPURLResponse {
            _response = httpUrlResponse
            if let token = httpUrlResponse.allHeaderFields["iVerbs-Token"] {
                // Token is present
                _token = token as? String
            }
        }
        
        _data = data
    }
    
    func validate() -> Bool {
        if _token == nil || _response == nil || _data == nil {
            return false
        }
        // Check signature
        
        let cipher = String(data: _data!, encoding: NSUTF8StringEncoding)! + iVerbs.Api.salt
//        print("cipher: ", cipher)
        let checkToken = cipher.sha1()
        return checkToken == _token!
    }
}