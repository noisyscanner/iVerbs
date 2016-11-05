//
//  LanguageDownloadTests.swift
//  iVerbs French
//
//  Created by Brad Reed on 03/01/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import XCTest
@testable import iVerbs_French

/// These tests validate that Language objects can be created with valid data, 
/// and return nil for invalid data
class LanguageTests: XCTestCase {

    /// Test: language initialised with missing data returns nil
    func testLanguageInitWithMissingData() {
        let data = [
            "data": [
                "id": 1,
                "code": "fr",
                "lang": "French"
                // Missing some keys, should be nil
            ]
        ]
        
        XCTAssertNil(Language(dict: data as JSONDict))
        
    }
    
    /// Test: language initialised with invalid data returns nil
    func testLanguageInitWithInvalidData() {
        let data = [
            "data": [
                "id": "1", // should be int
                "code": "fr", // should be string
                "lang": "French",
                "locale": 1234, // should be string
                "version": "1478079010" // should be int
            ]
        ]
        
        XCTAssertNil(Language(dict: data as JSONDict))
        
    }
    
    /// Test: language can be initialised with valid data
    func testLanguageInitWithValidData() {
        let data = [
            "data": [
                "id": 1,
                "code": "fr",
                "lang": "French",
                "locale": "fr_FR",
                "version": 1478079010
                // Example valid response from API
            ]
        ]
        
        XCTAssertNotNil(Language(dict: data as JSONDict))
    }
    
    /// Test: language is still initialised if there are extra keys in the data
    func testLanguageInitWithExtraData() {
        let data = [
            "data": [
                "id": 1,
                "code": "fr",
                "lang": "French",
                "locale": "fr_FR",
                "version": 1478079010,
                "extra": "key",
                "foo": 12345,
                "bar": true
                // Example valid response from API, with extra keys
                // Future versions of the API could introduce new data
            ]
        ]
        
        XCTAssertNotNil(Language(dict: data as JSONDict))
    }
}
