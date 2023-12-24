//
//  Datadog.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/13/23.
//

import Foundation

struct Root: Decodable {
    let monitors: [Monitor]
}

struct Monitor: Decodable {
    let id: Int
    let name: String
    let status: String
}

