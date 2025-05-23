//
//  Shell.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import SwiftUI

struct Shell: Sendable {
    static let shared = Shell()

    private init() {}

    private func trackCommandIfEnabled(_ command: any TrackableCommand) {
        Task {
            let shouldTrackCommand = UserDefaults.standard.bool(forKey: Setting.enableLogging.key)

            if shouldTrackCommand {
                await CommandHistoryTracker.shared.recordExecution(of: command)
            }
        }
    }

    func execute(_ command: Shell.Command) -> Result<String?, Failure> {
        defer {
            trackCommandIfEnabled(command)
        }

        return switch command {
        case .addMedia,
             .shotdown,
             .uninstallApp,
             .simulatorLocale,
             .activeProcesses,
             .createSimulator,
             .batteryStatusUpdate,
             .retrieveOverrides,
             .getDeviceTypes,
             .getRuntimes,
             .updateLocation,
             .installedApps:                basicExecute(command)

        case .eraseContents(let uuid):      eraseContent(uuid: uuid)

        case .deleteSimulator(let uuid):    deleteSimulator(uuid)

        case .fetchSimulators:              fetchSimulators()

        case .openSimulator(let uuid):      openSimulator(uuid: uuid)
        }
    }

    private func fetchSimulators() -> Result<String?, Failure> {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["simctl", "list", "devices", "--json"]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()

            guard let stringOutput = String(data: data, encoding: .utf8) else {
                return .failure(Failure.message("Decoding Error"))
            }

            return .success(stringOutput)
        } catch {
            return .failure(Failure.message(error.localizedDescription))
        }
    }

    private func deleteSimulator(_ uuid: String) -> Result<String?, Failure> {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["simctl", "delete", uuid]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)

            if process.terminationStatus == 0 {
                return .success(output)
            } else {
                return .failure(Failure.message("Simulator Termination Error"))
            }
        } catch {
            return .failure(Failure.message(error.localizedDescription))
        }
    }

    private func basicExecute(_ command: Shell.Command) -> Result<String?, Failure> {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command.path.rawValue)
        process.arguments = command.arguments

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return .failure(Failure.message(error.localizedDescription))
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()

        guard let stringOutput = String(data: data, encoding: .utf8) else {
            return .failure(Failure.message("Decoding Error"))
        }

        return .success(stringOutput)
    }

    private func eraseContent(uuid: String) -> Result<String?, Failure> {
        let shutdownProcess = Process()
        let eraseProcess = Process()

        let shutDownCommand = Shell.Command.shotdown(uuid)
        shutdownProcess.executableURL = URL(fileURLWithPath: shutDownCommand.path.rawValue)
        shutdownProcess.arguments = shutDownCommand.arguments

        let eraseCommand = Shell.Command.eraseContents(uuid)
        eraseProcess.executableURL = URL(fileURLWithPath: eraseCommand.path.rawValue)
        eraseProcess.arguments = eraseCommand.arguments

        do {
            try shutdownProcess.run()
            shutdownProcess.waitUntilExit()

            try eraseProcess.run()
            eraseProcess.waitUntilExit()

            _ = openSimulator(uuid: uuid)
            return .success(nil)
        } catch {
            return .failure(Failure.message(error.localizedDescription))
        }
    }

    @discardableResult
    private func openSimulator(uuid: String) -> Result<String?, Failure> {
        let bootProcess = Process()
        bootProcess.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        bootProcess.arguments = ["simctl", "boot", uuid]

        trackCommandIfEnabled(CustomTrackableCommand(fullCommand: "xcrun simctl boot \(uuid)"))

        let openProcess = Process()
        openProcess.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        openProcess.arguments = ["-a", "Simulator", "--args", "-CurrentDeviceUDID", uuid]

        trackCommandIfEnabled(CustomTrackableCommand(fullCommand: "open -a simulator --args -CurrentDeviceUDID \(uuid)"))

        do {
            try bootProcess.run()
            bootProcess.waitUntilExit()

            try openProcess.run()
            openProcess.waitUntilExit()

            return .success(nil)
        } catch {
            print("Failed to open simulator: \(error)")
            return .failure(Failure.message(error.localizedDescription))
        }
    }
}

extension Shell {
    enum Command: Hashable, TrackableCommand {
        case addMedia(String, String)
        case fetchSimulators
        case shotdown(String)
        case openSimulator(String)
        case activeProcesses(String)
        case eraseContents(String) // do not exclusively call this when executing command use the helper function
        case getDeviceTypes
        case getRuntimes
        case createSimulator(String, String, String) // name, deviceType, runtime
        case installedApps(String)
        case deleteSimulator(String)
        case uninstallApp(String, String)
        case updateLocation(String, Double, Double)
        case simulatorLocale(String)
        case batteryStatusUpdate(String, String, String)
        case retrieveOverrides(String)

        var path: Path {
            switch self {
            case .activeProcesses:          .bash

            case
                .addMedia,
                .shotdown,
                .installedApps,
                .eraseContents,
                .uninstallApp,
                .deleteSimulator,
                .fetchSimulators,
                .updateLocation,
                .simulatorLocale,
                .getDeviceTypes,
                .getRuntimes,
                .createSimulator,
                .batteryStatusUpdate,
                .retrieveOverrides:         .xcrun

            case .openSimulator:            .none
            }
        }

        var arguments: [String] {
            switch self {
            case .addMedia(let id, let path):
                ["simctl", "addmedia", id, path]

            case .installedApps(let id):
                ["simctl", "listapps", id]

            case .eraseContents(let id):
                ["simctl", "erase", id]

            case .createSimulator(let name, let deviceType, let runtime):
                ["simctl", "create", name, deviceType, runtime]

            case .deleteSimulator(let id):
                ["simctl", "delete", id]

            case .shotdown(let uuid):
                ["simctl", "shutdown", uuid]

            case .activeProcesses(let uuid):
                ["-c", "xcrun simctl spawn \(uuid) launchctl list"]

            case .openSimulator:
                []

            case .getDeviceTypes:
                ["simctl", "list", "devicetypes"]

            case .getRuntimes:
                ["simctl", "list", "runtimes"]

            case .uninstallApp(let simulatorUUID, let bundleID):
                ["simctl", "uninstall", simulatorUUID, bundleID]

            case .fetchSimulators:
                ["simctl", "list", "devices", "--json"]

            case .updateLocation(let id, let lat, let long):
                ["simctl", "location", id, "set", "\(lat),\(long)"]

            case .simulatorLocale(let simulatorID):
                [
                    "simctl",
                    "spawn",
                    simulatorID,
                    "defaults",
                    "read",
                    "-globalDomain",
                    "AppleLanguages"
                ]

            case .batteryStatusUpdate(let simulatorID, let state, let level):
                [
                    "simctl",
                    "status_bar",
                    simulatorID,
                    "override",
                    "--batteryState",
                    state,
                    "--batteryLevel",
                    level
                ]

            case .retrieveOverrides(let id):
                [
                    "simctl",
                    "status_bar",
                    id,
                    "list"
                ]
            }
        }
    }
}

extension Shell.Command {
    enum Path: String {
        case bash = "/bin/bash"
        case xcrun = "/usr/bin/xcrun"
        case open = "/usr/bin/open"
        case none
    }
}
