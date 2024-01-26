//
//  SwiftUIScrollView.swift
//  SwiftUIDemo
//
//  Created by 墨枫 on 2024/1/8.
//

import SwiftUI

struct SwiftUIScrollView: View {
    var body: some View {
        /*
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach(bannerModels) { item in
                    Image(item.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)*/
        NavigationView {
            VStack {
                hStackScrollView
                vStackScrollView
            }
            .padding()
            .navigationBarTitle("首页", displayMode: .inline)
        }
    }
    
    private var hStackScrollView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("横向滚动")
                .font(.system(size: 23))
                .bold()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(bannerModels) { item in
                        Image(item.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 120)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var vStackScrollView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("横向滚动")
                .font(.system(size: 23))
                .bold()
                .padding(.top, 40)
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ForEach(bannerModels) { item in
                        Image(item.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 100)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

#Preview {
    SwiftUIScrollView()
}
