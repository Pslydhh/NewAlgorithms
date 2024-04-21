//
//  JournalEntryDetail.swift
//  JRNLSwiftUI
//
//  Created by iOS17Programming on 16/10/2023.
//

import SwiftUI

struct JournalEntryDetail: View {
    var selectedJournalEntry: JournalEntry
    var body: some View {
        ScrollView {
            VStack{
                Spacer().frame(height: 30)
                Text(selectedJournalEntry.date.formatted(.dateTime.day().month().year()))
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Spacer().frame(height: 30)
                Text(selectedJournalEntry.entryTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer().frame(height: 30)
                Text(selectedJournalEntry.entryBody)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer().frame(height: 30)
                Image(uiImage: selectedJournalEntry.photo ?? UIImage(systemName: "face.smiling")!)
                    .resizable()
                    .frame(width: 300, height: 300)
                Spacer().frame(height: 30)
                MapView(journalEntry: selectedJournalEntry)
                    .frame(width: 300, height: 300)
            }.padding()
                .navigationTitle("Entry Detail")
        }
    }
}

#Preview {
    JournalEntryDetail(selectedJournalEntry: testData[0])
}
