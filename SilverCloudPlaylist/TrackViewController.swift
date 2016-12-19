//
//  TrackViewController.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/11/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import UIKit

class TrackViewController: UIViewController {
    
    var track: Track?
    
    @IBOutlet weak var trackImageView: UIImageView!
    
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    
    @IBOutlet weak var trackNameBackgroundView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        guard let track = track else {
            fatalError("no track available")
            //return
        }
        trackNameLabel.text = track.name
        if let image = track.largeImage {
            trackImageView.image = image
        }
        if let artist = track.artist {
            artistLabel.text = "by \(artist)"
        }
    }
}
