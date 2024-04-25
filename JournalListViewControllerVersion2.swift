//
//  ViewController.swift
//  JRNL
//
//  Created by iOS17Programming on 25/09/2023.
//

import UIKit

class JournalListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    @IBOutlet var tableView: UITableView!
    var sampleJournalEntryData = SampleJournalEntryData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sampleJournalEntryData.createSampleJournalEntryData()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sampleJournalEntryData.journalEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let journalCell = tableView.dequeueReusableCell(withIdentifier: "journalCell", for: indexPath) as! JournalListTableViewCell
        let journalEntry = sampleJournalEntryData.journalEntries[indexPath.row]
        journalCell.photoImageView.image = journalEntry.photo
        journalCell.dateLabel.text = journalEntry.date.formatted(
            .dateTime.month().day().year()
        )
        journalCell.titleLabel.text = journalEntry.entryTitle
        return journalCell
    }
    
    // MARK: - Methods
    @IBAction func unwindNewEntryCancel(segue: UIStoryboardSegue) {
        
    }


}
