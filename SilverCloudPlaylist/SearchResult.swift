//
//  SearchResult.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/5/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation

struct SearchResult {
    var tracks = [SPTPartialTrack]()
    var albums = [SPTPartialAlbum]()
    var playlists = [SPTPartialPlaylist]()
    let searchType: SPTSearchQueryType
    
    var count: Int {
        switch searchType {
        case .queryTypeTrack:
            return tracks.count
        case .queryTypeAlbum:
            return albums.count
        case .queryTypePlaylist:
            return playlists.count
        default:
            return 0
        }
    }
    
    init(musicResults: [Any], searchType: SPTSearchQueryType) {
        self.searchType = searchType
        
        switch searchType {
        case .queryTypeTrack:
            print("query tracks")
            if let tracks = musicResults as? [SPTPartialTrack] {
                print("have tracks")
                self.tracks = tracks
            }
        case .queryTypeAlbum:
            if let albums = musicResults as? [SPTPartialAlbum]  {
                self.albums = albums
            }
        case .queryTypePlaylist:
            if let playlists = musicResults as? [SPTPartialPlaylist] {
                self.playlists = playlists
            }
        default:
            break
        }
    }
    
    func name(atIndex index: Int) -> String? {
        switch searchType {
        case .queryTypeTrack:
            if let trackName = tracks[index].name {
                return trackName
            }
        case .queryTypeAlbum:
            if let albumName = albums[index].name {
                return albumName
            }
        case .queryTypePlaylist:
            if let playlistName = playlists[index].name {
                return playlistName
            }
        default:
            break
        }
        return nil
    }
    
    
    
    
}
