/*********************************************************************
 ** Program name: SilverCloudPlaylist - Spotify playlists
 ** Author: Vinny Harris-Riviello
 ** Date: Dec 4, 2016
 ** Description: SearchResult.swift - handling the incoming data from
 ** request. 
 *********************************************************************/


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
            if let tracks = musicResults as? [SPTPartialTrack] {
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
