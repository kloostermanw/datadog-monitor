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
    
    func getMonitors(url: URL, ddApiKey: String, ddAppKey: String) async throws -> [Monitor] {
        var request = URLRequest(url: url)
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(ddApiKey, forHTTPHeaderField: "DD-API-KEY")
        request.addValue(ddAppKey, forHTTPHeaderField: "DD-APPLICATION-KEY")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode([Monitor].self, from: data)
    }
    
}
