//
//  InstalledApplicationsViewModelTests.swift
//  SimJD
//
//  Created by John Demirci on 4/16/25.
//

import XCTest
import Collections
@testable import SimJD

@MainActor
final class InstalledApplicationsViewModelTests: XCTestCase {
    private var viewModel: InstalledApplicationsViewModel!
    private var copyBoard: CopyBoardMock!
    private var eventHandler: EventHandler!
    private var manager: SimulatorManager!

    override func setUp() {
        super.setUp()
        self.eventHandler = .init()
        self.copyBoard = .init()
        self.manager = makeSimulatorManager()
        self.viewModel = .init(
            copyBoard: self.copyBoard,
            simulatorManager: manager,
            sendEvent: {
                self.eventHandler.handleEvent($0)
            }
        )
    }

    override func tearDown() {
        super.tearDown()
        self.eventHandler = nil
        self.copyBoard = nil
        self.viewModel = nil
        self.manager = nil
    }
}

extension InstalledApplicationsViewModelTests {
    func testSelectedSimulatorExistsUponInitialization() {
        manager.fetchSimulators()
        XCTAssertEqual(viewModel.selectedSimulator, .iphone16)
    }

    func testSelectedSimulatorIsNil() {
        let newManager = makeSimulatorManager(
            activeProcesses: {_ in
                return .success([])
            },
            installedApps: { _ in return .success([.sample1]) },
            simulatorDictionary: {
                return .success([:])
            }
        )

        self.viewModel = .init(
            copyBoard: self.copyBoard,
            simulatorManager: newManager,
            sendEvent: { _ in
                XCTFail("failure")
            }
        )

        XCTAssertNil(viewModel.selectedSimulator)

        viewModel.fetchInstalledApplications()

        XCTAssertNil(viewModel.installedApplications)
    }

    func testFetchInstalledApplicationsSetInstalledApplications() {
        manager.fetchSimulators()
        viewModel.fetchInstalledApplications()

        XCTAssertEqual(viewModel.installedApplications?.count, 2)
        XCTAssertEqual(viewModel.installedApplications, [.sample1, .sample2])
    }

    func testDidSelectCopyBundleID() {
        manager.fetchSimulators()
        viewModel.fetchInstalledApplications()
        viewModel.didSelectCopyBundleID(["sample"])

        XCTAssertTrue(copyBoard.didCallClear)
        XCTAssertEqual(copyBoard.didCallCopy, "sample")
    }

    func testDidSelectCppyIDWithNoInstalledAppDoesNothing() {
        viewModel.didSelectCopyBundleID(["sample"])

        XCTAssertNil(copyBoard.didCallCopy)
        XCTAssertFalse(copyBoard.didCallClear)
    }

    func testDidSelectCopyApplicationPath() {
        manager.fetchSimulators()
        viewModel.fetchInstalledApplications()
        viewModel.didSelectCopyApplicationPath(["sample"])

        XCTAssertTrue(copyBoard.didCallClear)
        XCTAssertEqual(copyBoard.didCallCopy, "sampleContainer")
    }

    func testDidSelectCopyApplicationPathWithNoInstalledAppDoesNothing() {
        viewModel.didSelectCopyApplicationPath(["sample"])

        XCTAssertNil(copyBoard.didCallCopy)
        XCTAssertFalse(copyBoard.didCallClear)
    }

    func testDidSelectCopyDataContainerPath() {
        manager.fetchSimulators()
        viewModel.fetchInstalledApplications()

        viewModel.didSelectCopyDataContainerPath(["sample"])

        XCTAssertTrue(copyBoard.didCallClear)
        XCTAssertEqual(copyBoard.didCallCopy, "samplePath")
    }

    func testDidSelectCopyDataContainerPathWithNoInstalledAppDoesNothing() {
        viewModel.didSelectCopyDataContainerPath(["sample"])

        XCTAssertNil(copyBoard.didCallCopy)
        XCTAssertFalse(copyBoard.didCallClear)
    }

    func testDidSelectCopyDataContainerPathWithNilPathDoesNothing() {
        let manager = makeSimulatorManager(installedApps: { _ in
            var appWithNilPath = InstalledAppDetail.sample1
            appWithNilPath.path = nil
            return .success([appWithNilPath])
        })

        self.viewModel = .init(
            copyBoard: self.copyBoard,
            simulatorManager: manager,
            sendEvent: {
                self.eventHandler.handleEvent($0)
            }
        )

        manager.fetchSimulators()
        viewModel.fetchInstalledApplications()
        viewModel.didSelectCopyDataContainerPath(["sample"])

        XCTAssertNil(copyBoard.didCallCopy)
        XCTAssertFalse(copyBoard.didCallClear)
    }

    func testDidSelectCopyBundlePath() {
        manager.fetchSimulators()
        viewModel.fetchInstalledApplications()

        viewModel.didSelectCopyBundlePath(["sample"])

        XCTAssertTrue(copyBoard.didCallClear)
        XCTAssertEqual(copyBoard.didCallCopy, "sampleBundle")
    }

    func testDidSelectCopyBundlePathWithNoInstalledAppDoesNothing() {
        viewModel.didSelectCopyBundlePath(["sample"])

        XCTAssertNil(copyBoard.didCallCopy)
        XCTAssertFalse(copyBoard.didCallClear)
    }

    func testDidSelectCopyBundlePathWithNilBundleDoesNothing() {
        let manager = makeSimulatorManager(installedApps: { _ in
            var appWithNilBundle = InstalledAppDetail.sample1
            appWithNilBundle.bundle = nil
            return .success([appWithNilBundle])
        })

        self.viewModel = .init(
            copyBoard: self.copyBoard,
            simulatorManager: manager,
            sendEvent: { self.eventHandler.handleEvent($0) }
        )

        manager.fetchSimulators()
        viewModel.fetchInstalledApplications()
        viewModel.didSelectCopyBundlePath(["sample"])

        XCTAssertNil(copyBoard.didCallCopy)
        XCTAssertFalse(copyBoard.didCallClear)
    }

    func testDidSelectAppEmitsEvent() {
        manager.fetchSimulators()
        viewModel.fetchInstalledApplications()

        viewModel.didSelectApp(["sample"])

        XCTAssertEqual(eventHandler.receivedEvent, .didSelectApp(.sample1))
    }

    func testDidSelectAppWithInvalidIDEmitsFailureEvent() {
        viewModel.didSelectApp(["invalidID"])

        XCTAssertEqual(eventHandler.receivedEvent, .didFailToRetrieveApplication)
    }

    func testFetchAndObserveSetsInstalledApplications() {
        manager.fetchSimulators()
        viewModel.fetchAndObserve()

        XCTAssertEqual(viewModel.installedApplications?.count, 2)
        XCTAssertEqual(viewModel.installedApplications, [.sample1, .sample2])
    }

    func testObservation() async {
        let sim1: Simulator = .iphone16
        let sim2: Simulator = .iphone16ProMax

        let client = SimulatorClient
            .testing
            .mutate(
                _installedApps: { simulator in
                    if simulator == sim1.id {
                        return .success([.sample1])
                    } else if simulator == sim2.id {
                        return .success([.sample2])
                    } else {
                        fatalError("should never be here")
                    }
                },
                _fetchSimulatorDictionary: {
                    return .success(
                        [
                            .ios17: [.iphone16],
                            .ios18: [.iphone16ProMax]
                        ]
                    )
                }
            )

        self.manager = .init(client: client)
        manager.fetchSimulators()
        self.viewModel = .init(
            copyBoard: copyBoard,
            simulatorManager: self.manager,
            sendEvent: { _ in XCTFail("should never happen") }
        )

        viewModel.fetchAndObserve()

        XCTAssertEqual(viewModel.installedApplications, [.sample1])

        manager.didSelectSimulator(.iphone16ProMax)

        try! await Task.sleep(for: .seconds(1))

        XCTAssertEqual(viewModel.installedApplications, [.sample2])
    }
}

extension InstalledApplicationsViewModelTests {
    @discardableResult
    func makeSimulatorManager(
        activeProcesses: @escaping (String) -> Result<[SimJD.ProcessInfo], Failure> = { _ in
            return .success([.sample])
        },
        installedApps: @escaping (String) -> Result<[SimJD.InstalledAppDetail], Failure> = { _ in
            return .success([.sample1, .sample2])
        },
        uninstallApp: @escaping (InstalledAppDetail, String) -> Result<Void, Failure> = { _, _ in
            return .success(())
        },
        simulatorDictionary: @escaping () -> Result<OrderedDictionary<OS.Name, [Simulator]>, Failure> = {
            return .success(
                [
                    .ios17: [.iphone16],
                    .ios18: [.iphone16ProMax]
                ]
            )
        },
        locale: @escaping (String) -> Result<String, Failure> = { _ in
            return .success("en-US")
        }
    ) -> SimulatorManager {
        let client = SimulatorClient
            .testing
            .mutate(
                _activeProcesses: {
                    activeProcesses($0)
                },
                _installedApps: {
                    installedApps($0)
                },
                _uninstallApp: {
                    uninstallApp($0, $1)
                },
                _fetchSimulatorDictionary: {
                    simulatorDictionary()
                },
                _fetchLocale: {
                    locale($0)
                }
            )

        let manager = SimulatorManager(client: client)
        return manager
    }
}

fileprivate class CopyBoardMock: CopyBoardProtocol {
    var didCallClear: Bool = false
    var didCallCopy: String? = nil

    func clear() {
        didCallClear = true
    }

    func copy(_ text: String) {
        didCallCopy = text
    }
}

fileprivate final class EventHandler {
    var receivedEvent: InstalledApplicationsViewModel.Event?

    func handleEvent(_ event: InstalledApplicationsViewModel.Event) {
        receivedEvent = event
    }
}


private extension SimJD.ProcessInfo {
    static let sample: Self = .init(
        pid: "sample",
        status: "sample",
        label: "sample"
    )
}

private extension InstalledAppDetail {
    static let sample1: Self = .init(
        applicationType: "System",
        bundle: "sampleBundle",
        displayName: "sample",
        bundleIdentifier: "sample",
        bundleName: "sample",
        bundleVersion: "1",
        dataContainer: "sampleContainer",
        path: "samplePath"
    )

    static let sample2: Self = .init(
        applicationType: "User",
        bundle: "sample2Bundle",
        displayName: "sample2",
        bundleIdentifier: "sample2",
        bundleName: "sample2",
        bundleVersion: "2",
        dataContainer: "sample2Container",
        path: "sample2Path"
    )

    static let nilBundleID: Self = .init(
        applicationType: "User",
        bundle: "sample2Bundle",
        displayName: "sample2",
        bundleIdentifier: nil,
        bundleName: "sample2",
        bundleVersion: "2",
        dataContainer: "sample2Container",
        path: "sample2Path"
    )
}

private extension OS.Name {
    static let ios18: Self = .iOS("18")
    static let ios17: Self = .iOS("17")
}

private extension Simulator {
    static let iphone16ProMax: Self = .init(
        dataPath: "path",
        dataPathSize: 12,
        logPath: "logPath",
        udid: "id1",
        isAvailable: true,
        deviceTypeIdentifier: "deviceTypeIdentifier",
        state: "Booted",
        name: "iphone16ProMax",
        os: .ios18,
        deviceImage: .iphone(.gen3)
    )

    static let iphone16: Self = .init(
        dataPath: "path2",
        dataPathSize: 12,
        logPath: "logPath2",
        udid: "id2",
        isAvailable: true,
        deviceTypeIdentifier: "deviceTypeIdentifier",
        state: "Booted",
        name: "iphone16",
        os: .iOS("17"),
        deviceImage: .iphone(.gen3)
    )
}
