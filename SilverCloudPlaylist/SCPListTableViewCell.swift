//
//  SCPListTableViewCell.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/1/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import UIKit

class SCPListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var scpNameLabel: UILabel?
    @IBOutlet weak var scpImageView: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //scpImageView?.layer.borderWidth = 1
        scpImageView?.layer.masksToBounds = false
        //scpImageView?.layer.borderColor = UIColor.blackColor().CGColor
        scpImageView?.layer.cornerRadius = 16.0
        scpImageView?.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
