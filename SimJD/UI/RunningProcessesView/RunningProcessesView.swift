//
//  RunningProcessesView.swift
//  SimJD
//
//  Created by John Demirci on 11/30/24.
//

import SwiftUI

struct RunningProcessesView: View {
    private let viewModel: RunningProcessesViewModel

    init(viewModel: RunningProcessesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            ForEach(viewModel.processes) { process in
                Text(process.label)
            }
            .inCase(viewModel.processes.isEmpty) {
                NoProcessView {
                    viewModel.emptyProcesses()
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}

private struct NoProcessView: View {
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        VStack {
            Text("Currently There are no processes, check if the simulator is active")
            Button("turn on this simulator") {
                withAnimation {
                    action()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
