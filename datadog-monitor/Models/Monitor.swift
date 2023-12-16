//
//  Datadog.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/13/23.
//

import Foundation

struct Monitor: Decodable {
    let id: Int
    let name: String
    let overall_state: String
}
