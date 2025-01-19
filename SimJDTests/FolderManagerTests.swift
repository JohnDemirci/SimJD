//
//  FolderManagerTests.swift
//  SimJD
//
//  Created by John Demirci on 1/14/25.
//

import XCTest
@testable import SimJD

final class FolderManagerTests: XCTestCase {
    private var manager: FolderManager!
    private var folderClient: FolderClient!
    private var simulatorClient: SimulatorClient!

    override func setUp() {
        super.setUp()
        folderClient = .testing
        simulatorClient = .testing
        manager = .init(client: folderClient, simulatorClient: simulatorClient)
    }

    override func tearDown() {
        super.tearDown()
        manager = nil
    }

    func updateManager() {
        manager = .init(client: folderClient, simulatorClient: simulatorClient)
    }
}

// MARK: - Testing Open Documents Folder

extension FolderManagerTests {
    func testOpenDocumentsFolderSuccess() {
        folderClient.mutate(_openSimulatorDocuments: { _ in
            return .success(())
        })

        updateManager()

        switch manager.openDocumentsFolder(.bootedSimulator) {
        case .success:
            break
        case .failure:
            XCTFail()
        }
    }

    func testOpenDocumentsFolderFailure() {
        folderClient.mutate(_openSimulatorDocuments: { _ in
            return .failure(Failure.message("Error"))
        })

        updateManager()

        switch manager.openDocumentsFolder(.bootedSimulator) {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }
}

// MARK: - Testing Open UserDefaults Folder

extension FolderManagerTests {
    func testOpenUserDefaultsFolderSuccess() {
        folderClient.mutate(_openUserDefaults: { _,_  in
            return .success(())
        })
        
        updateManager()

        switch manager.openUserDefaultsFolder(.withContainerAndBundleID) {
        case .success:
            break
        case .failure:
            XCTFail()
        }
    }

    func testOpenUserDefaultsFolderFailure() {
        folderClient.mutate(_openUserDefaults: { _,_ in
            return .failure(Failure.message("Error"))
        })
        
        updateManager()
        
        switch manager.openUserDefaultsFolder(.withContainerAndBundleID) {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }

    func testOpenUserDefaultsFolderFailsWhenNoContainerExists() {
        switch manager.openUserDefaultsFolder(.withOnlyBundleID) {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }

    func testOpenUserDefaultsFailsWhenNoBundleIDExists() {
        switch manager.openUserDefaultsFolder(.withOnlyContainer) {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }

    func testOpenApplicationSandboxFolderSuccess() {
        folderClient.mutate(_openAppSandboxFolder: { _ in
            return .success(())
        })

        updateManager()

        switch manager.openApplicationSupport(.withContainerAndBundleID) {
        case .success:
            break
        case .failure:
            XCTFail()
        }
    }

    func testOpenApplicationSandboxFolderFailure() {
        folderClient.mutate(_openAppSandboxFolder: { _ in
            return .failure(Failure.message("Errpr"))
        })
        
        updateManager()
        
        switch manager.openApplicationSupport(.withContainerAndBundleID) {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }

    func testOpenApplicationSandboxFailsWhenNoContainerExists() {
        switch manager.openApplicationSupport(.withOnlyBundleID) {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }
}

// MARK: - Testing Remove User Defaults

extension FolderManagerTests {
    func testDeleteUserDefaultsSuccess() {
        folderClient.mutate(_removeUserDefaults: { _, _ in
            return .success(())
        })
        updateManager()

        switch manager.removeUserDefaults(.withContainerAndBundleID) {
        case .success:
            break
        case .failure:
            XCTFail("Should not have failed")
        }
    }

    func testDeleteUserDefaultsFailure() {
        folderClient.mutate(_removeUserDefaults: { _, _ in
            return .failure(Failure.message("Error"))
        })
        updateManager()
        
        switch manager.removeUserDefaults(.withContainerAndBundleID) {
        case .success:
            XCTFail("Should not have succeeded")
        case .failure:
            break
        }
    }

    func testRemoveUserDefaultsWithOnlyContainer() {
        switch manager.removeUserDefaults(.withOnlyContainer) {
        case .success:
            XCTFail("Both the bundle id and the container should exist to delete")
        case .failure:
            break
        }
    }

    func testRemoveUserDefaultsWithOnlyBundleID() {
        switch manager.removeUserDefaults(.withOnlyBundleID) {
        case .success:
            XCTFail("Both the bundle id and the container should exist to delete")
        case .failure:
            break
        }
    }
}

// MARK: - Testing Uninstalling Application

extension FolderManagerTests {
    func testUninstallApplicationSuccess() {
        simulatorClient.mutate(_uninstallApp: { _, _ in
            return .success(())
        })
        updateManager()

        switch manager.uninstall(.withContainerAndBundleID, simulatorID: "something") {
        case .success:
            break
        case .failure:
            XCTFail()
        }
    }

    func testUninstallApplicationFailure() {
        simulatorClient.mutate(_uninstallApp: { _, _ in
            return .failure(Failure.message("Error"))
        })
        updateManager()
        
        switch manager.uninstall(.withContainerAndBundleID, simulatorID: "something") {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }

    func testUnisntallSystemApplicationFails() {
        simulatorClient.mutate(_uninstallApp: { _, _ in
            return .success(())
        })
        updateManager()

        switch manager.uninstall(.systemApp, simulatorID: "uid") {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }

    func testUninstallApplicationWithOnlyContainer() {
        simulatorClient.mutate(_uninstallApp: { _, _ in
            return .success(())
        })
        updateManager()
        
        switch manager.uninstall(.withOnlyContainer, simulatorID: "uid") {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }
}

extension InstalledAppDetail {
    static let withContainerAndBundleID = InstalledAppDetail(
        bundleIdentifier: "bundleID",
        dataContainer: "container"
    )

    static let withOnlyContainer = InstalledAppDetail(dataContainer: "Container")

    static let withOnlyBundleID = InstalledAppDetail(bundleIdentifier: "BundleID")
    
    static let systemApp = InstalledAppDetail(
        applicationType: "System",
        bundle: "something",
        displayName: "name",
        bundleIdentifier: "BundleID",
        bundleName: "bundlename",
        bundleVersion: "bundleversion",
        dataContainer: "Container",
        path: "path"
    )
}
