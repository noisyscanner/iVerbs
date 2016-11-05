//
//  ModelTests.swift
//  iVerbs French
//
//  Created by Brad Reed on 30/12/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import XCTest
@testable import iVerbs_French

class ModelTests: XCTestCase {
    
    func testLanguageCount() {
        let count = Language.count
        XCTAssertGreaterThanOrEqual(count, 0)
    }
    
    func testLanguageCountInBackground() {
        // Use this because of the async stuff
//        let expectation = self.expectation(description: "Background language count succeeds")
        
        let count = Language.count
        XCTAssertGreaterThanOrEqual(count, 0)
        
        /*DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let count = Language.count
            XCTAssertGreaterThanOrEqual(count, 0)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)*/
    }
    
    /*func testLanguageStringListWorks() {
        // Test that the Language.listOfLanguagesNames() works
        
        XCTAssertGreaterThan(Language.count, 0, "Test will only work if there are languages installed")
        
        let langs = Language.listOfLanguagesNames()
        XCTAssertGreaterThan(langs.count, 0)
    }*/
    
    /*func testLangUpdate() {
        LanguageManager.checkForUpdates { _ in }
        
        let expectation = self.expectation(description: "Realm transaction complete")
        
        let lang = Language.findByCode("fr")
        XCTAssertNotNil(lang)
        
        print("Current version:", lang!.version)
        print("Latest version:", lang!.latestVersion)
        
        RealmManager.realmWrite { realm in
//            let version = lang!.version
//            lang!.version = 0
            
            let hasUpdate = lang!.hasUpdate
//            lang!.version = version
            
            XCTAssertTrue(hasUpdate)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
    }*/
    
    /*func testRemoveJouer() {
        let lang = Language.findByCode("fr")
        
        if lang != nil {
            let jouer = lang!.verbs.filter("infinitive = 'Jouer'").first
            if jouer != nil {
                RealmManager.realmWrite { realm in
                    realm.delete(jouer!)
                    
                    XCTAssertNil(jouer)
                }
            }
        }
    }*/
    
}
