//
//  SCPList.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/3/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation

struct SCPList {
    var playlists = [SCPlaylist]()
    
    
    init(sptPlaylistsSnapshot: [SPTPlaylistSnapshot]) throws {
        guard !sptPlaylistsSnapshot.isEmpty else {
            throw SCPListError.missing(ErrorIdentifier.sptPlaylistArraySnapshot.rawValue)
        }
        for snapshot in sptPlaylistsSnapshot {
            if let scpPlaylist = SCPlaylist(sptPlaylistSnapshot: snapshot) {
                playlists.append(scpPlaylist)
            }
        }
    }


}
enum SCPListError: Error {
    case missing(String)
}
