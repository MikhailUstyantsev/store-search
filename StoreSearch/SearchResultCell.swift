//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Mikhail Ustyantsev on 27.08.2022.
//

import UIKit

class SearchResultCell: UITableViewCell {

    var downloadTask: URLSessionDownloadTask?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(named: "SearchBar")?.withAlphaComponent(0.5)
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

//    MARK: - Helper Methods
    func configure(for result: SearchResult) {
        nameLabel.text = result.name
        
        if result.artist.isEmpty {
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = String(format: "%@ (%@)", result.artist, result.type)
        }
        artworkImageView.image = UIImage(systemName: "square")
        if let smallURL = URL(string: result.imageSmall) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }
/*
 Remember that table view cells can be reused, so it’s theoretically possible that you’re scrolling through the table and some cell is about to be reused while its previous image is still downloading.
 
 You no longer need that image, so you should really cancel the pending download. Table view cells have a special method named prepareForReuse() that is ideal for this
 */
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    
}
