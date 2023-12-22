//
//  IconView.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/17/23.
//

import SwiftUI

struct IconView: View {
    var statusData: StatusData
    
    var body: some View {
        ZStack {
            
            HStack(spacing: 2) {
                Text(String(statusData.ok))
                    .frame(width: 20,height: 20)
                    .background(Color.green)
                Text(String(statusData.nok))
                    .frame(width: 20,height: 20)
                    .background(Color.red)
            }
        }
    }
}

#Preview {
    IconView(statusData: StatusData(ok: 0, nok: 0))
}
