/*********************************************************************
 ** Program name: SilverCloudPlaylist - Spotify playlists
 ** Author: Vinny Harris-Riviello
 ** Date: Nov 25, 2016
 ** Description: Track struct. Part of the Model, a Track represents
 ** a song or track in an album. SearchViewController.swift -
 ** View controller to handle the serach of a track.
 *********************************************************************/


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
        if let album = track.album, let albumName = track.album?.name {
            self.album = albumName
            if let smallImage = album.smallestCover, let largeImage = album.largestCover {
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
