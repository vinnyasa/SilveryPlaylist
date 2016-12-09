//
//  SCPPlaylist.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/2/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation

struct SCPlaylist {
    
    let snapshot: SPTPlaylistSnapshot?
    var tracks: [SPTPartialTrack]? {
        guard let sptTracks = snapshot?.firstTrackPage.items as? [SPTPartialTrack] else {
            return nil
        }
        return sptTracks
    }
    var largeImage: UIImage?
    var smallImage: UIImage?
    var tracksOnLocal: [SPTPartialTrack]?
    var name: String? {
        return snapshot!.name
    }
    var uri: URL? {
        return snapshot!.uri
    }
    var id: String? {
        return snapshot?.snapshotId
    }
    
    
    
    //change to init with SPTPlaylistSnapshot
    init?(sptPlaylistSnapshot: SPTPlaylistSnapshot) {
        //guard escentials
        guard  let _ = sptPlaylistSnapshot.uri else {
            return nil
        }
        self.snapshot = sptPlaylistSnapshot
        //tracks
        if let largeImage = sptPlaylistSnapshot.largestImage {
            self.largeImage = largeImage.toImage
        } else { largeImage = nil }
        
        if let smallImage = sptPlaylistSnapshot.smallestImage {
            self.smallImage = smallImage.toImage
        } else { smallImage = nil }
    }
    
    init? (sptPlaylistSnapshot: SPTPlaylistSnapshot, tracks: [SPTPartialTrack]?) {
        
        guard let playlist = SCPlaylist(sptPlaylistSnapshot: sptPlaylistSnapshot) else {
            return nil
        }
        snapshot = playlist.snapshot
        largeImage = playlist.largeImage
        smallImage = playlist.smallImage
        tracksOnLocal = tracks
        
    }

}

extension SPTImage {
    var toImage: UIImage? {
        guard let url = self.imageURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
            return nil
        }
        return image
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
    case sptPlaylistArraySnapshot = "sptPlaylistArraySnapshot"
    case newPlaylistSnapshot = "newPlaylistSnapshot"
    case newPlaylistSnapshotWithTracks = "withNewPlaylistSnapshotWithTracks"
    case localPlaylist = "localPlaylist"
    case json = "jsonDictionary"
}
