//
//  Playlists.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 11/30/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation

class SilverCloudPlaylistList {
    var playlists = [Playlist]()
    
    init(sptPlaylistList: SPTPlaylistList?) throws {
        guard let playlistList = sptPlaylistList else {
            throw PlaylistError.missing(ErrorIdentifier.sptPlaylistList.rawValue)
        }
        print("have a sptPlaylistList: \(playlistList)")
        guard let items = playlistList.items else {
            //if user hasn't created any playlists there is still a SPTPlaylistList Object with 0 iitems == nil
            //could have feature to invite them to create a playlist
            print("user has 0 playlists")
            throw PlaylistError.missing(ErrorIdentifier.items.rawValue)
        }
        print("printing playlistList: \(playlistList)")
        
        for item in items  {
            guard let playlist = item as? SPTPartialPlaylist else {
                print("did not create partialPlaylist, item not converting")
                throw PlaylistError.missing(ErrorIdentifier.partialList.rawValue)
                
            }
            if let playList = Playlist(spotifyPlaylist: playlist) {
                playlists.append(playList)
            }
        }
    }
    
}

