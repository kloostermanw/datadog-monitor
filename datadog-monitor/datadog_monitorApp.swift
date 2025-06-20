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
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var popoverS: NSPopover!
    
    private var monitorListVM: MonitorListViewModel!
    private var monitorJob: MonitorJob!
    
    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {
        
        self.monitorListVM = MonitorListViewModel()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        self.monitorJob = MonitorJob(statusItem: statusItem, monitorListVM: self.monitorListVM)
        self.monitorJob.doRegularWork()
        self.monitorJob.start()
                
        let statusBarMenu = NSMenu(title: "Cap Status Bar Menu")
        statusItem.menu = statusBarMenu
        
        statusBarMenu.addItem(
            withTitle: "Show monitors",
            action: #selector(togglePopover),
            keyEquivalent: "")
        
        statusBarMenu.addItem(
            withTitle: "Refresh",
            action: #selector(refreshData),
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
        self.popover.contentSize = NSSize(width: 400, height: 300)
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: ContentView(vm: self.monitorListVM))
    }
    
    @objc func exit() {
        NSApplication.shared.terminate(self)
    }
    
    @objc func togglePopover() {
                
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
        let appSettings = AppSettings()
        appSettings.getSettings()
        
        self.popoverS = NSPopover()
        self.popoverS.contentSize = NSSize(width: 600, height: 300)
        self.popoverS.behavior = .transient
        self.popoverS.contentViewController = NSHostingController(rootView: SettingsView(appSettings: appSettings, popover: self.popoverS))
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
            }
            self.popoverS.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    @objc func refreshData() {
        self.monitorJob.doRegularWork()
    }
}
