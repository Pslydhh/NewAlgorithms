//
//  SwiftUIColorHEX.swift
//  SwiftUIDemo
//
//  Created by 墨枫 on 2024/1/9.
//

import SwiftUI

struct SwiftUIColorHEX: View {
    private var colors: Gradient = Gradient(colors: [Color(hex: "8FD3F4"), Color(hex: "84FAB0")]
    )
    
    var body: some View {
        Circle()
            .fill(LinearGradient(gradient: colors, startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .padding()
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    SwiftUIColorHEX()
}
