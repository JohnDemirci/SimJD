//
//  DocumentFolderCoordinatorTests.swift
//  SimJD
//
//  Created by John Demirci on 4/20/25.
//

import XCTest
@testable import SimJD

@MainActor
final class DocumentFolderCoordinatorTests: XCTestCase {
	private var coordinator: DocumentFolderCoordinator!

	override func setUp() {
		super.setUp()
		coordinator = .init()
	}

	override func tearDown() {
		super.tearDown()
		coordinator = nil
	}
}

extension DocumentFolderCoordinatorTests {
	func testDidFailToFetchFiles() {
		coordinator.handleAction(.documentFolderViewEvent(.didFailToFetchFiles))

		XCTAssertEqual(coordinator.alert, .didFailToFetchFiles)
	}

	func testDidFailToFindSelectedFile() {
		coordinator.handleAction(.documentFolderViewEvent(.didFailToFindSelectedFile))

		XCTAssertEqual(coordinator.alert, .didFailToFindSelectedFile)
	}

	func testDidFailToOpenFile() {
		coordinator.handleAction(.documentFolderViewEvent(.didFailToOpenFile))

		XCTAssertEqual(coordinator.alert, .didFailToOpenFile)
	}

	func testDidSelectDirectoryFileItem() {
		coordinator.handleAction(.documentFolderViewEvent(.didSelect(.directory)))

		XCTAssertEqual(coordinator.destination, [.folder(FileItem.directory.url)])
	}

	func testDidSelectNonDirectoryFileItemSuccess() {
		let folderClient = FolderClient
			.testing
			.mutate(_openFile: { _ in
				return .success(())
			})

		let folderManager = FolderManager(folderClient)

		coordinator = .init(folderManager: folderManager)

		coordinator.handleAction(.documentFolderViewEvent(.didSelect(.nonDirectory)))

		XCTAssertNil(coordinator.alert)
		XCTAssertTrue(coordinator.destination.isEmpty)
	}

	func testDidSelectNonDirectoryFileItemFailure() {
		let folderClient = FolderClient
			.testing
			.mutate(_openFile: { _ in
				return .failure(Failure.message("Error"))
			})

		let folderManager = FolderManager(folderClient)

		coordinator = .init(folderManager: folderManager)

		coordinator.handleAction(.documentFolderViewEvent(.didSelect(.nonDirectory)))

		XCTAssertEqual(coordinator.alert, .didFailToOpenFile)
	}

	func testDidSelectOpenInFinder() {
		let folderClient = FolderClient
			.testing
			.mutate(_openFile: { _ in
				return .success(())
			})

		let manager = FolderManager(folderClient)

		coordinator = .init(folderManager: manager)

		coordinator.handleAction(.documentFolderViewEvent(.didSelectOpenInFinder(.directory)))

		XCTAssertNil(coordinator.alert)
		XCTAssertTrue(coordinator.destination.isEmpty)
	}

	func testDidSelectOpenInFinderFailure() {
		let folderClient = FolderClient
			.testing
			.mutate(_openFile: { _ in
				return .failure(Failure.message("Error"))
			})

		let manager = FolderManager(folderClient)

		coordinator = .init(folderManager: manager)

		coordinator.handleAction(.documentFolderViewEvent(.didSelectOpenInFinder(.directory)))

		XCTAssertEqual(coordinator.alert, .didFailToOpenFile)
	}
}

private extension FileItem {
	static let directory: Self = .init(
		name: "Directory",
		url: .applicationDirectory,
		isDirectory: true,
		creationDate: nil,
		modificationDate: nil,
		size: nil
	)

	static let nonDirectory: Self = .init(
		name: "Non-directory",
		url: .applicationDirectory,
		isDirectory: false,
		creationDate: nil,
		modificationDate: nil,
		size: nil
	)
}
