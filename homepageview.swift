//
//  HomePageView.swift
//  SwiftUIDemo
//
//  Created by 墨枫 on 2024/1/8.
//

import SwiftUI

struct HomePageView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            bannerView
            featureGroup
            productList
        }
    }
    
    private var bannerView: some View {
        TabView {
            ForEach(coffeeModels) { item in
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .cornerRadius(16)
                    .padding(.horizontal)
            }
        }
        .tabViewStyle(.page)
        .frame(height:200)
    }
    
    private var featureGroup: some View {
        HStack {
            FeatureBtn(iconImage: "mifan", iconName: "米饭")
            FeatureBtn(iconImage: "chadian", iconName: "茶点")
            FeatureBtn(iconImage: "lengyin", iconName: "冷饮")
            FeatureBtn(iconImage: "shuiguo", iconName: "水果")
            FeatureBtn(iconImage: "tianpin", iconName: "甜品")
        }
        .padding(.vertical, 15)
    }
    
    private var productList: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("为你推荐")
                .font(.system(size: 17))
                .bold()
            
            ForEach(productModels) { item in
                ProductList(productImage: item.productImage, productName: item.productName,
                            size: item.size, price: item.price )
            }
        }
        .padding(.horizontal, 20)
    }
    
    struct FeatureBtn: View {
        var iconImage: String
        var iconName: String
        
        var body: some View {
            VStack(spacing: 10) {
                Image(iconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32)
                
                Text(iconName)
                    .font(.system(size: 14))
            }
            .padding(.horizontal)
        }
            
    }
    
    struct ProductList: View {
        var productImage: String
        var productName: String
        var size: String
        var price: Int
        
        var body: some View {
            HStack(alignment: .bottom) {
                HStack(spacing: 15) {
                    Image(productImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(productName)
                            .font(.system(size: 17))
                            .bold()
                        
                        Text("默认:" + size)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text("¥" + String(price))
                            .font(.system(size: 17))
                            .foregroundColor(.red)
                            .bold()
                    }
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    HomePageView()
}
