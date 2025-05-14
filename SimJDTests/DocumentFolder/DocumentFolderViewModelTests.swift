//
//  DocumentFolderViewModelTests.swift
//  SimJD
//
//  Created by John Demirci on 4/20/25.
//

import XCTest
@testable import SimJD

@MainActor
final class DocumentFolderViewModelTests: XCTestCase {
	private var viewModel: DocumentsFolderViewModel!
	private var copyboard: MockCopyboard!
	private var folderManager: FolderManager!
	private var eventHandler: EventHandler!

	private var url: URL {
		.applicationDirectory
	}

	override func setUp() {
		super.setUp()
		self.copyboard = .init()
		self.folderManager = .debug
		self.eventHandler = .init()
		self.viewModel = .init(
			folderURL: url,
			copyBoard: copyboard,
			folderManager: folderManager,
			sendEvent: { [weak self] event in
				self?.eventHandler.handle(event)
			}
		)
	}

	override func tearDown() {
		super.tearDown()
		self.copyboard = nil
		self.folderManager = nil
		self.viewModel = nil
	}
}

extension DocumentFolderViewModelTests {
	func testFetchFileItemsSuccess() {
		let client = FolderClient
			.testing
			.mutate(_fetchFileItems: { _ in
				return .success([.sample1, .sample2, .sample3])
			})

		self.folderManager = .init(client)

		self.viewModel = .init(
			folderURL: url,
			copyBoard: self.copyboard,
			folderManager: self.folderManager,
			sendEvent: { [weak self] event in
				self?.eventHandler.handle(event)
			}
		)

		viewModel.fetchFileItems()
		XCTAssertEqual(viewModel.items, [.sample1, .sample2, .sample3])
	}

	func testFetchFileItemsFailure() {
		let client = FolderClient
			.testing
			.mutate(_fetchFileItems: { _ in
				return .failure(Failure.message("error"))
			})

		self.folderManager = .init(client)

		self.viewModel = .init(
			folderURL: url,
			copyBoard: self.copyboard,
			folderManager: self.folderManager,
			sendEvent: { [weak self] event in
				self?.eventHandler.handle(event)
			}
		)

		viewModel.fetchFileItems()
		XCTAssertEqual(eventHandler.event, .didFailToFetchFiles)
	}

	func testDidDoubleClickOnEmptyArrayOfSelectedItems() {
		viewModel.didDoubleClickOn([])
		XCTAssertEqual(eventHandler.event, .didFailToFindSelectedFile)
	}

	func testDidDoubleClickOnNonExistingFileItem() {
		let client = FolderClient
			.testing
			.mutate(_fetchFileItems: { _ in
				return .success([.sample2])
			})

		self.folderManager = .init(client)

		self.viewModel = .init(
			folderURL: url,
			copyBoard: self.copyboard,
			folderManager: self.folderManager,
			sendEvent: { [weak self] event in
				self?.eventHandler.handle(event)
			}
		)

		viewModel.fetchFileItems()
		viewModel.didDoubleClickOn([FileItem.sample3.id])
		XCTAssertEqual(viewModel.selectedItem, FileItem.sample3.id)
		XCTAssertEqual(eventHandler.event, .didFailToFindSelectedFile)
	}

	func testDidDoubleClickOnSelectedItemSuccess() {
		let client = FolderClient
			.testing
			.mutate(_fetchFileItems: { _ in
				return .success([.sample2])
			})

		self.folderManager = .init(client)

		self.viewModel = .init(
			folderURL: url,
			copyBoard: self.copyboard,
			folderManager: self.folderManager,
			sendEvent: { [weak self] event in
				self?.eventHandler.handle(event)
			}
		)

		viewModel.fetchFileItems()
		viewModel.didDoubleClickOn([FileItem.sample2.id])
		XCTAssertEqual(viewModel.selectedItem, FileItem.sample2.id)
		XCTAssertEqual(eventHandler.event, .didSelect(.sample2))
	}

	func testDidSelectOpenInFinderSuccess() {
		let client = FolderClient
			.testing
			.mutate(_fetchFileItems: { _ in
				return .success([.sample2])
			})

		self.folderManager = .init(client)

		self.viewModel = .init(
			folderURL: url,
			copyBoard: self.copyboard,
			folderManager: self.folderManager,
			sendEvent: { [weak self] event in
				self?.eventHandler.handle(event)
			}
		)

		viewModel.fetchFileItems()
		viewModel.didSelectOpenInFinder([FileItem.sample2.id])
		XCTAssertEqual(eventHandler.event, .didSelectOpenInFinder(FileItem.sample2))
	}

	func testDidSelectOpenInFinderWithEmptySetDoesNothing() {
		let client = FolderClient
			.testing
			.mutate(_fetchFileItems: { _ in
				return .success([.sample2])
			})

		self.folderManager = .init(client)

		self.viewModel = .init(
			folderURL: url,
			copyBoard: self.copyboard,
			folderManager: self.folderManager,
			sendEvent: { [weak self] event in
				self?.eventHandler.handle(event)
			}
		)

		viewModel.fetchFileItems()
		viewModel.didSelectOpenInFinder([])
		XCTAssertNil(eventHandler.event)
		XCTAssertNil(viewModel.selectedItem)
	}

	func testDidSelectOpenInFinderForNonExistingFileItem() {
		let client = FolderClient
			.testing
			.mutate(_fetchFileItems: { _ in
				return .success([.sample2])
			})

		self.folderManager = .init(client)

		self.viewModel = .init(
			folderURL: url,
			copyBoard: self.copyboard,
			folderManager: self.folderManager,
			sendEvent: { [weak self] event in
				self?.eventHandler.handle(event)
			}
		)

		viewModel.fetchFileItems()
		viewModel.didSelectOpenInFinder([FileItem.sample3.id])
		XCTAssertNil(eventHandler.event)
		XCTAssertNil(viewModel.selectedItem)
	}

	func testDidCopyClipboardSuccess() {
		let client = FolderClient
			.testing
			.mutate(_fetchFileItems: { _ in
				return .success([.sample2])
			})

		self.folderManager = .init(client)

		self.viewModel = .init(
			folderURL: url,
			copyBoard: self.copyboard,
			folderManager: self.folderManager,
			sendEvent: { [weak self] event in
				self?.eventHandler.handle(event)
			}
		)

		viewModel.fetchFileItems()
		viewModel.didSelectCopyPathToClipboard([FileItem.sample2.id])
		XCTAssertEqual(copyboard.didCallCopy, FileItem.sample2.url.absoluteString)
		XCTAssertTrue(copyboard.didCallClear)
	}

	func testDidCopyClipboardWithEmptySetDoesNothing() {
		viewModel.didSelectCopyPathToClipboard([])
		XCTAssertFalse(copyboard.didCallClear)
		XCTAssertNil(copyboard.didCallCopy)
	}

	func testDidCopyClipboardWithNonExistingSetDoesNothing() {
		viewModel.didSelectCopyPathToClipboard([FileItem.sample2.id])
		XCTAssertFalse(copyboard.didCallClear)
		XCTAssertNil(copyboard.didCallCopy)
	}

	func testDidCopyClipboardWithNonMatchingExistingSetDoesNothing() {
		let client = FolderClient
			.testing
			.mutate(_fetchFileItems: { _ in
				return .success([.sample2])
			})

		self.folderManager = .init(client)

		self.viewModel = .init(
			folderURL: url,
			copyBoard: self.copyboard,
			folderManager: self.folderManager,
			sendEvent: { [weak self] event in
				self?.eventHandler.handle(event)
			}
		)

		viewModel.fetchFileItems()
		viewModel.didSelectCopyPathToClipboard([FileItem.sample1.id])
		XCTAssertFalse(copyboard.didCallClear)
		XCTAssertNil(copyboard.didCallCopy)
	}
}

private final class EventHandler {
	var event: DocumentsFolderViewModel.Event?

	func handle(_ event: DocumentsFolderViewModel.Event) {
		self.event = event
	}
}

private final class MockCopyboard: CopyBoardProtocol {
	var didCallClear: Bool = false
	var didCallCopy: String? = nil
	func clear() {
		didCallClear = true
	}
	
	func copy(_ text: String) {
		didCallCopy = text
	}
}

private extension FileItem {
    static let sample1: Self = FileItem(
        creationDate: nil,
        isDirectory: true,
        modificationDate: nil,
        name: "sample",
        size: nil,
        url: .applicationDirectory
	)

	static let sample2: Self = FileItem(
        creationDate: nil,
        isDirectory: true,
        modificationDate: nil,
        name: "sample2",
        size: nil,
        url: .applicationDirectory
	)

	static let sample3: Self = FileItem(
        creationDate: nil,
        isDirectory: true,
        modificationDate: nil,
        name: "sample3",
        size: nil,
        url: .applicationDirectory
	)
}
