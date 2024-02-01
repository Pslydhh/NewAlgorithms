//
//  ViewModel3.swift
//  SwiftUIDemo
//
//  Created by 墨枫 on 2024/1/10.
//

import SwiftUI

class ViewModel3: ObservableObject {
    @Published var showNewNoteView: Bool = false
    
    @Published var isEdit: Bool = false
    
    @Published var noteId: UUID = UUID()
    @Published var content: String = ""
    
    @AppStorage("darkMode") var darkMode = false
    @Published var noteModels = [NoteModel2]()

    init() {
        loadItems()
    }
    
    func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func dataFilePath() -> URL {
        documentsDirectory().appendingPathComponent("NoteModel2.plist")
    }
    
    func loadItems() {
        let path = dataFilePath()
        
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                noteModels = try decoder.decode([NoteModel2].self, from: data)
            } catch {
                print("错误提示: \(error.localizedDescription)")
            }
        }
    }
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(noteModels)
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("错误提示: \(error.localizedDescription)")
        }
    }
    
    func addItem(content: String, updateTime: String) {
        let newItem = NoteModel2(content: content, updateTime: updateTime)
        noteModels.append(newItem)
        saveItems()
    }
    
    func editItem(item: NoteModel2) {
        if let id = noteModels.firstIndex(where: { $0.id == item.id }) {
            noteModels[id] = item
            saveItems()
        }
    }
    
    func deleteItem(itemId: UUID) {
        noteModels.removeAll(where: { $0.id == itemId })
        saveItems()
    }
    
    func getTime() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        return dateformatter.string(from: Date())
    }
}
