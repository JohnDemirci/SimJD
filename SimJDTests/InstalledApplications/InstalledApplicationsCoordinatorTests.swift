//
//  InstalledApplicationsCoordinatorTests.swift
//  SimJD
//
//  Created by John Demirci on 4/20/25.
//

import XCTest
@testable import SimJD

@MainActor
final class InstalledApplicationsCoordinatorTests: XCTestCase {
    private var coordinator: InstalledApplicationsCoordinator!

    override func setUp() {
        super.setUp()
        coordinator = .init()
    }

    override func tearDown() {
        super.tearDown()
        coordinator = nil
    }
}

extension InstalledApplicationsCoordinatorTests {
    func testJDAlert_forSimulatorNotBooted() {
        let alert = coordinator.jdAlert(.simulatorNotBooted)
        XCTAssertEqual(alert.title, "Simulator not booted")
        XCTAssertEqual(alert.message, "Please boot your simulator before continuing")
    }

    func testJDAlert_forDidFailToRetrieveApp() {
        let alert = coordinator.jdAlert(.didFailToRetrieveApp)
        XCTAssertEqual(alert.title, "Failed retrieving installed application")
        XCTAssertEqual(alert.message, "Please check the simulator state and try again")
    }

    func testJDAlert_forDidFailToFetchInstalledApps() {
        let alert = coordinator.jdAlert(.didFailToFetchInstalledApps)
        XCTAssertEqual(alert.title, "Failed fetching installed apps")
        XCTAssertNil(alert.message)
    }

    func testJDAlert_forCouldNotOpenUserDefaults() {
        let alert = coordinator.jdAlert(.couldNotOpenUserDefaults)
        XCTAssertEqual(alert.title, "Unable to open User Defaults Folder")
        XCTAssertNil(alert.message)
    }

    func testJDAlert_forDidSelectRemoveUserDefaults_hasConfirmationButtons() {
        let app = InstalledAppDetail.apple
        let alert = coordinator.jdAlert(.didSelectRemoveUserDefaults(app))
        XCTAssertEqual(alert.title, "Remove User Defaults")
        XCTAssertEqual(alert.message, "Are you sure about removing the user defaults folder for this application?")
        XCTAssertNotNil(alert.button1)
        XCTAssertNotNil(alert.button2)
        XCTAssertEqual(alert.button1?.title, "Remove")
        XCTAssertEqual(alert.button2?.title, "Cancel")
    }

    func testJDAlert_forDidSelectUninstallApplication_hasConfirmationButtons() {
        let simulator = Simulator.iphone
        let app = InstalledAppDetail.apple
        let alert = coordinator.jdAlert(.didSelectUnisntallApplication(simulator, app))
        XCTAssertEqual(alert.title, "Remove Application from Simulator")
        XCTAssertEqual(alert.message, "Are you sure about removing the application?")
        XCTAssertNotNil(alert.button1)
        XCTAssertNotNil(alert.button2)
        XCTAssertEqual(alert.button1?.title, "Remove")
        XCTAssertEqual(alert.button2?.title, "Cancel")
    }

    func testJDAlert_forCouldNotRemoveApplication() {
        let alert = coordinator.jdAlert(.couldNotRemoveApplication)
        XCTAssertEqual(alert.title, "Could not Remove Application")
        XCTAssertNil(alert.message)
    }

    func testJDAlert_forCouldNotRemoveUserDefaults() {
        let alert = coordinator.jdAlert(.couldNotRemoveUserDefaults)
        XCTAssertEqual(alert.title, "Could not Remove User Defaults")
        XCTAssertNil(alert.message)
    }

    func testJDAlert_forDidUninstallApplication() {
        let alert = coordinator.jdAlert(.didUnisntallApplication(.apple))
        XCTAssertEqual(alert.title, "Successfully Uninstalled Application")
        XCTAssertNil(alert.message)
    }

    func testJDAlert_forDidRemoveUserDefaults() {
        let alert = coordinator.jdAlert(.didRemoveUserDefaults)
        XCTAssertEqual(alert.title, "User Defaults Removed")
        XCTAssertNil(alert.message)
    }

    func testJDAlert_forDidFailToFetchFiles() {
        let alert = coordinator.jdAlert(.didFailToFetchFiles)
        XCTAssertEqual(alert.title, "Failed to Fetch Files")
        XCTAssertNil(alert.message)
    }

    func testJDAlert_forDidFailToFindSelectedFile() {
        let alert = coordinator.jdAlert(.didFailToFindSelectedFile)
        XCTAssertEqual(alert.title, "Failed to Find Selected File")
        XCTAssertNil(alert.message)
    }

    func testJDAlert_forDidFailToOpenFile() {
        let alert = coordinator.jdAlert(.didFailToOpenFile)
        XCTAssertEqual(alert.title, "Failed to Open File")
        XCTAssertNil(alert.message)
    }

    func testJDAlert_forNoSelectedSimulator() {
        let alert = coordinator.jdAlert(.noSelectedSimulator)
        XCTAssertEqual(alert.title, "No Simulator Selected")
        XCTAssertNil(alert.message)
    }
}

// test handle action
extension InstalledApplicationsCoordinatorTests {
    func testDidFailToFetchInstalledApps() {
        coordinator.handleAction(.installedApplicationsViewModelEvent(.didFailToFetchInstalledApps(Failure.message("Error"))))

        XCTAssertEqual(coordinator.alert, .didFailToFetchInstalledApps)
    }

    func testDidSelectApp() {
        coordinator.handleAction(.installedApplicationsViewModelEvent(.didSelectApp(.apple)))

        XCTAssertEqual(coordinator.destination, [.installedApplicationDetails(.apple)])
    }

    func testDidFailToRetrieveApplication() {
        coordinator.handleAction(.installedApplicationsViewModelEvent(.didFailToRetrieveApplication))

        XCTAssertEqual(coordinator.alert, .didFailToRetrieveApp)
    }

    func testSimulatorNotBooted() {
        coordinator.handleAction(.installedApplicationsViewModelEvent(.simulatorNotBooted))

        XCTAssertEqual(coordinator.alert, .simulatorNotBooted)
    }

    func testCouldNotOpenUserDefaults() {
        coordinator.handleAction(.installedApplicationDetailViewEvent(.couldNotOpenUserDefaults(.apple)))

        XCTAssertEqual(coordinator.alert, .couldNotOpenUserDefaults)
    }

    func testDidSelectRemoveUserDefaults() {
        coordinator.handleAction(.installedApplicationDetailViewEvent(.didSelectRemoveUserDefaults(.apple)))

        XCTAssertEqual(coordinator.alert, .didSelectRemoveUserDefaults(.apple))
    }

    func testDidSelectUninstallApplication() {
        let client = SimulatorClient
            .testing
            .mutate(_fetchSimulatorDictionary: {
                return .success([.iOS("18"): [.iphone]])
            })

        let manager = SimulatorManager(client: client)
        manager.fetchSimulators()

        coordinator = .init(
            simulatorManager: manager
        )

        coordinator.handleAction(.installedApplicationDetailViewEvent(.didSelectUninstallApplication(.apple)))

        XCTAssertEqual(coordinator.alert, .didSelectUnisntallApplication(.iphone, .apple))
    }

    func testDidSelectUninstallApplicationWhenSelectedSimulatorNil() {
		let client = SimulatorClient.testing
		let manager = SimulatorManager(client: client)

		coordinator = .init(simulatorManager: manager)
		coordinator.handleAction(
			.installedApplicationDetailViewEvent(
				.didSelectUninstallApplication(.apple)
			)
		)

        XCTAssertEqual(coordinator.alert, .noSelectedSimulator)
    }

	func testDidSelectApplicationSandboxData() {
		coordinator.handleAction(.installedApplicationDetailViewEvent(.didSelectApplicationSandboxData(.apple)))

		guard let path = InstalledAppDetail.apple.dataContainer else {
			XCTFail("unexpexted")
			return
		}

		let expandedPath = NSString(string: path).expandingTildeInPath
		let fileURL = URL(fileURLWithPath: expandedPath)

		XCTAssertEqual(coordinator.destination, [.folder(fileURL)])
	}

	func testDidSelectApplicationSandboxDataWhenContainerPathIsNik() {
		coordinator.handleAction(.installedApplicationDetailViewEvent(.didSelectApplicationSandboxData(.containerless)))

		guard let _ = InstalledAppDetail.containerless.dataContainer else {
			XCTAssertTrue(coordinator.destination.isEmpty)
			return
		}

		XCTFail("unexpected")
	}

	func testDidSelectOpenUserDefaults() {
		let folderClient = FolderClient
			.testing
			.mutate(_openUserDefaults: { _, _ in
				return .success(())
			})

		let manager = FolderManager(folderClient)

		coordinator = .init(folderManager: manager)

		coordinator.handleAction(.installedApplicationDetailViewEvent(.didSelectOpenUserDefaults(.apple)))

		XCTAssertNil(coordinator.alert)
	}

	func testDidSelectOpenUserDefaultsFailure() {
		let folderClient = FolderClient
			.testing
			.mutate(_openUserDefaults: { _, _ in
				return .failure(Failure.message("Error"))
			})

		let manager = FolderManager(folderClient)

		coordinator = .init(folderManager: manager)

		coordinator.handleAction(.installedApplicationDetailViewEvent(.didSelectOpenUserDefaults(.apple)))

		XCTAssertEqual(coordinator.alert, .couldNotOpenUserDefaults)
	}

	func testDidFailToFetchFiles() {
		coordinator.handleAction(.documentFolderViewModelEvent(.didFailToFetchFiles))

		XCTAssertEqual(coordinator.alert, .didFailToFetchFiles)
	}

	func testCouldNotFindSelectedFile() {
		coordinator.handleAction(.documentFolderViewModelEvent(.didFailToFindSelectedFile))

		XCTAssertEqual(coordinator.alert, .didFailToFindSelectedFile)
	}

	func testDidFailToOpenFile() {
		coordinator.handleAction(.documentFolderViewModelEvent(.didFailToOpenFile))

		XCTAssertEqual(coordinator.alert, .didFailToOpenFile)
	}

	func testHandleDidSelectFile() {
		coordinator.handleAction(.documentFolderViewModelEvent(.didSelect(.sample)))

		XCTAssertEqual(coordinator.destination, [.folder(FileItem.sample.url)])
	}

	func testHandleDidSelectOpenInFinder() {
		let folderClient = FolderClient
			.testing
			.mutate(_openFile: { _ in
				return .success(())
			})

		let folderManager = FolderManager(folderClient)

		coordinator = .init(folderManager: folderManager)

		coordinator.handleAction(.documentFolderViewModelEvent(.didSelectOpenInFinder(.sample)))

		XCTAssertNil(coordinator.alert)
	}

	func testHandleDidSelectOpenInFinderFailure() {
		let folderClient = FolderClient
			.testing
			.mutate(_openFile: { _ in
				return .failure(Failure.message("Error"))
			})

		let folderManager = FolderManager(folderClient)

		coordinator = .init(folderManager: folderManager)

		coordinator.handleAction(.documentFolderViewModelEvent(.didSelectOpenInFinder(.sample)))

		XCTAssertEqual(coordinator.alert, .didFailToOpenFile)
	}
}

private extension InstalledAppDetail {
    static let apple: Self = .init(
        applicationType: "User",
        bundle: "AppleBundle",
        displayName: "Apple",
        bundleIdentifier: "Apple",
        bundleName: "Apple",
        bundleVersion: "1.2.3",
        dataContainer: "AppleContainer",
        path: "ApplePath"
    )

    static let samsung: Self = .init(
        applicationType: "User",
        bundle: "SamsungBundle",
        displayName: "Samsung",
        bundleIdentifier: "Samsung",
        bundleName: "Samsung",
        bundleVersion: "1.2.3",
        dataContainer: "SamsungContainer",
        path: "SamsungPath"
    )

	static let containerless: Self = .init(
		applicationType: "User",
		bundle: "Containerless",
		displayName: "Containerless",
		bundleIdentifier: "Containerless",
		bundleName: "Containerless",
		bundleVersion: "1.2.3",
		dataContainer: nil,
		path: "Containerless"
	)
}

private extension FileItem {
	static let sample: Self = .init(
		name: "one",
		url: .applicationDirectory,
		isDirectory: true,
		creationDate: nil,
		modificationDate: nil,
		size: nil
	)
}

private extension Simulator {
    static let iphone: Self = .init()
}
