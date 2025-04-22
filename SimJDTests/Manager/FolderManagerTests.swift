//
//  FolderManagerTests.swift
//  SimJD
//
//  Created by John Demirci on 4/22/25.
//

import XCTest
@testable import SimJD

final class FolderManagerTests: XCTestCase {
    private var folderManager: FolderManager!

    override func setUp() {
        super.setUp()
        self.initializeManager()
    }

    override func tearDown() {
        super.tearDown()
        self.folderManager = nil
    }

    func testOpenUserDefaultsFolderSuccess() {
        initializeManager(openUserDefaults: { _,_  in
            return .success(())
        })

        switch folderManager.openUserDefaultsFolder(.sample) {
        case .success:
            break
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testOpenUserDefaultsFolderWithoutDataContainer() {
        initializeManager(openUserDefaults: { _,_  in
            return .success(())
        })

        switch folderManager.openUserDefaultsFolder(.sampleWithoutContainer) {
        case .success:
            XCTFail("Should not succeed")
        case .failure(let error):
            XCTAssertEqual(
                error,
                Failure.message("No User Defaults Folder")
            )
        }
    }

    func testOpenUserDefaultsFolderWithoutBundleID() {
        initializeManager(openUserDefaults: { _,_  in
            return .success(())
        })

        switch folderManager.openUserDefaultsFolder(.sampleWithoutBundleID) {
        case .success:
            XCTFail("Should not succeed")
        case .failure(let error):
            XCTAssertEqual(
                error,
                Failure.message("No Bundle Identifier")
            )
        }
    }

    func testOpenUserDefaultsfolderFailure() {
        let failure = Failure.message("Error")

        initializeManager(openUserDefaults: { _,_  in
            return .failure(failure)
        })

        switch folderManager.openUserDefaultsFolder(.sample) {
        case .success:
            XCTFail("Should not succeed")
        case .failure(let error):
            XCTAssertEqual(error, failure)
        }
    }

    func testRemoveUserDefaultsFolderSuccess() {
        initializeManager(removeUserDefaults: { _,_  in
            return .success(())
        })

        switch folderManager.removeUserDefaults(.sample) {
        case .success:
            break
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRemoveUserDefaultsFolderWithoutDataContainer() {
        initializeManager(removeUserDefaults: { _,_  in
            return .success(())
        })

        switch folderManager.removeUserDefaults(.sampleWithoutContainer) {
        case .success:
            XCTFail("Should not succeed")
        case .failure(let error):
            XCTAssertEqual(
                error,
                Failure.message("No User Defaults Folder")
            )
        }
    }

    func testRemoveUserDefaultsFolderWithoutBundleID() {
        initializeManager(removeUserDefaults: { _,_  in
            return .success(())
        })

        switch folderManager.removeUserDefaults(.sampleWithoutBundleID) {
        case .success:
            XCTFail("Should not succeed")
        case .failure(let error):
            XCTAssertEqual(
                error,
                Failure.message("No Bundle Identifier")
            )
        }
    }

    func testRemoveUserDefaultsfolderFailure() {
        let failure = Failure.message("Error")

        initializeManager(removeUserDefaults: { _,_  in
            return .failure(failure)
        })

        switch folderManager.removeUserDefaults(.sample) {
        case .success:
            XCTFail("Should not succeed")
        case .failure(let error):
            XCTAssertEqual(error, failure)
        }
    }

    func testOpenFileSuccess() {
        initializeManager(openFile: { _ in
            return .success(())
        })

        switch folderManager.openFile(.applicationDirectory) {
        case .success:
            break
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func testOpenFileFailure() {
        let failure = Failure.message("Error")

        initializeManager(openFile: { _ in
            return .failure(failure)
        })
        
        switch folderManager.openFile(.applicationDirectory) {
        case .success:
            XCTFail("Should not succeed")
        case .failure(let error):
            XCTAssertEqual(error, failure)
        }
    }

    func testFetchFileItemsSuccess() {
        let fileItems: [FileItem] = [.sample, .sample2]

        initializeManager(fetchFileItems: { _ in
            return .success(fileItems)
        })
        
        switch folderManager.fetchFileItems(at: .applicationDirectory) {
        case .success(let items):
            XCTAssertEqual(items, fileItems)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func fetchFileItemEmptyArraySuccess() {
        let fileItems: [FileItem] = []

        initializeManager(fetchFileItems: { _ in
            return .success(fileItems)
        })

        switch folderManager.fetchFileItems(at: .applicationDirectory) {
        case .success(let items):
            XCTAssertEqual(items, fileItems)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func fetchFileItemFailure() {
        let failure = Failure.message("Error")

        initializeManager(fetchFileItems: { _ in
            return .failure(failure)
        })
        
        switch folderManager.fetchFileItems(at: .applicationDirectory) {
        case .success:
            XCTFail("Should not succeed")
        case .failure(let error):
            XCTAssertEqual(error, failure)
        }
    }
}

extension FolderManagerTests {
    func initializeManager(
        openUserDefaults: ((String, String) -> Result<Void, Failure>)? = nil,
        removeUserDefaults: ((String, String) -> Result<Void, Failure>)? = nil,
        openFile: ((URL) -> Result<Void, Failure>)? = nil,
        fetchFileItems: ((URL) -> Result<[FileItem], Failure>)? = nil
    ) {
        let client = FolderClient
            .testing
            .mutate(
                _openUserDefaults: openUserDefaults,
                _removeUserDefaults: removeUserDefaults,
                _openFile: openFile,
                _fetchFileItems: fetchFileItems
            )

        self.folderManager = .init(client)
    }
}

private extension InstalledAppDetail {
    static let sample: Self = .init(
        applicationType: "User",
        bundle: "Sample",
        displayName: "aAmple",
        bundleIdentifier: "Sample",
        bundleName: "Sample",
        bundleVersion: "Sample",
        dataContainer: "Sample",
        path: "Sample"
    )

    static let sampleWithoutContainer: Self = .init(
        applicationType: "User",
        bundle: "Sample",
        displayName: "aAmple",
        bundleIdentifier: "Sample",
        bundleName: "Sample",
        bundleVersion: "Sample",
        dataContainer: nil,
        path: "Sample"
    )

    static let sampleWithoutBundleID: Self = .init(
        applicationType: "User",
        bundle: "Sample",
        displayName: "aAmple",
        bundleIdentifier: nil,
        bundleName: "Sample",
        bundleVersion: "Sample",
        dataContainer: "Sample",
        path: "Sample"
    )
}

private extension FileItem {
    static let sample: Self = .init(
        name: "1",
        url: .applicationDirectory,
        isDirectory: true,
        creationDate: nil,
        modificationDate: nil,
        size: nil
    )

    static let sample2: Self = .init(
        name: "2",
        url: .applicationDirectory,
        isDirectory: false,
        creationDate: nil,
        modificationDate: nil,
        size: nil
    )
}
