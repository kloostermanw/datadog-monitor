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
    var monitorTimer: Timer?
    
    
    func start()
    {
        monitorTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func stop()
    {
        monitorTimer?.invalidate()
    }
    
    
    
    @objc func update() async
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
                
                countStatus()
            }
        }
        catch {
            print(error)
        }
    }
                
    func countStatus()
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
        
        print([statusOK, statusNOK])
    }
}
