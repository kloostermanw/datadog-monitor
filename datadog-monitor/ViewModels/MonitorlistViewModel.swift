//
//  DataDoglistViewModel.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/15/23.
//

import Foundation

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
                    ddAppKey: appSettings.appKey
                )
                self.monitors = monitors.map(MonitorViewModel.init)
            }
        } catch {
            print(error)
        }
    }
}

struct MonitorViewModel {
    
    private var monitor: Monitor
    
    init(monitor: Monitor) {
        self.monitor = monitor
    }
    
    var symbol: Int {
        monitor.id
    }
    
    var price: String {
        monitor.overall_state
    }
    
    var description: String {
        monitor.name
    }
}
