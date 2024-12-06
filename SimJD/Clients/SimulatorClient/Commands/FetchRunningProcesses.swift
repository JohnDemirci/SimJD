//
//  FetchRunningProcesses.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

extension SimulatorClient {
    static func handleRunningProcesses(
        _ id: String
    ) -> Result<[ProcessInfo], Failure> {
        switch Shell.shared.execute(.activeProcesses(id)) {
        case .success(let maybeOutput):
            guard let output = maybeOutput else {
                return .failure(Failure.message("no output for processes"))
            }

            return parseOutputData(output)

        case .failure(let error):
            return .failure(error)
        }
    }
}

extension SimulatorClient {
    private static func parseOutputData(_ inputData: String) -> Result<[ProcessInfo], Failure> {
        let lines = inputData.components(separatedBy: "\n")

        // Parse the lines into an array of ProcessInfo
        var processes = [ProcessInfo]()

        for line in lines.dropFirst() { // Drop the header line
            let components = line.components(separatedBy: "\t")
            if components.count == 3 {
                let processInfo = ProcessInfo(pid: components[0], status: components[1], label: components[2])
                processes.append(processInfo)
            }
        }

        return .success(processes)
    }
}
