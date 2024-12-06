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

    func execute(_ command: Shell.Command) -> Result<String?, Failure> {
        switch command {
        case .fetchBootedSimulators_Legacy,
             .shotdown,
             .uninstallApp,
             .activeProcesses,
             .installedApps,
             .fetchAllSimulators_Legacy:    basicExecute(command)

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

            // Read data from the pipe
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

        let openProcess = Process()
        openProcess.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        openProcess.arguments = ["-a", "Simulator", "--args", "-CurrentDeviceUDID", uuid]

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
    enum Command {
        case fetchBootedSimulators_Legacy
        case fetchAllSimulators_Legacy
        case fetchSimulators
        case shotdown(String)
        case openSimulator(String)
        case activeProcesses(String)
        case eraseContents(String) // do not exclusively call this when executing command use the helper function
        case installedApps(String)
        case deleteSimulator(String)
        case uninstallApp(String, String)

        var path: Path {
            switch self {
            case .fetchBootedSimulators_Legacy, .fetchAllSimulators_Legacy, .activeProcesses:
                .bash

            case .shotdown, .installedApps, .eraseContents, .uninstallApp, .deleteSimulator, .fetchSimulators:
                .xcrun

            case .openSimulator:
                .none
            }
        }

        var arguments: [String] {
            switch self {
            case .installedApps(let id):
                ["simctl", "listapps", id]

            case .eraseContents(let id):
                ["simctl", "erase", id]

            case .deleteSimulator(let id):
                ["simctl", "delete", id]

            case .fetchBootedSimulators_Legacy:
                ["-c", "xcrun simctl list devices | grep Booted"]

            case .fetchAllSimulators_Legacy:
                ["-c", "xcrun simctl list devices"]

            case .shotdown(let uuid):
                ["simctl", "shutdown", uuid]

            case .activeProcesses(let uuid):
                ["-c", "xcrun simctl spawn \(uuid) launchctl list"]

            case .openSimulator:
                []

            case .uninstallApp(let simulatorUUID, let bundleID):
                ["simctl", "uninstall", simulatorUUID, bundleID]

            case .fetchSimulators:
                ["simctl", "list", "devices", "--json"]
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
