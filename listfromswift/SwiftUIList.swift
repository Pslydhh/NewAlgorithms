//
//  SwiftUIList.swift
//  SwiftUIDemo
//
//  Created by 墨枫 on 2024/1/7.
//

import SwiftUI

struct SwiftUIList: View {
    
    /*var sentences:[String] = ["福气新岁，万事顺遂。","家人闲坐，灯火可亲。","新年伊始，喜乐安宁。","岁月常新，美好常在。"]*/
    @State var sentences = Sentences
    
    func moveItem(from source:IndexSet, to destination: Int) {
        sentences.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteRow(at offsets: IndexSet) {
        sentences.remove(atOffsets: offsets)
    }
    
    var body: some View {
        /*
        VStack(alignment: .leading, spacing: 10) {
            Text("福气新岁，万事顺遂。")
            Text("家人闲坐，灯火可亲。")
            Text("新年伊始，喜乐安宁。")
            Text("岁月常新，美好常在。")
        }*/
        /*
        List {
            Text("福气新岁，万事顺遂。")
            Text("家人闲坐，灯火可亲。")
            Text("新年伊始，喜乐安宁。")
            Text("岁月常新，美好常在。")
        }*/
        /*
        List {
            ForEach(sentences.indices, id: \.self) {
                item in Text(sentences[item])
            }
        }*/
        /*
        List {
            ForEach(sentences) {
                item in HStack(spacing: 20) {
                    Image(item.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(
                                    .systemGray5), lineWidth: 1)
                        )
                    Text(item.text)
                }
                .padding(.all, 5)
            }
        }*/
        NavigationView {
            ZStack {
                Color(.systemGray6).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                List {
                    ForEach(sentences) {
                        item in ListItem(image: item.image,
                                         text: item.text)
                    }
                    .onMove(perform: moveItem)
                    .onDelete(perform: deleteRow)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
                .navigationBarTitle("账号中心", displayMode: .inline)
                .navigationBarItems(trailing: EditButton())
            }
        }
    }
    
    struct ListItem: View {
        var image: String
        var text: String
        
        var body: some View {
            HStack(spacing: 20) {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color(
                                .systemGray5), lineWidth: 1)
                    )
                Text(text)
            }
            .padding(.all, 5)
        }
    }
}

#Preview {
    SwiftUIList()
}
