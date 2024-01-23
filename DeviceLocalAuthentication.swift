//
//  ContentView.swift
//  DeviceLocalAuthentication
//
//  Created by 墨枫 on 2024/1/12.
//

import SwiftUI

struct ContentView: View {
    @State private var isOpenFaceID = false
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        //faceIDToggleView
        if viewModel.isOpenFaceID {
            if !viewModel.isLock {
                faceIDLockView
            } else {
                faceIDToggleView
            }
        } else {
            faceIDToggleView
        }
    }
    
    private var faceIDToggleView: some View {
        HStack {
            Text("面容ID登录")
            Toggle(isOn: $isOpenFaceID) {
                
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
        .onChange(of: isOpenFaceID) {
            //viewModel.isLock = value
            viewModel.isOpenFaceID = isOpenFaceID
        }
        .onAppear() {
            self.isOpenFaceID = viewModel.isOpenFaceID
        }
    }
    
    private var faceIDLockView: some View {
        VStack(spacing: 20) {
            Image(systemName: "faceid")
                .font(.system(size: 48))
                .foregroundColor(.red)
            Text("点击进行面容ID登录")
        }
        .onTapGesture {
            viewModel.authenticate()
        }
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
