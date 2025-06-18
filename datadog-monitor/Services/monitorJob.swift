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

class MonitorJob
{
    private var statusItem: NSStatusItem
    private var monitorListVM: MonitorListViewModel?
    var monitors: [MonitorViewModel] = []
    var monitorTimer: Timer?
    var run: Bool = true
    var result: Array<Any> = []
    var statusOK: Int = 0
    var statusNOK: Int = 0
    var statusData = StatusData(ok: 1, nok: 1)
    let appSettings = AppSettings()
    
    init(statusItem: NSStatusItem, monitorListVM: MonitorListViewModel? = nil) {
        self.statusItem = statusItem
        self.monitorListVM = monitorListVM

        let iconView = NSHostingView(rootView: IconView(statusData: statusData))
        iconView.frame = NSRect(x: 0, y: 0, width: 40, height: 22)

        statusItem.button?.addSubview(iconView)
        statusItem.button?.frame = iconView.frame
    }
    
    func start() {
        appSettings.getSettings()
        let interval = DispatchTimeInterval.seconds(Int(appSettings.interval) ?? 60)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) { [self] in
                doRegularWork()
            if run {
                start()
            }
        }
    }
    
    func stop() {
        run = false
    }
    
    func doRegularWork() {
        Task {
            result = await update()
        }
    }
    
    func update() async -> Array<Int>
    {
        do {
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
                
                // Sort monitors by status priority (Alert, Warn, OK)
                let sortedMonitors = self.monitors.sorted { $0.statusPriority < $1.statusPriority }
                
                // Update the MonitorListViewModel with the sorted data
                Task { @MainActor in
                    self.monitorListVM?.monitors = sortedMonitors
                }
                
                return countStatus()
            }
        }
        catch {
            print(error)
        }
        
        return [0,0]
    }
                
    func countStatus() -> Array<Int>
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
        
        return [OK, NOK]
    }
}
