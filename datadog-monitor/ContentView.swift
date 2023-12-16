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
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            
                            Text(monitor.description)
                                .opacity(0.4)
                            Divider()
                        }
                       
                        
                    }
                }.task {
                    await vm.populateMonitors()
                }
                
            }.frame(width: 300, height: 300)
        }
    
    
}

#Preview {
    ContentView(vm: MonitorListViewModel())
}
