//
//  ProcessInfo.swift
//  SimJD
//
//  Created by John Demirci on 11/29/24.
//

struct ProcessInfo: Identifiable, Hashable {
    let pid: String
    let status: String
    let label: String

    var id: String {
        "\(pid)\(status)\(label)"
    }
}
