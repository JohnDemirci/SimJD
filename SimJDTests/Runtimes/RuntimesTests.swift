//
//  RuntimesTests.swift
//  SimJD
//
//  Created by John Demirci on 3/30/25.
//

import XCTest
@testable import SimJD

@MainActor
final class RuntimesTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDeviceTypes() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: Shell.Command.Path.xcrun.rawValue)
        process.arguments = ["simctl", "list", "devicetypes"]

        let pipe = Pipe()
        process.standardOutput = pipe
        
        try! process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        let arr = output.split(separator: "\n")
            .dropFirst()

        XCTAssertTrue(!arr.isEmpty)
    }

    func testRuntimes() {
        let shell = Shell.shared

        let result = shell.execute(.getRuntimes)

        switch result {
        case .success(let maybeOutput):
            guard let output = maybeOutput else {
                XCTFail("No output from shell command.")
                return
            }

            let actualData = output
                .split(separator: "\n")
                .dropFirst()
                .map { "\($0)" }

            XCTAssertTrue(!actualData.isEmpty)
        case .failure(let failure):
            XCTFail(failure.localizedDescription)
        }
    }
}
