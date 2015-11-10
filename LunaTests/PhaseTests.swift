//
//  PhaseTests.swift
//  Luna
//
//  Created by Andrew Shepard on 4/14/15.
//  Copyright (c) 2015 Andrew Shepard. All rights reserved.
//

import UIKit
import XCTest

class PhaseTests: XCTestCase {

    func testPhasesAreCreatedFromJSON() {
        let file = NSBundle(forClass: self.dynamicType).pathForResource("moonphases", ofType: "json")
        let data = NSData(contentsOfFile: file!)
        
        guard let result = data?.toJSON() else { return XCTFail("No data was found") }
        
        switch result {
        case .Success(let json):
            if case .Success(let phases) = Phase.phasesFromJSON(json) {
                XCTAssertEqual(phases.count, 7, "Phases count is incorrect")
            }
        case .Failure:
            XCTFail("Failing JSONResult was found")
        }
    }
    
    func testPhaseIsCreatedFromJSON() {
        let file = NSBundle(forClass: self.dynamicType).pathForResource("moonphases", ofType: "json")
        let data = NSData(contentsOfFile: file!)
        
        guard let result = data?.toJSON() else { return XCTFail("No data was found") }
        
        switch result {
        case .Success(let json):
            if let response = json["response"] as? [JSON],
                let phaseObj = response.first,
                case .Success(let phase) = Phase.phaseFromJSON(phaseObj) {
                    XCTAssertEqual(phase.name, "new moon", "Phase name is incorrect")
            }
        case .Failure:
            XCTFail("Failing JSONResult was found")
        }
    }
}
