//
//  SHA1.swift
//  iVerbs
//
//  Created by Brad Reed on 28/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation

// Extension to the Swift String class to add a sha1() method
extension String {
    
    // Calculate SHA1 hash for the string
    // Used for validating authenticity tokens from the API
    // http://stackoverflow.com/questions/25761344/how-to-crypt-string-to-sha1-with-swift
    func sha1() -> String {
        
        // Convert string to NSData using UTF-8 encoding
        let data = self.data(using: String.Encoding.utf8)!
        
        // Create array of bytes, zeroes,
        // the size of a SHA1 digest (20 bytes)
        // Type: UInt8 ('A 8-bit unsigned integer value')
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        
        // Run the SHA1 algorithm on the data
        // Params: data - the input string as an array of bytes
        //         len  - the length of the data
        //         md   - the array of bytes to output the digest to
        CC_SHA1((data as NSData).bytes, CC_LONG(data.count), &digest)
        
        // Convert the array of bytes to an array of single character
        // strings for the Unicode character they represent
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        
        // Return a string made by joining the array of bytes 
        // with no separator between the characters
        return hexBytes.joined(separator: "")
    }
}
