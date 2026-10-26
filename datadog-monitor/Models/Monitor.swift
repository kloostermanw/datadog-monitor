//
//  Datadog.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/13/23.
//

import Foundation

struct Root: Decodable {
    let monitors: [Monitor]
    let metadata: SearchMetadata?
}

/// Paging information returned by the monitor search endpoint.
struct SearchMetadata: Decodable {
    let page: Int
    let pageCount: Int

    enum CodingKeys: String, CodingKey {
        case page
        case pageCount = "page_count"
    }
}

struct Monitor: Decodable {
    let id: Int
    let name: String
    let status: String
}
