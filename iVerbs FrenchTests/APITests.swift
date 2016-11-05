//
//  APITests.swift
//  iVerbs French
//
//  Created by Brad Reed on 18/12/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import XCTest
@testable import iVerbs_French

class APITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAPIConnection() {
        // Use this because of the async stuff
        let expectation = self.expectation(description: "API Request Succeeds")
        
        let request = ApiRequest(path: "/languages") { response in
            /*if let error = response.error {
                print("API error: ", error)
            }*/
            XCTAssertTrue(response.succeeded) // Assert request succeeded
            XCTAssert(response.error == nil) // Assert there was no error
            
            expectation.fulfill() // Saying the async stuff is done
        }
        
        request.makeRequest() // Make the request to the server
        
        // Wait for the expectation to be fulfilled before
        // ending the test
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testInvalidDataFromAPI() {
        // Make a request to the API with non-JSON data received
        
        let expectation = self.expectation(description: "API Request Succeeds")
        
        let request = ApiRequest(path: "/languages?invalidJSON=1") { response in
            XCTAssertTrue(response.failed) // Assert there WAS an error
            
            expectation.fulfill() // Saying the async stuff is done
        }
        
        request.makeRequest()
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testInvalidTokenFromAPI() {
        // Make a request to the API with an invalid token received
        let expectation = self.expectation(description: "API Request Succeeds")
        
        let request = ApiRequest(path: "/languages?invalidToken=1", callback: { response in
            XCTAssertTrue(response.failed) // Assert there WAS an error
            XCTAssertNil(response.data) // Data should be disregarded for invalid tokens
            
            expectation.fulfill() // Saying the async stuff is done
        })
        
        request.makeRequest()
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testGetAvailableLanguages() {
        let expectation = self.expectation(description: "Languages fetched")
        
        LanguageManager.cacheAvailableLanguages { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testInvalidURLFails() {
        let expectation = self.expectation(description: "Request completes")
        
        iVerbs.Api.baseURL = "https://notarealhostname.abc"
        
        let request = ApiRequest(path: "test") { response in
            XCTAssertTrue(response.failed)
            expectation.fulfill()
        }
        request.makeRequest()
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func DISABLED_testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
