//
//  SCPColor.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/5/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation

enum SilverCloudColor {
    case aquaGreen
    
    var toColor: UIColor {
        switch self {
        case .aquaGreen:
            return UIColor(red: 54/255.0, green: 185/255.0, blue: 188/255.0, alpha: 1.0)
        }
    }
}
