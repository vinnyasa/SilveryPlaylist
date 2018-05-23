/*********************************************************************
 ** Program name: SilverCloudPlaylist - Spotify playlists
 ** Author: Vinny Harris-Riviello
 ** Date: Dec 4, 2016
 ** Description: SPTSearchQueryType - extension to assit the search
 ** request.
 *********************************************************************/


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
