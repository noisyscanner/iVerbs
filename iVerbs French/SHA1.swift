//
//  SHA1.swift
//  Realm-Test
//
//  Created by Brad Reed on 28/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation

extension String {
    
    // Find Sha1 for the string
    func sha1() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        for byte in digest {
            output.appendFormat("%02x", byte)
        }
        return output as String
    }
}
