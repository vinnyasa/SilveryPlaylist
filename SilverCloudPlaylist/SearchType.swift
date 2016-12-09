//
//  SearchType.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/4/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation

extension SPTSearchQueryType {
    var toString: String? {
        switch self {
        case SPTSearchQueryType.queryTypeAlbum:
            return "Albums"
        case .queryTypeTrack:
            return "Tracks"
        case .queryTypePlaylist:
            return "Playlists"
        case .queryTypeArtist:
            return "Artists"
        }
    }
}
