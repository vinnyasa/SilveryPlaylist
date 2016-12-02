//
//  Track.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 11/25/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation

struct Track {

    let name: String
    let id: String
    //let artist: String
    //var coverArt = CoverArt?()
    let album: Album?
    var coverArt: [CoverArt]? {
        return album?.images
    }
    //maybe just bring in one?
    var image: UIImage? {
        return album?.images.first?.image
    }
    
    init?(trackDictionary: [String: Any]) {
        guard let track = trackDictionary["track"] as? [String: Any], let name = track["name"] as? String, let id = track["id"] as? String, let album = track["album"] as? [String: Any]  else {
            return nil
        }
        self.name = name
        self.id = id
        self.album = Album(albumDictionary: album)
    }
}
