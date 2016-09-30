//
//  Constants.swift
//  Realm-Test
//
//  Created by Brad Reed on 30/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation

struct iVerbs {

    let brandName = "iVerbs French"
    var setup = false // Whether or not the DB schema has been set up locally
    var language: Language
    
    struct Lang {
        static let language = "French"
        static let code = "fr"
    }
    
    struct Api {
        static let baseURL = "http://api.iverbs.local"
        static let salt = "mSRy4DOUWH TmJ1o-bLlnl~pfDkKrWmtktl~OMHZQbQ1ufcf o%aQl1q8iiQ"
    }
}