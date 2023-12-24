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
                    .background(okBackGroundColor())
                if (showNok()) {
                    Text(String(statusData.nok))
                        .frame(width: 20,height: 20)
                        .background(nokBackGroundColor())
                }
            }
        }
    }
    
    func okBackGroundColor() -> Color?
    {
        if (statusData.nok == 0) {
            return nil
        }
        
        return .green
    }

    func nokBackGroundColor() -> Color?
    {
        if (statusData.nok == 0) {
            return nil
        }
        
        return .red
    }
        
    func showNok() -> Bool
    {
        return statusData.nok != 0
    }
}

#Preview {
    IconView(statusData: StatusData(ok: 0, nok: 0))
}
