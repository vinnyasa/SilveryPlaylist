//
//  NetworkOperation.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 11/30/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation

class NetworkOperation {
    
    lazy var session:URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    typealias JSONDictionaryCompletion = (_ error: Error?, _ json: [String: AnyObject]?) -> ()
    
    
    func downloadJson(request: URLRequest, completion: @escaping JSONDictionaryCompletion) {
        
        let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse ,  200...299 ~= httpResponse.statusCode else {
                //handle error
                completion(error, nil)
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] else {
                completion(NetworkError.unableToUnWrapJson, nil)
                return
            }
            completion(nil, json)
            
        })
        dataTask.resume()
    }
    
    typealias ResponseCompletion = (_ error: Error?, _ success: Bool) -> ()
    func handle(request: URLRequest, completion: @escaping ResponseCompletion) {
        let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse ,  200...299 ~= httpResponse.statusCode else {
                //handle error
                completion(error, false)
                return
            }
            completion(nil, true)
        })
        dataTask.resume()
    }
}

enum NetworkError: Error {
    case unableToUnWrapJson
}


class SilverCloudService {
    var auth: SPTAuth = SPTAuth.defaultInstance()
    var silverCloudAuth = SilverCloudAuth()
    let url: URL? = URL(string: API.url.rawValue)
    
    typealias ResponseCompletion = (_ error: Error?, _ success: Bool) -> ()
    typealias SCPlaylistsCompletion = ((_ error: Error?, _ scpPlaylistList: [SCPlaylist]?) -> ())
    //typealias SCPlaylistCompletion = (_ error: Error?, _ newPlaylistSnapshot: SCPlaylist?) -> ()
    
}
enum API: String {
    case url = "https://api.spotify.com"
}

class SCPListService: SilverCloudService {
    
    let username: String
    
    
    init(username: String) {
        self.username = username
    }
    
    func updateSCPList(withToken token: String, completion: @escaping SCPlaylistsCompletion) {
        
        SPTPlaylistList.playlists(forUser: username, withAccessToken: token) {
            (error, playlistsResponse) in
            print("errorSays: \(error?.localizedDescription)")
            guard error == nil, let playlistsList = playlistsResponse as? SPTPlaylistList else {
                print("haveError on SPTPlaylistList.playlists(forUser), error: \(error)")
                completion(error, nil)
                return
            }
            // handleList
            print("have playlistsResponse: \(playlistsResponse)")
            do {
                let partialPlaylists = try self.unwrapPlaylistList(sptPlaylistList: playlistsList)
                self.toSCPlaylists(fromPartialPlaylists: partialPlaylists, withToken: token) {
                    (error, playlists) in
                    if error == nil {
                        completion(nil, playlists)
                    } else { completion(error, nil) }
                }
            } catch {
                completion(error, nil)
            }
        }
    }
    
    func toSCPlaylists(fromPartialPlaylists partialPlaylists: [SPTPartialPlaylist], withToken token: String, completion:@escaping SCPlaylistsCompletion)  {
        var playlists = [SCPlaylist]()
        var uris = [URL]()
        for partial in partialPlaylists {
            if let uri = partial.uri {
                uris.append(uri)
            }
        }
        SPTPlaylistSnapshot.playlists(withURIs: uris, accessToken: token) {
            (error, playlistsSnapshotArray) in
            if let playlistsSnapshots = playlistsSnapshotArray as? [SPTPlaylistSnapshot] {
                for snapshot in playlistsSnapshots {
                    if let playlist = SCPlaylist(sptPlaylistSnapshot: snapshot) {
                    
                        playlists.append(playlist)
                    }
                }
                completion(nil, playlists)
            }
        }
    }
    
    func unwrapPlaylistList(sptPlaylistList: SPTPlaylistList?) throws -> [SPTPartialPlaylist]  {
        
        guard let playlistList = sptPlaylistList else {
            throw SCPListServiceError.missing(ErrorIdentifier.sptPlaylistList.rawValue)
        }
        guard let partials = playlistList.items as? [SPTPartialPlaylist] else {
            //if user hasn't created any playlists there is still a SPTPlaylistList Object with items == nil
            //could have feature to invite them to create a playlist
            throw SCPListServiceError.missing(ErrorIdentifier.sptPlaylistListItems.rawValue)
        }
        guard !partials.isEmpty else {
            throw SCPListServiceError.missing(ErrorIdentifier.sptPartialPlaylists.rawValue)
        }
        print("spatPartialPalylists have \(partials.count)")
        return partials
    }

}
enum SCPListServiceError: Error {
    case missing(String)
}


class PlaylistService: SilverCloudService, SessionHandler {
    func unfollowPlaylist(username: String, playlist: String, completion: @escaping ResponseCompletion) {
        handleSession() {
            (error, accessToken) in
            let path = "/v1/users/\(username)/playlists/\(playlist)/followers"
            guard let token = accessToken, let baseUrl = self.url, let url = URL(string: path, relativeTo: baseUrl) else {
                //handle no url
                return
            }
            let request = self.createRequestUrl(url: url, token: token, httpMethod: "DELETE")
            let networkOperation = NetworkOperation()
            networkOperation.handle(request: request) {
                (error, success) in
                completion(error, success)
                print("playlist got deleted: \(success)")
                if let errorNotNil = error {
                    print(errorNotNil)
                }
            }
        }
    }
    
    typealias SCPlaylistCompletion = (_ error: Error?, _ newPlaylistSnapshot: SCPlaylist?) -> ()
    //local playlist
    /*
    func handleCreatePlaylist(withName name: String, tracks: [SPTPartialTrack]?, completion: @escaping SCPlaylistCompletion) {
        handleSession() {
            (error, accessToken) in
            guard error == nil else {
                completion(error, nil)
                return
            }
            if let username = self.spotifySession?.canonicalUsername, let token = accessToken {
                SPTPlaylistList.createPlaylist(withName: name, forUser: username, publicFlag: true, accessToken: token) {
                    (error, sptPlaylistSnapshot) in
                    guard let playlistSnapshot = sptPlaylistSnapshot else {
                        completion(error, nil)
                        return
                    }
                    guard let playlist = SCPlaylist(sptPlaylistSnapshot: playlistSnapshot, tracks: tracks) else {
                        completion(PlaylistServiceError.unableToCreateSCPlaylist(ErrorIdentifier.localPlaylist.rawValue), nil)
                        return
                    }
                    //add tracks to spotify snapshot
                    if let playlistTracks = tracks {
                        self.addTracks(to: playlistSnapshot, token: token, tracks: playlistTracks)
                    }
                    completion(nil, playlist)
                }
            }
        }
    }*/
    
    func addTracks(to playlistSnapshot: SPTPlaylistSnapshot, token: String, tracks: [SPTPartialTrack]) {
        playlistSnapshot.addTracks(toPlaylist: tracks, withAccessToken: token) {
            (error) in
            guard error == nil else {
                return
            }
        }
    }

    
    func handleCreateNewPlaylist(withName name: String, accessToken token: String, tracks: [SPTPartialTrack]?, publicFlag: Bool, completion: @escaping SCPlaylistCompletion) {
        if let username = self.spotifySession?.canonicalUsername {
            SPTPlaylistList.createPlaylist(withName: name, forUser: username, publicFlag: true, accessToken: token) {
                (error, sptPlaylistSnapshot) in
                guard let playlistSnapshot = sptPlaylistSnapshot else {
                    completion(error, nil)
                    return
                }
                //could create local SCPLaylist with tracks to different, to avoid another call, but would not have cover art for tracks
                guard let playlistTracks = tracks else {
                    guard let scpPlaylist = SCPlaylist(sptPlaylistSnapshot: playlistSnapshot) else {
                        completion(PlaylistServiceError.unableToCreateSCPlaylist(ErrorIdentifier.newPlaylistSnapshot.rawValue), nil)
                        return
                    }
                    completion(nil, scpPlaylist)
                    return
                }
                //add tracks to playlist
                playlistSnapshot.addTracks(toPlaylist: playlistTracks, withAccessToken: token) {
                    (error) in
                    guard error == nil else {
                        completion(error, nil)
                        return
                    }
                    SPTPlaylistSnapshot.playlist(withURI: playlistSnapshot.uri, accessToken: token) {
                        (error, playlistWithTracks) in
                        
                        guard let sptPlaylistWithTracks = playlistWithTracks as? SPTPlaylistSnapshot, let scpPlaylistWithTracks = SCPlaylist(sptPlaylistSnapshot: sptPlaylistWithTracks) else {
                            completion(PlaylistServiceError.unableToCreateSCPlaylist(ErrorIdentifier.newPlaylistSnapshotWithTracks.rawValue), nil)
                            return
                        }
                        completion(nil, scpPlaylistWithTracks)
                    }
                }
            }
        }
    }
}

enum PlaylistServiceError: Error {
    case unableToCreateSCPlaylist(String)
    
}

class TracksService: SilverCloudService, SessionHandler {

    let tracksUrl: URL
    
    init(tracksUri: URL) {
        self.tracksUrl = tracksUri
    }
    typealias TracksCompletion = ((_ error: Error?, _ scpPlaylistList: [SPTPartialTrack]?) -> ())
    func handleTracks(withUri uri: URL, completion: @escaping TracksCompletion ) {
        var tracks: [SPTPartialTrack] = []
        handleSession() {
            (error, token) in
            guard let accessToken = token else  {
                completion(error, nil)
                return
            }
            //FIXME: handle error scenarios
            SPTPlaylistSnapshot.playlist(withURI: uri, accessToken: accessToken) {
                (error, playlistSnapshot) in
                guard let playlistSnapshot = playlistSnapshot as? SPTPlaylistSnapshot, let items = playlistSnapshot.firstTrackPage.items else {
                    completion(PlaylistError.missing(ErrorIdentifier.sptPlaylistSnapshot.rawValue), nil)
                    return
                }
                for item in items {
                    if let track = item as? SPTPartialTrack {
                        tracks.append(track)
                    }
                }
                completion(nil, tracks)
            }
        }
    }
}


protocol RequestHandler {
    
}


class SearchService: SilverCloudService, SessionHandler {
    
    typealias SearchResultsCompletion = ((_ error: Error?, _ searchResults: SearchResult?) -> ())
    func searchSpotify(with query: String, searchType: SPTSearchQueryType, completion: @escaping SearchResultsCompletion ) {
        handleSession() {
            (error, token) in
            guard let accessToken = token else {
                completion(error, nil)
                return
            }
            SPTSearch.perform(withQuery: query, queryType: searchType, accessToken: accessToken) {
                (error, queryResults) in
                guard error == nil else {
                    completion(error, nil)
                    return
                }
                
                guard let searchResults = queryResults as? SPTListPage, let musicSearchResults = searchResults.items else {
                    return
                }
                let searchResult = SearchResult(musicResults: musicSearchResults, searchType: searchType)
                print(musicSearchResults)
               
                completion(nil, searchResult)
            }
        }
    }
}

extension SilverCloudService {
    func createRequestUrl(url: URL, token: String, httpMethod: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}






