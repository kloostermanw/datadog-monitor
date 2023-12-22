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
                        value: $appSettings.interval,
                        label: "Interval")
                }
                HStack {
                    Spacer()
                    Button("Save") {
                        appSettings.save()
                    }
                }
            }
            .padding()
        }
   }
}

#Preview {
    SettingsView(appSettings: AppSettings())
}

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
