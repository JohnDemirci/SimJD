//
//  ProcessInfo.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

struct ProcessInfo: Identifiable, Hashable {
    let label: String
    let pid: String
    let status: String

    var id: String {
        "\(pid)\(status)\(label)"
    }
}
