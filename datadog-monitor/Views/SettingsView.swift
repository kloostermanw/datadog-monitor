//
//  SettingsView.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/16/23.
//

import SwiftUI

let windowWidth = CGFloat(400)
let labelsWidth = windowWidth / 4


struct SettingsView: View {
    @StateObject var appSettings: AppSettings
    var popover: NSPopover
    
    var body: some View {
        Form {
            VStack {
                Section {
                    NameRow(
                        value: $appSettings.url,
                        label: "Datadog API url")
                    NameRow(
                        value: $appSettings.apiKey,
                        label: "API key")
                    NameRow(
                        value: $appSettings.appKey,
                        label: "Application key")
                    NameRow(
                        value: $appSettings.query,
                        label: "Query")
                    NameRow(
                        value: $appSettings.interval,
                        label: "Interval (sec)")
                }
                HStack {
                    Spacer()
                    Button("Cancel") {
                        if popover.isShown {
                            self.popover.performClose(nil)
                        }
                    }
                    Button("Save") {
                        appSettings.save()
                        
                        if popover.isShown {
                            self.popover.performClose(nil)
                        }
                    }
                }
            }
            .padding()
        }
   }
}

//#Preview {
//    SettingsView(appSettings: AppSettings())
//}

struct NameRow: View {

    @Binding var value: String
    let label: String

    var body: some View {
        HStack {
            Text("\(label)")
                .frame(minWidth: labelsWidth, alignment: .trailing)
            TextField(label, text: $value)
                .labelsHidden()
            
        }
    }
}
