//
//  ContentView.swift
//  JRNLSwiftUI
//
//  Created by iOS17Programming on 16/10/2023.
//

import SwiftUI

struct ContentView: View {
    var journalEntries: [JournalEntry] = testData
    var body: some View {
        NavigationStack {
            List(journalEntries) { journalEntry in
                JournalCell(journalEntry: journalEntry)
            }.navigationTitle("Journal List")
                .navigationDestination(for: JournalEntry.self) {
                    journalEntry in
                    JournalEntryDetail(selectedJournalEntry: journalEntry)
                }
        }
    }
}

#Preview {
    ContentView()
}

struct JournalCell: View {
    var journalEntry: JournalEntry
    var body: some View {
        NavigationLink(value: journalEntry) {
            VStack {
                HStack {
                    Image(uiImage: journalEntry.photo ?? UIImage(systemName: "face.smiling")!)
                        .resizable()
                        .frame(width: 90, height: 90)
                    VStack {
                        Text(journalEntry.date.formatted(.dateTime.day().month().year()))
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(journalEntry.entryTitle)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}

//
//  MapView.swift
//  JRNLSwiftUI
//
//  Created by iOS17Programming on 16/10/2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    var journalEntry: JournalEntry
    var body: some View {
        Map(bounds: MapCameraBounds(minimumDistance: 4500, maximumDistance: 4500)) {
            Marker(journalEntry.entryTitle, coordinate: CLLocationCoordinate2D(latitude: journalEntry.latitude ?? 0.0, longitude: journalEntry.longitude ?? 0.0))
        }
    }
}

#Preview {
    MapView(journalEntry: testData[0])
}
