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

class monitorJob
{
    private var statusItem: NSStatusItem
    var monitors: [MonitorViewModel] = []
    var monitorTimer: Timer?
    var run: Bool = true
    var result: Array<Any> = []
    var statusOK: Int = 0
    var statusNOK: Int = 0
    var statusData = StatusData(ok: 1, nok: 1)
    
    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem

        let iconView = NSHostingView(rootView: IconView(statusData: statusData))
        iconView.frame = NSRect(x: 0, y: 0, width: 40, height: 22)

        statusItem.button?.addSubview(iconView)
        statusItem.button?.frame = iconView.frame
        
    }
    
    func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [self] in
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
            print("-----> callFunc")
            print(result)
        }
    }
    
    func update() async -> Array<Int>
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
                
    func countStatus() -> Array<Int>
    {
        var OK: Int = 0
        var NOK: Int = 0
        
        for monitor in self.monitors {
            if (monitor.monitor.overall_state == "OK") {
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
