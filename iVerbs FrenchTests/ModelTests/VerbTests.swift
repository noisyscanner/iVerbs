//
//  VerbTests.swift
//  iVerbs
//
//  Created by Bradley Reed on 02/11/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import XCTest
@testable import iVerbs_French

/// These tests validate that Verb objects can be created with valid data,
/// and return nil for invalid data
class VerbTests: XCTestCase {

    var sampleData: [String: Any] = [:]
    
    override func setUp() {
        sampleData = [
            "id": 2,
            "i": "Jouer",
            "e": "To Play",
            "ni": "jouer",
            "hid": 53,
            "ih": false,
            "conjugations": [ // valid, contains some conjugations
                "data": [
                    [
                        "tid": 1,
                        "pid": 1,
                        "c": "joue",
                        "nc": "joue"
                    ],
                    [
                        "tid": 1,
                        "pid": 2,
                        "c": "joues",
                        "nc": "joues"
                    ]
                ]
            ]
        ] as [String: Any]
    }
    
    /// Test: verb initialised with missing data returns nil
    func testVerbInitWithMissingData() {
        let data = [
            "data": [
                "id": 1,
                "e": "To Play",
                // Missing i, ni, hid, ih
            ]
        ]
        
        XCTAssertNil(Verb(dict: data as JSONDict))
        
    }
    
    /// Test: verb initialised with invalid data returns nil
    func testVerbInitWithInvalidData() {
        let data = [
            "id": "1", // should be int
            "e": 1, // should be string
            "i": 2, // should be string
            "ni": 3, // should be string
            "hid": "53", // should be int
            "ih": 0 // should be bool
            // Missing conjugations
        ] as [String: Any]
        
        XCTAssertNil(Verb(dict: data as JSONDict))
        
    }
    
    /// Test: valid verbs with no conjugations should return nil
    func testVerbInitWithNoConjugations() {
        var data = sampleData
        data.removeValue(forKey: "conjugations")
        
        XCTAssertNil(Verb(dict: data as JSONDict))
    }
    
    /// Test: verb can be initialised with valid data
    func testVerbInitWithValidData() {
        // Example valid response from API
        let verb = Verb(dict: sampleData as JSONDict)
        
        XCTAssertNotNil(verb)
        
        // Test conjugations are created
        let conjArr = ((sampleData["conjugations"] as! JSONDict)["data"] as! [JSONDict])
        XCTAssertEqual(verb!.conjugations.count, conjArr.count)
    }
    
    /// Test: verb is still initialised if there are extra keys in the data
    func testVerbInitWithExtraData() {
        var data = sampleData
        data["extra"] = "key"
        data["foo"] = 12345
        data["bar"] = true
        // Example valid response from API, with extra keys
        // Future versions of the API could introduce new data
        
        XCTAssertNotNil(Verb(dict: data as JSONDict))
    }
}
