//
//  DataDoglistViewModel.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/15/23.
//

import Foundation
import AppKit

@MainActor
class MonitorListViewModel: ObservableObject {
    
    @Published var monitors: [MonitorViewModel] = []
    
    func populateMonitors() async {
        
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
                    ddAppKey: appSettings.appKey,
                    query: appSettings.query
                )
                self.monitors = monitors.map(MonitorViewModel.init)
                
            }
        } catch {
            print(error)
        }
    }
}

struct MonitorViewModel {
    
    public var monitor: Monitor
    
    init(monitor: Monitor) {
        self.monitor = monitor
    }
    
    var symbol: Int {
        monitor.id
    }
    
    var overall_state: String {
        monitor.status
    }
    
    var description: String {
        monitor.name
    }
    
    var statusPriority: Int {
        switch monitor.status {
        case "Alert":
            return 0
        case "Warn":
            return 1
        case "OK":
            return 3
        default:
            return 2
        }
    }
}
