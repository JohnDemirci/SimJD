//
//  FileSystemNavigatorTests.swift
//  SimJD
//
//  Created by John Demirci on 1/19/25.
//

import XCTest
@testable import SimJD

@MainActor
final class FileSystemNavigatorTests: XCTestCase {
    private var navigator: FileSystemNavigator!

    override func setUp() {
        super.setUp()
        navigator = .init()
    }

    override func tearDown() {
        super.tearDown()
        navigator = nil
    }
}

// MARK: - Testing Pushing

extension FileSystemNavigatorTests {
    func testPushInstalledApplicationsSuccess() {
        navigator.add(.installedApplications)
        XCTAssertEqual(navigator.last, .installedApplications)
    }

    func testPushInstalledApplicationDetailsSuccess() {
        navigator.add(.installedApplicationDetails(.sample))
        XCTAssertEqual(navigator.last, .installedApplicationDetails(.sample))
    }

    func testPushFileSystemSuccess() {
        guard let url = URL(string: "https://github.com") else {
            XCTFail("Failed to create URL")
            return
        }

        navigator.add(.fileSystem(url: url))
        XCTAssertEqual(navigator.last, .fileSystem(url: url))
    }
}

// MARK: - Testing Popping

extension FileSystemNavigatorTests {
    func testPoppingMakesLastStackNil() {
        self.navigator = .init(initialDestination: .installedApplications)
        navigator.pop()
        XCTAssertNil(navigator.last)
    }

    func testPoppingMakesLastStackPrevious() {
        self.navigator = .init(initialDestination: .installedApplications)
        navigator.add(.installedApplicationDetails(.sample))
        navigator.pop()
        XCTAssertEqual(navigator.last, .installedApplications)
    }
}

// MARK: - Testing Resetting the Stack

extension FileSystemNavigatorTests {
    func testResettingStack() {
        navigator = .init(initialDestination: .installedApplications)

        for _ in 0..<10 {
            navigator.add(.installedApplications)
        }

        navigator.resetTo(.installedApplicationDetails(.sample))
        XCTAssertEqual(navigator.last, .installedApplicationDetails(.sample))
        XCTAssertEqual(navigator.stack.count, 1)
    }
}
