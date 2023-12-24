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
    
    func getMonitors(url: URL, ddApiKey: String, ddAppKey: String, query: String) async throws -> [Monitor] {
        var url2 = url
        
        if (query != "") {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false);
            components?.queryItems = [URLQueryItem(name: "query", value: query)]
            url2 = components?.url ?? url
        }
        
        var request = URLRequest(url: url2)
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(ddApiKey, forHTTPHeaderField: "DD-API-KEY")
        request.addValue(ddAppKey, forHTTPHeaderField: "DD-APPLICATION-KEY")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        
        return root.monitors
    }
    
}
