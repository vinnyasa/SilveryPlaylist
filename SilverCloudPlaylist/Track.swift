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
    let album: String?
    var artist: String?
    var smallImage: UIImage?
    var largeImage: UIImage?
    
    init?(track: SPTPartialTrack) {
        
        guard let name = track.name else {
            return nil
        }
        self.name = name
        print("getting album name:")
        if let album = track.album, let albumName = track.album?.name {
            self.album = albumName
            print(albumName)
            print("getting images:")
            if let smallImage = album.smallestCover, let largeImage = album.largestCover {
                print("there should be images")
                self.smallImage = smallImage.toImage
                self.largeImage = largeImage.toImage
            }
        } else { album = nil }
        
        if let artists = track.artists as? [SPTPartialArtist] {
            if !artists.isEmpty {
                self.artist = artists.first?.name
            }
        } else { artist = nil }
        
        
    }
}
