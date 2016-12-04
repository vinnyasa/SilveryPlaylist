//
//  SCPPlaylist.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/2/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation

struct SCPlaylist {
    //let name: String?
    //let uri: URL?
    //let id: String
    let snapshot: SPTPlaylistSnapshot?
    var tracks: [SPTPartialTrack]? {
        guard let sptTracks = snapshot?.firstTrackPage.items as? [SPTPartialTrack] else {
            return nil
        }
        return sptTracks
    }
    //convert to UIImage
    var largeImage: UIImage?
    var smallImage: UIImage?
    
    //change to init with SPTPlaylistSnapshot
    init?(sptPlaylistSnapshot: SPTPlaylistSnapshot) {
        //guard escentials
        guard  let _ = sptPlaylistSnapshot.uri else {
            return nil
        }

        /*
        guard  let name = sptPlaylistSnapshot.name, let uri = sptPlaylistSnapshot.uri, let id = sptPlaylistSnapshot.snapshotId else {
            return nil
        }
        self.name = name
        self.uri = uri
        self.id = id
        */
        self.snapshot = sptPlaylistSnapshot
        //tracks
        if let largeImage = sptPlaylistSnapshot.largestImage {
            self.largeImage = largeImage.toImage
        } else { largeImage = nil }
        
        if let smallImage = sptPlaylistSnapshot.smallestImage {
            self.smallImage = smallImage.toImage
        } else { smallImage = nil }
    }
    
    init? (sptPlaylistSnapshot: SPTPlaylistSnapshot, tracks: [SPTTrack]) {
        //guard escentials
        guard  let _ = sptPlaylistSnapshot.uri else {
            return nil
        }
        
        /*
         guard  let name = sptPlaylistSnapshot.name, let uri = sptPlaylistSnapshot.uri, let id = sptPlaylistSnapshot.snapshotId else {
         return nil
         }
         self.name = name
         self.uri = uri
         self.id = id
         */
        self.snapshot = sptPlaylistSnapshot
        //tracks
        
        
        if let largeImage = sptPlaylistSnapshot.largestImage  {
            self.largeImage = largeImage.toImage
        } else { largeImage = nil }
        
        if let smallImage = sptPlaylistSnapshot.smallestImage {
            self.smallImage = smallImage.toImage
        } else { smallImage = nil }

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
}
