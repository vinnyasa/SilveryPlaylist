//
//  SCPPlaylist.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/2/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation

struct SCPlaylist {
    let name: String?
    let uri: URL?
    var images: [UIImage?] = []
    var largeImage: SPTImage?
    var smallImage: SPTImage?
    // track has album, album has image
    var sptTracks: [SPTPartialTrack] = []
    
    
    init?(spotifyPlaylist: SPTPartialPlaylist, sptTracks: [SPTPartialTrack])  {
        
        guard let name = spotifyPlaylist.name, let uri = spotifyPlaylist.uri, let largeImage = spotifyPlaylist.largestImage, let smallImage = spotifyPlaylist.smallestImage else {
            return nil
        }
        self.name = name
        self.uri = uri
        self.largeImage = largeImage
        self.smallImage = smallImage
        self.sptTracks = sptTracks
    }

}

enum PlaylistError: Error {
    case missing(String)
}

enum ErrorIdentifier: String {
    case sptPlaylistList = "sptPlaylistList"
    case sptPlaylistListItems = "sptPlaylistListItems"
    case partialList = "partialPlaylist"
    case sptPartialPlaylists = "sptPartialPlaylists"
    case sptPlaylistSnapshot = "sptPlaylistSnapshot"
}
