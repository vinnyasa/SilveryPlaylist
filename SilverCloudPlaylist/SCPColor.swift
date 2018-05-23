/*********************************************************************
 ** Program name: SilverCloudPlaylist - Spotify playlists
 ** Author: Vinny Harris-Riviello
 ** Date: Dec 4, 2016
 ** Description: SCPColor.swift - custom scp color for UI
 *********************************************************************/


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
