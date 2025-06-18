//
//  ContentView.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/13/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm: MonitorListViewModel
        
    init(vm: MonitorListViewModel) {
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Monitors").padding()
            
            List(vm.monitors, id: \.symbol) { monitor in
                HStack(alignment: .center, spacing: 0) {
                    Text(monitor.overall_state)
                        .padding(2)
                        .foregroundStyle(.white)
                        .background(backGroundColor(overall_state: monitor.overall_state))
                        .cornerRadius(4)
                    
                    Text(monitor.description)
                        .padding(.leading, 10)
                        
                }
            }
            
        }.frame(width: 400, height: 300)
    }
    
    
    func backGroundColor(overall_state: String) -> Color?
    {
        if (overall_state == "OK") {
            return .green
        }
        
        if (overall_state == "Warn") {
            return .yellow
        }
        
        if (overall_state == "Alert") {
            return .red
        }
        
        return .clear
    }
}

#Preview {
    ContentView(vm: MonitorListViewModel())
}
