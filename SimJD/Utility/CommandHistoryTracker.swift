//
//  CommandHistoryTracker.swift
//  SimJD
//
//  Created by John Demirci on 2/19/25.
//

import Foundation

actor CommandHistoryTracker {
    nonisolated(unsafe)
    private(set) var commands: [CommandHistory] = []

    static let shared = CommandHistoryTracker()

    private init() {}

    func recordExecution(of command: any TrackableCommand) {
        commands.append(.init(command: command, executionDate: Date()))
    }
}

struct CommandHistory: Hashable {
    let command: any TrackableCommand
    let executionDate: Date

    static func == (lhs: CommandHistory, rhs: CommandHistory) -> Bool {
        lhs.command.fullCommand == rhs.command.fullCommand &&
        lhs.executionDate == rhs.executionDate
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(command.fullCommand)
        hasher.combine(executionDate)
    }

    fileprivate init(command: any TrackableCommand, executionDate: Date) {
        self.command = command
        self.executionDate = executionDate
    }
}

protocol TrackableCommand: Equatable, Sendable {
    var fullCommand: String { get }
}

extension Shell.Command {
    var fullCommand: String {
        let initialPath = "\(self.path.rawValue.split(separator: "/").last ?? "")"
        let arguments = self.arguments.joined(separator: " ")
        return "\(initialPath) \(arguments)"
    }
}

struct CustomTrackableCommand: TrackableCommand {
    var fullCommand: String

    init(fullCommand: String) {
        self.fullCommand = fullCommand
    }
}
