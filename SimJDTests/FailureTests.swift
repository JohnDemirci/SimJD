//
//  FailureTests.swift
//  SimJD
//
//  Created by John Demirci on 1/19/25.
//

import XCTest
@testable import SimJD

final class FailureTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFailureDescriptionOne() {
        let failure = Failure.message("one")
        XCTAssertEqual(failure.description, "one")
    }

    func testFailureDescriptionTwo() {
        let failure = Failure.message("two")
        XCTAssertEqual(failure.description, "two")
    }

    func testFailureEquals() {
        let failure1 = Failure.message("one")
        let failure2 = Failure.message("one")

        XCTAssertEqual(failure1, failure2)
    }

    func testFailureNotEquals() {
        let failure1 = Failure.message("one")
        let failure2 = Failure.message("two")

        XCTAssertNotEqual(failure1, failure2)
    }
}
