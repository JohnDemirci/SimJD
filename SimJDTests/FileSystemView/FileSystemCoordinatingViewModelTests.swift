//
//  FileSystemCoordinatingViewModelTests.swift
//  SimJD
//
//  Created by John Demirci on 1/19/25.
//

import XCTest
@testable import SimJD

@MainActor
final class FileSystemCoordinatingViewModelTests: XCTestCase {
    private var viewModel: FileSystemCoordinatingViewModel!

    override func setUp() {
        super.setUp()
        viewModel = .init()
    }

    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }
}

// MARK: - Handle Action Tests

extension FileSystemCoordinatingViewModelTests {
    func testHandleActionFileSystemViewEventDidFailToFetchFilesChangesAlert() {
        viewModel.handleAction(.fileSystemViewEvent(.didFailToFetchFiles))
        XCTAssertEqual(viewModel.alert, .fileFetchingError)
    }

    func testHandleActionFileSystemViewEventDidFailToFindSelectedFileChangesAlert() {
        viewModel.handleAction(.fileSystemViewEvent(.didFailToFindSelectedFile))
        XCTAssertEqual(viewModel.alert, .fileFindingError)
    }

    func testHandleActionFileSystemViewEventDidFailToOpenFileChangesAlert() {
        viewModel.handleAction(.fileSystemViewEvent(.didFailToOpenFile))
        XCTAssertEqual(viewModel.alert, .fileOpeningError)
    }
}
