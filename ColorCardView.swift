//
//  ColorCardView.swift
//  SwiftUIDemo
//
//  Created by 墨枫 on 2024/1/8.
//

import SwiftUI

struct ColorCardView: View {
    @State private var redValue: CGFloat = 243
    @State private var greenValue: CGFloat = 248
    @State private var blueValue: CGFloat = 232
    
    var body: some View {
        Form {
            Section {
                Rectangle()
                    .fill(Color(
                        red: redValue / 255,
                        green: greenValue / 255,
                        blue: blueValue / 255)
                    )
                    .frame(height: 200)
                    .cornerRadius(8)
            }
            
            Section {
                HStack {
                    Text("R: \(String(Int(redValue)))")
                    Slider(value: $redValue,
                           in: 0 ... 255,
                           step: 1)
                    .accentColor(.red)
                }
                HStack {
                    Text("G: \(String(Int(greenValue)))")
                    Slider(value: $greenValue,
                           in: 0 ... 255,
                           step: 1)
                    .accentColor(.green)
                }
                HStack {
                    Text("B: \(String(Int(blueValue)))")
                    Slider(value: $blueValue,
                           in: 0 ... 255,
                           step: 1)
                    .accentColor(.blue)
                }
            }
        }
    }
}

#Preview {
    ColorCardView()
}
