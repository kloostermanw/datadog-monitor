//
//  datadog_monitorApp.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/13/23.
//

import SwiftUI

@main
struct datadog_monitorApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(vm: MonitorListViewModel())
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var popoverS: NSPopover!
    
    private var monitorListVM: MonitorListViewModel!
    
    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {
        
        self.monitorListVM = MonitorListViewModel()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let myString = "10"
        let myAttribute = [ NSAttributedString.Key.foregroundColor: NSColor.green ]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)

        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "chart.line.uptrend.xyaxis.circle", accessibilityDescription: "Chart Line")
            statusButton.action = #selector(togglePopover)
            statusButton.attributedTitle = myAttrString
        }
        

        
        let statusBarMenu = NSMenu(title: "Cap Status Bar Menu")
        statusItem.menu = statusBarMenu
        
        statusBarMenu.addItem(
            withTitle: "Show monitors",
            action: #selector(togglePopover),
            keyEquivalent: "")
        
        statusBarMenu.addItem(
            withTitle: "Settings",
            action: #selector(showSettings),
            keyEquivalent: "")
        
        statusBarMenu.addItem(
            withTitle: "Stop application",
            action: #selector(exit),
            keyEquivalent: "")
        
        self.popover = NSPopover()
        self.popoverS = NSPopover()
        self.popover.contentSize = NSSize(width: 300, height: 300)
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: ContentView(vm: self.monitorListVM))
    }
    
    @objc func exit() {
        NSApplication.shared.terminate(self)
    }
    
    @objc func togglePopover() {
        
//        Task {
//            await self.monitorListVM.populateMonitors
//        }
        
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
            } else if self.popoverS.isShown{
                self.popoverS.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
        
    }
    
    @objc func showSettings() {
        let objUserDefaults = UserDefaults(suiteName: "datadog-monitor.kloosterman.eu")
        let appSettings = AppSettings()
        
        if objUserDefaults?.value(forKey: "settings") != nil {
            let arrDirectory = objUserDefaults?.value(forKey: "settings") as! [String : String]
            appSettings.apiKey = arrDirectory["apiKey"]!
            appSettings.appKey = arrDirectory["appKey"]!
            appSettings.url = arrDirectory["url"]!
            appSettings.interval = arrDirectory["interval"]!
        }
        
        self.popoverS = NSPopover()
        self.popoverS.contentSize = NSSize(width: 400, height: 300)
        self.popoverS.behavior = .transient
        self.popoverS.contentViewController = NSHostingController(rootView: SettingsView(appSettings: appSettings))
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
            }
            self.popoverS.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
}
