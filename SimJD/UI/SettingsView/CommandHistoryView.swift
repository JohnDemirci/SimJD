//
//  CommandHistoryView.swift
//  SimJD
//
//  Created by John Demirci on 2/19/25.
//

import Foundation
import SwiftUI

struct CommandHistoryView: View {
    let commands: [CommandHistory]

    var body: some View {
        List {
            ForEach(commands, id: \.self) { command in
                VStack(alignment: .leading) {
                    Text(command.command.fullCommand)

                    Text("at: \(command.executionDate.formatted(date: .numeric, time: .shortened))")
                }
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            }
        }
    }
}
