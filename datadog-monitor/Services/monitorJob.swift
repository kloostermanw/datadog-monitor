//
//  monitorJob.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/17/23.
//

import Foundation

class monitorJob
{
    var monitors: [MonitorViewModel] = []
    
    func update() async -> [Int]
    {
        do {
            let appSettings = AppSettings()
            appSettings.getSettings()
            if (
                !(appSettings.apiKey ).isEmpty
                && !(appSettings.appKey ).isEmpty
                && !(appSettings.url ).isEmpty
            ) {
                let monitors = try await Webservice().getMonitors(
                    url: URL(string: appSettings.url)!,
                    ddApiKey: appSettings.apiKey,
                    ddAppKey: appSettings.appKey
                )
                self.monitors = monitors.map(MonitorViewModel.init)
                
                return countStatus()
            }
        }
        catch {
            print(error)
        }
        
        return [0,0]
    }
                
    func countStatus() -> [Int]
    {
        var statusOK: Int = 0
        var statusNOK: Int = 0
        
        for monitor in self.monitors {
            if (monitor.monitor.overall_state == "OK") {
                statusOK += 1
            } else {
                statusNOK += 1
            }
        }
        
        return [statusOK, statusNOK]
    }
}
