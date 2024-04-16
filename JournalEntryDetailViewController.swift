//
//  JournalEntryDetailViewController.swift
//  JRNL
//
//  Created by iOS17Programming on 07/10/2023.
//

import UIKit
import MapKit

class JournalEntryDetailViewController: UITableViewController {
    
    // MARK: - Properties
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyTextView: UITextView!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var mapImageView: UIImageView!
    @IBOutlet var ratingView: RatingView!
    var selectedJournalEntry: JournalEntry?

    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = selectedJournalEntry?.dateString
        ratingView.rating = selectedJournalEntry?.rating ?? 0
        titleLabel.text = selectedJournalEntry?.entryTitle
        bodyTextView.text = selectedJournalEntry?.entryBody
        if let photoData = selectedJournalEntry?.photoData {
            photoImageView.image = UIImage(data: photoData)
        }
        getMapSnapshot()
    }
    
    // MARK: - Private methods
    private func getMapSnapshot() {
        if let lat = selectedJournalEntry?.latitude, let long = selectedJournalEntry?.longitude {
            let options = MKMapSnapshotter.Options()
            options.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            options.size = CGSize(width: 300, height: 300)
            options.preferredConfiguration = MKStandardMapConfiguration()
            let snapShotter = MKMapSnapshotter(options: options)
            snapShotter.start {
                snapShot, error in
                if let snapShot = snapShot {
                    self.mapImageView.image = snapShot.image
                } else if let error = error {
                    print("snapShot error: \(error.localizedDescription)")
                }
            }
        } else {
            self.mapImageView.image = nil
        }
    }

}
