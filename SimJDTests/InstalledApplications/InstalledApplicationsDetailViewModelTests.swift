//
//  InstalledApplicationsDetailViewModelTests.swift
//  SimJD
//
//  Created by John Demirci on 4/19/25.
//

import XCTest
@testable import SimJD

@MainActor
final class InstalledApplicationsDetailViewModelTests: XCTestCase {

    func testActionsList_containsAllExpectedActions() {
        let mock = EventHandlerMock()
        let viewModel = InstalledApplicationDetailViewModel(installedApplication: .apple, sendEvent: mock.handle)

        let actionNames = viewModel.actions.map(\.name)

        XCTAssertEqual(actionNames, [
            "Application Sandbox Data",
            "Info.plist",
            "Open User Defaults",
            "Remove UserDefaults",
            "Uninstall Application"
        ])
    }

    func testActionCallbacks_sendCorrectEvents() {
        let mock = EventHandlerMock()
        let viewModel = InstalledApplicationDetailViewModel(installedApplication: .apple, sendEvent: mock.handle)

        viewModel.actions.first(where: { $0.name == "Application Sandbox Data" })?.action()
        XCTAssertEqual(mock.event, .didSelectApplicationSandboxData(.apple))

        viewModel.actions.first(where: { $0.name == "Open User Defaults" })?.action()
        XCTAssertEqual(mock.event, .didSelectOpenUserDefaults(.apple))

        viewModel.actions.first(where: { $0.name == "Remove UserDefaults" })?.action()
        XCTAssertEqual(mock.event, .didSelectRemoveUserDefaults(.apple))

        viewModel.actions.first(where: { $0.name == "Uninstall Application" })?.action()
        XCTAssertEqual(mock.event, .didSelectUninstallApplication(.apple))
    }

    func testDidSelectAction_executesCorrectAction() {
        let mock = EventHandlerMock()
        let viewModel = InstalledApplicationDetailViewModel(installedApplication: .apple, sendEvent: mock.handle)

        for action in viewModel.actions {
            mock.event = nil  // Reset before each test
            viewModel.didSelectAction([action.id])

            switch action.name {
            case "Application Sandbox Data":
                XCTAssertEqual(mock.event, .didSelectApplicationSandboxData(.apple))
            case "Open User Defaults":
                XCTAssertEqual(mock.event, .didSelectOpenUserDefaults(.apple))
            case "Remove UserDefaults":
                XCTAssertEqual(mock.event, .didSelectRemoveUserDefaults(.apple))
            case "Uninstall Application":
                XCTAssertEqual(mock.event, .didSelectUninstallApplication(.apple))
            case "Info.plist":
                XCTAssertEqual(mock.event, .didSelectInfoPlist(.apple))
            default:
                XCTFail("Unexpected action name: \(action.name)")
            }
        }
    }
}

private final class EventHandlerMock {
    var event: InstalledApplicationDetailViewModel.Event?

    func handle(_ event: InstalledApplicationDetailViewModel.Event) {
        self.event = event
    }
}

private extension InstalledAppDetail {
    static let apple: Self = .init(
        applicationType: "User",
        bundle: "AppleBundle",
        bundleIdentifier: "Apple",
        bundleName: "Apple",
        bundleVersion: "1.2.3",
        dataContainer: "AppleContainer",
        displayName: "Apple",
        path: "ApplePath"
    )

    static let samsung: Self = .init(
        applicationType: "User",
        bundle: "SamsungBundle",
        bundleIdentifier: "Samsung",
        bundleName: "Samsung",
        bundleVersion: "1.2.3",
        dataContainer: "SamsungContainer",
        displayName: "Samsung",
        path: "SamsungPath"
    )
}
