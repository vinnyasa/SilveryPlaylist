/*********************************************************************
 ** Program name: SilverCloudPlaylist - Spotify playlists
 ** Author: Vinny Harris-Riviello
 ** Date: Dec 1, 2016
 ** Description: SCPListTableViewCell - custom cell
 *********************************************************************/


import UIKit

class SCPListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var scpNameLabel: UILabel?
    @IBOutlet weak var scpImageView: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        scpImageView?.rounded()
        self.indentationWidth = 20.0
        self.indentationLevel = 0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
