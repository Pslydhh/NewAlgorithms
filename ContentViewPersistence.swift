//
//  ContentViewPersistence.swift
//  SwiftUIDemo
//
//  Created by 墨枫 on 2024/1/9.
//

import SwiftUI

struct ContentViewPersistence: View {
    @StateObject var viewModel3 = ViewModel3()
    
    var body: some View {
        NavigationView {
            ScrollView {
                /*
                NoteCardItemView(id: UUID(), content: "纵然敌众我寡，吾亦一往无前。", updateTime: "2023-03-10")
                NoteCardItemView(id: UUID(), content: "躲起来的星星，其实也在努力发光。", updateTime: "2023-03-10")*/
                ForEach(viewModel3.noteModels) { item in
                    NoteCardItemView(id: item.id, content: item.content, updateTime: item.updateTime)
                        .contextMenu {
                            Button("删除") {
                                viewModel3.deleteItem(itemId: item.id)
                            }
                        }
                        .onTapGesture {
                            viewModel3.isEdit = true
                            viewModel3.noteId = item.id
                            viewModel3.content = item.content
                            viewModel3.showNewNoteView.toggle()
                        }
                }
            }
            .navigationBarTitle("我的笔记", displayMode: .inline)
            .navigationBarItems(leading: darkModeBtn, trailing: addBtn)
        }
        .preferredColorScheme(viewModel3.darkMode ? .dark : .light)
        .sheet(isPresented: $viewModel3.showNewNoteView) {
            NewNoteView(id: viewModel3.noteId, content: viewModel3.content, showNewNoteView: $viewModel3.showNewNoteView,
                        viewModel3: viewModel3)
        }
    }
    
    private var addBtn: some View {
        Image(systemName: "plus.circle.fill")
            .font(.system(size: 20))
            .foregroundColor(.blue)
            .onTapGesture {
                viewModel3.isEdit = false
                viewModel3.noteId = UUID()
                viewModel3.content = ""
                viewModel3.showNewNoteView.toggle()
            }
    }
    
    private var darkModeBtn: some View {
        Image(systemName: viewModel3.darkMode ? "sun.max.circle.fill" : "moon.circle.fill")
            .font(.system(size: 20))
            .foregroundColor(viewModel3.darkMode ? .white : .gray)
            .onTapGesture {
                viewModel3.darkMode.toggle()
            }
    }
}

struct NoteCardItemView: View {
    var id: UUID
    var content: String
    var updateTime: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(content)
                    .font(.system(size: 17))
                    .lineLimit(3)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Text(updateTime)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 140)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct NewNoteView: View {
    @State var id: UUID
    @State var content: String = ""
    @Binding var showNewNoteView: Bool
    var viewModel3 = ViewModel3()
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $content)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray5), lineWidth: 1)
                        )
                    
                    if content.isEmpty {
                        Text("请输入内容")
                            .foregroundColor(Color(UIColor.placeholderText))
                            .padding(10)
                    }
                }
                .frame(height: 320)
                .padding()
                
                Spacer()
            }
            .navigationBarTitle(viewModel3.isEdit ? "编辑笔记" : "新增笔记", displayMode: .inline)
            .navigationBarItems(leading: closeBtn, trailing: saveBtn)
            
            .preferredColorScheme(viewModel3.darkMode ? .dark: .light)
        }
    }
    
    private var closeBtn: some View {
        Image(systemName: "xmark.circle.fill")
            .font(.system(size: 20))
            .foregroundColor(.gray)
            .onTapGesture {
                self.showNewNoteView.toggle()
            }
    }
    
    private var saveBtn: some View {
        Text("保存")
            .font(.system(size: 20))
            .foregroundColor(.blue)
            .onTapGesture {
                if viewModel3.isEdit {
                    let updateItem = NoteModel2(id: id, content: content,
                                               updateTime: viewModel3.getTime())
                    viewModel3.editItem(item: updateItem)
                } else {
                    viewModel3.addItem(content: content, updateTime: viewModel3.getTime())
                }
                self.showNewNoteView.toggle()
            }
    }
}

#Preview {
    ContentViewPersistence()
}
