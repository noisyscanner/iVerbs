//
//  LanguageDownloadTests.swift
//  iVerbs French
//
//  Created by Brad Reed on 03/01/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import XCTest
@testable import iVerbs_French

class LanguageDownloadTests: XCTestCase {

    func testLanguageInitWithDict() {
        
        let language = Language.initWithDataFromAPI([
            "data": [
                "id": 1,
                "code": "fr",
                "language": "French"
            ]
        ])
        
        XCTAssertNotNil(language)
        
        print(language)
        
    }
    
}