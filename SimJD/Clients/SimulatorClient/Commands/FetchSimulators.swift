//
//  FetchSimulators.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

import Foundation
import OrderedCollections

extension SimulatorClient {
    static func handleFetchSimulators() -> Result<OrderedDictionary<OS.Name, [Simulator]>, Failure> {
        switch fetch() {
        case .success(let dataRepresentation):
            do {
                let jsonSerialization = try JSONSerialization.jsonObject(with: dataRepresentation, options: []) as? [String: Any]

                guard let jsonSerialization else {
                    return .failure(Failure.message("unable to convert to dictionary"))
                }

                return parse(jsonSerialization)
            } catch {
                return .failure(Failure.message(error.localizedDescription))
            }

        case .failure(let error):
            return .failure(error)
        }
    }
}

private extension SimulatorClient {
    static func fetch() -> Result<Data, Failure> {
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

            return .success(data)
        } catch {
            return .failure(Failure.message(error.localizedDescription))
        }
    }
}

extension SimulatorClient {
    private static func parse(_ json: [String: Any]) -> Result<OrderedDictionary<OS.Name, [Simulator]>, Failure> {
        guard let devicesDict = json["devices"] as? [String: [Any]] else {
            return .failure(Failure.message("unable to decode"))
        }

        var dict = devicesDict.reduce(
            into: OrderedDictionary<OS.Name, [Simulator]>()
        ) { partialResult, kyp in
            guard let osName = getOSName(key: kyp.key) else { return }
            partialResult[osName] = simulatorParsing(
                data: kyp.value,
                key: osName
            )
        }

        dict.sort { $0.key < $1.key }

        return .success(dict)
    }

    private static func getOSName(key: String) -> OS.Name? {
        let seperator = "."

        let xxx = key.split(separator: seperator).last!
        let device: String = "\(xxx.split(separator: "-").first!)"
        var version = xxx.split(separator: "-")
        version.removeFirst()
        let finalVersion: String = version.joined(separator: "-")

        let osName = OS.Name(os: device, version: finalVersion)
        return osName
    }

    public static func getDeviceModel(key: String) -> String {
        let seperator = "."
        return "\(key.split(separator: seperator).last ?? "")"
    }

    private static func simulatorParsing(
        data: [Any],
        key: OS.Name?
    ) -> [Simulator] {
        return data.compactMap { maybeDict -> Simulator? in
            guard let dict = maybeDict as? [String: Any] else { return nil }
            var simulator = Simulator()

            if let dataPath = dict["dataPath"] as? String {
                simulator.dataPath = dataPath
            }

            if let logPath = dict["logPath"] as? String {
                simulator.logPath = logPath
            }

            if let udid = dict["udid"] as? String {
                simulator.udid = udid
            }

            if let deviceTypeIdentifier = dict["deviceTypeIdentifier"] as? String {
                let model = getDeviceModel(key: deviceTypeIdentifier)
                simulator.deviceTypeIdentifier = model
                simulator.deviceImage = getDeviceSystemImage(key: deviceTypeIdentifier)
            }

            if let state = dict["state"] as? String {
                simulator.state = state
            }

            if let dataPathSize = dict["dataPathSize"] as? Int {
                simulator.dataPathSize = dataPathSize
            }

            if let isAvailable = dict["isAvailable"] as? Bool {
                simulator.isAvailable = isAvailable
            }

            if let name = dict["name"] as? String {
                simulator.name = name
            }

            simulator.os = key

            return simulator
        }
    }

    private static func getDeviceSystemImage(key: String) -> Device? {
        Device.init(key: key)
    }
}
