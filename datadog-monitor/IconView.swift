//
//  IconView.swift
//  datadog-monitor
//
//  Created by Wiebe on 12/17/23.
//

import SwiftUI

struct IconView: View {
    var statusOK: Int
    var statusNOK: Int
    
    var body: some View {
        ZStack {
            
            HStack(spacing: 2) {
                Text(String(statusOK))
                    .frame(width: 20,height: 20)
                    .background(Color.green)
                Text(String(statusNOK))
                    .frame(width: 20,height: 20)
                    .background(Color.red)
            }
        }
    }
}

#Preview {
    IconView(statusOK: 10, statusNOK: 0)
}
