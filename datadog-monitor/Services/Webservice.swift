//
//  Webservice.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/13/23.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse
}

class Webservice {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Fetches every monitor matching `query`. The search endpoint pages its
    /// results (30 per page by default), so this follows `metadata.page_count`
    /// until all pages have been collected.
    func getMonitors(url: URL, ddApiKey: String, ddAppKey: String, query: String) async throws -> [Monitor] {
        var monitors: [Monitor] = []
        var page = 0
        
        while true {
            let root = try await getPage(page, url: url, ddApiKey: ddApiKey, ddAppKey: ddAppKey, query: query)
            monitors.append(contentsOf: root.monitors)
            
            guard let metadata = root.metadata, page + 1 < metadata.pageCount else {
                break
            }
            page += 1
        }
        
        return monitors
    }
    
    private func getPage(_ page: Int, url: URL, ddApiKey: String, ddAppKey: String, query: String) async throws -> Root {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var queryItems = [URLQueryItem(name: "page", value: String(page))]
        if (query != "") {
            queryItems.append(URLQueryItem(name: "query", value: query))
        }
        components?.queryItems = queryItems
        
        var request = URLRequest(url: components?.url ?? url)
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(ddApiKey, forHTTPHeaderField: "DD-API-KEY")
        request.addValue(ddAppKey, forHTTPHeaderField: "DD-APPLICATION-KEY")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(Root.self, from: data)
    }
    
}
