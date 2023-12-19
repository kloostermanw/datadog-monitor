//
//  monitorJob.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/17/23.
//

import Foundation

import SwiftUI

class monitorJob
{
    private var statusItem: NSStatusItem
    var monitors: [MonitorViewModel] = []
    var monitorTimer: Timer?
    var run: Bool = true
    var result: Array<Any> = []
    @State var statusOK: Int = 0
    @State var statusNOK: Int = 0
    
    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem

        let iconView = NSHostingView(rootView: IconView(statusOK: statusOK, statusNOK: statusNOK))
        iconView.frame = NSRect(x: 0, y: 0, width: 40, height: 22)

        statusItem.button?.addSubview(iconView)
        statusItem.button?.frame = iconView.frame
        
    }
    
    func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [self] in
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
        
        statusOK = OK
        statusNOK = NOK
        
        return [OK, NOK]
    }
}
