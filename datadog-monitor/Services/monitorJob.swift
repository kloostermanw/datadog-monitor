//
//  monitorJob.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/17/23.
//

import Foundation

import SwiftUI
import Observation

@Observable class StatusData {
    var ok: Int = 0
    var nok: Int = 0
    
    init(ok: Int, nok: Int) {
        self.ok = ok
        self.nok = nok
    }
}

@MainActor
class MonitorJob
{
    private var statusItem: NSStatusItem
    private var monitorListVM: MonitorListViewModel?
    var monitors: [MonitorViewModel] = []
    var run: Bool = true
    var statusData = StatusData(ok: 1, nok: 1)
    let appSettings = AppSettings()
    private var pollTask: Task<Void, Never>?
    
    init(statusItem: NSStatusItem, monitorListVM: MonitorListViewModel? = nil) {
        self.statusItem = statusItem
        self.monitorListVM = monitorListVM

        let iconView = NSHostingView(rootView: IconView(statusData: statusData))
        iconView.frame = NSRect(x: 0, y: 0, width: 40, height: 22)

        statusItem.button?.addSubview(iconView)
        statusItem.button?.frame = iconView.frame
    }
    
    func start() {
        pollTask?.cancel()
        pollTask = Task {
            while run, !Task.isCancelled {
                appSettings.getSettings()
                let seconds = Int(appSettings.interval) ?? 60
                try? await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
                guard run, !Task.isCancelled else { break }
                await update()
            }
        }
    }
    
    func stop() {
        run = false
        pollTask?.cancel()
        pollTask = nil
    }
    
    func doRegularWork() {
        Task {
            await update()
        }
    }
    
    func update() async
    {
        do {
            appSettings.getSettings()
            if (
                !(appSettings.apiKey ).isEmpty
                && !(appSettings.appKey ).isEmpty
                && !(appSettings.url ).isEmpty
            ) {
                guard let url = URL(string: appSettings.url) else {
                    print("Invalid URL: \(appSettings.url)")
                    return
                }
                let monitors = try await Webservice().getMonitors(
                    url: url,
                    ddApiKey: appSettings.apiKey,
                    ddAppKey: appSettings.appKey,
                    query: appSettings.query
                )
                self.monitors = monitors.map(MonitorViewModel.init)
                
                // Sort monitors by status priority (Alert, Warn, OK)
                let sortedMonitors = self.monitors.sorted { $0.statusPriority < $1.statusPriority }
                
                // Update the MonitorListViewModel with the sorted data
                self.monitorListVM?.monitors = sortedMonitors
                
                countStatus()
            }
        }
        catch {
            print(error)
        }
    }
                
    func countStatus()
    {
        var OK: Int = 0
        var NOK: Int = 0
        
        for monitor in self.monitors {
            if (monitor.monitor.status == "OK") {
                OK += 1
            } else {
                NOK += 1
            }
        }
        
        statusData.ok = OK
        statusData.nok = NOK
    }
}
