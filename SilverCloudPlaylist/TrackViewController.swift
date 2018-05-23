/*********************************************************************
 ** Program name: SilverCloudPlaylist - Spotify playlists
 ** Author: Vinny Harris-Riviello
 ** Date: Dec 4, 2016
 ** Description: TrackViewController.swift - when a song is
 selected, you can see the title and cover art in a pop.
 *********************************************************************/


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
