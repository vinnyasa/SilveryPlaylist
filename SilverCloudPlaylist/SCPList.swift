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
        if sptPlaylistsSnapshot.isEmpty {
            throw SCPListError.missing(ErrorIdentifier.sptPlaylistArraySnapshot.rawValue)
        }
        for snapshot in sptPlaylistsSnapshot {
            if let scpPlaylist = SCPlaylist(sptPlaylistSnapshot: snapshot) {
                playlists.append(scpPlaylist)
            }
        }
    }
    // init from json
    init(jsonDictionary: [String: Any]?) throws {
        /*
        guard let json = jsonDictionary else {
            throw SCPListError.missing(ErrorIdentifier.json.rawValue)
        }
        
        if let items = json["items"] as [[String: Any]] {
            for item in items
        }*/
    }


}
enum SCPListError: Error {
    case missing(String)
}
