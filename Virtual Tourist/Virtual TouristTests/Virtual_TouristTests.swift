//
//  Virtual_TouristTests.swift
//  Virtual TouristTests
//
//  Created by Matthew Flood on 5/14/23.
//

import XCTest
@testable import Virtual_Tourist

final class Virtual_TouristTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPhotoSearch() throws {
    
        // Set up an expectation for the async function to complete
        let expectation = self.expectation(description: "Photo Search should perform callback")
        
        FlickrApiClient.FlickrApiKey = API_KEY
        
        FlickrApiClient.searchPhotos(lat: 37, lon: 126, callback: { result, error in
            
            XCTAssertEqual(result?.stat, "ok")
            
            // Fulfill the expectation to indicate that the async function has completed
            expectation.fulfill()
            
        })
        
        // Wait for the expectation to be fulfilled, or time out after 10 seconds
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
