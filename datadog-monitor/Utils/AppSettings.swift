//
//  Constants.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/15/23.
//

import Foundation

class AppSettings: ObservableObject
{
    @Published var url = "https://api.datadoghq.com/api/v1/monitor/search"
    @Published var apiKey = ""
    @Published var appKey = ""
    @Published var interval = "60"
    @Published var query = ""
        
    var settingsKey = "settings"
}

extension AppSettings {
    func save()
    {
        do {
            let objUserDefaults = UserDefaults(suiteName: "datadog-monitor.kloosterman.eu")
            var values: [String : String] = ["interval": "60"]
            values["interval"] = interval
            values["url"] = url
            values["apiKey"] = apiKey
            values["appKey"] = appKey
            values["query"] = query
                    
            objUserDefaults?.setValue(values, forKey: settingsKey)
        }
    }
    
    func getSettings()
    {
        let objUserDefaults = UserDefaults(suiteName: "datadog-monitor.kloosterman.eu")
        if objUserDefaults?.value(forKey: settingsKey) != nil {
            let values = objUserDefaults?.value(forKey: settingsKey) as! [String : String]
            self.apiKey = values["apiKey"] ?? ""
            self.appKey = values["appKey"] ?? ""
            self.url = values["url"] ?? ""
            self.interval = values["interval"] ?? "60"
            self.query = values["query"] ?? ""
        }
    }
}
