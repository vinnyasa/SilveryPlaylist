//
//  NetworkOperation.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 11/30/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation
/*
class NetworkOperation {
    var headers = [String]()
    lazy var session:URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    typealias JSONDictionaryCompletion = (_ json: [String: AnyObject]?, _ error: Error?) -> ()
    
    
    func downloadJSON(fromRequest request: URLRequest, completion: @escaping JSONDictionaryCompletion) {
        
        let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse ,  200...299 ~= httpResponse.statusCode else {
                //handle error
                completion(nil, error)
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] else {
                completion(nil, NetworkRequestError.unableToUnWrapJson)
                return
            }
            completion(json, nil)
            
        })
        dataTask.resume()
    }

}*/

class SearchService: SilverCloudService, SessionHandler {
    
}

class SCPListService {
    let username: String
    
    init(username: String) {
        self.username = username
    }
    
    typealias SCPListCompletion = ((_ error: Error?, _ scpPlaylistList: SCPList?) -> ())
    
    func updateSCPList(withToken token: String, completion: @escaping SCPListCompletion) {
        print("updating playlists")
        SPTPlaylistList.playlists(forUser: username, withAccessToken: token) {
            (error, playlistsResponse) in
            print("errorSays: \(error?.localizedDescription)")
            guard error == nil, let playlistsList = playlistsResponse as? SPTPlaylistList else {
                print("haveError on SPTPlaylistList.playlists(forUser), error: \(error)")
                completion(error, nil)
                return
            }
            // handleList
            print("have playlistsResponse")
            // getPlaylist Tracks
            /*
            if  let playlists = playlistsList.items as? [SPTPlaylistSnapshot] {
                for playlist in playlists  {
                    print("playlist: \(playlist.name)")
                }
            }
        */
            
            do {
                let partialPlaylists = try self.unwrapPlaylistList(sptPlaylistList: playlistsList)
                let scpList = try self.toSCPList(fromPartialPlaylists: partialPlaylists, withToken: token)
                completion(nil, scpList)
                
            } catch {
                completion(error, nil)
            }
        }
    }
    
    func toSCPList(fromPartialPlaylists partialPlaylists: [SPTPartialPlaylist], withToken token: String) throws -> SCPList {
        var sptPlaylistsSnapshot = [SPTPlaylistSnapshot]()
        for partial in partialPlaylists {
            if let uri = partial.uri{
                SPTPlaylistSnapshot.playlist(withURI: uri, accessToken: token) {
                    (error, playlistSnapshot) in
                    guard let playlistSnapshot = playlistSnapshot as? SPTPlaylistSnapshot else {
                        print("unable to create snapshot for this playlist")
                        return
                    }
                    sptPlaylistsSnapshot.append(playlistSnapshot)
                }
            }
        }
        guard !sptPlaylistsSnapshot.isEmpty else {
            throw SCPListServiceError.missing(ErrorIdentifier.sptPlaylistArraySnapshot.rawValue)
        }
        do {
            return try SCPList(sptPlaylistsSnapshot: sptPlaylistsSnapshot)
            
        } catch {
            throw error
        }
    }
    
    func unwrapPlaylistList(sptPlaylistList: SPTPlaylistList?) throws -> [SPTPartialPlaylist]  {
        var sptPartialPlaylists: [SPTPartialPlaylist] = []
        guard let playlistList = sptPlaylistList else {
            throw SCPListServiceError.missing(ErrorIdentifier.sptPlaylistList.rawValue)
        }
        print("have a sptPlaylistList: \(playlistList)")
        guard let playlistListItems = playlistList.items as? [SPTPartialPlaylist] else {
            //if user hasn't created any playlists there is still a SPTPlaylistList Object with 0 iitems == nil
            //could have feature to invite them to create a playlist
            print("user has 0 playlists")
            throw SCPListServiceError.missing(ErrorIdentifier.sptPlaylistListItems.rawValue)
        }
        print("printing playlistList: \(playlistList)")
        
        for playlist in playlistListItems  {
            sptPartialPlaylists.append(playlist)
        }
        
        guard !sptPartialPlaylists.isEmpty else {
            throw SCPListServiceError.missing(ErrorIdentifier.sptPartialPlaylists.rawValue)
        }
        return sptPartialPlaylists
    }
    
    enum SCPListServiceError: Error {
        case missing(String)
    }
    
}



class PlaylistService: SilverCloudService, SessionHandler {
    
    typealias NewPlaylistSnapshotCompletion = (_ error: Error?, _ newPlaylistSnapshot: SCPlaylist?) -> ()
    //what kind of completion do I need?
    //token should be passed in to avoid so many calls
    func handleCreateNewPlaylist(withName name: String, accessToken token: String, tracks: [SPTPartialTrack]?, completion: @escaping NewPlaylistSnapshotCompletion) {
        if let username = self.spotifySession?.canonicalUsername {
            SPTPlaylistList.createPlaylist(withName: name, forUser: username, publicFlag: true, accessToken: token) {
                (error, sptPlaylistSnapshot) in
                guard let sptPlaylistSnapshot = sptPlaylistSnapshot else {
                    completion(error, nil)
                    return
                }
                if let playlistTracks = tracks {
                    //add tracks to playlist
                    sptPlaylistSnapshot.addTracks(toPlaylist: playlistTracks, withAccessToken: token) {
                        (error) in
                        guard error == nil else {
                            completion(error, nil)
                            return
                        }
                        // tracks added succesfully, create SCPLaylist and pass to controller
                        guard let scpPlaylist = SCPlaylist(sptPlaylistSnapshot: sptPlaylistSnapshot) else {
                            completion(PlaylistServiceError.unableToCreateSCPlaylist, nil)
                            return
                        }
                        completion(nil, scpPlaylist)
                    }
                }
                //createNewPlaylist, then add tracks then create an SCPPlaylist and add to array. regardless if tracks are added, return that SCPlaylist
            }
        }
    }
    
    enum PlaylistServiceError: Error {
        case unableToCreateSCPlaylist
    
    }
    
    /*
    func handleCreateNewPlaylist(withName name: String, completion: @escaping NewPlaylistSnapshotCompletion) {
        handleSession() {
            (error, token) in
            guard error == nil else {
                completion(error, nil)
                return
            }
            if let username = self.spotifySession?.canonicalUsername, let token = token {
                SPTPlaylistList.createPlaylist(withName: name, forUser: username, publicFlag: true, accessToken: token) {
                    (error, sptPlaylistSnapshot) in
                    guard let sptPlaylistSnapshot = sptPlaylistSnapshot else {
                        completion(error, nil)
                        return
                    }
                    completion(nil, sptPlaylistSnapshot)
                }
            }
        }
    }*/
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
                print ("badToken error: \(error)")
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



class SilverCloudService {
    var auth: SPTAuth = SPTAuth.defaultInstance()
    var silverCloudAuth = SilverCloudAuth()
    
}

protocol FetchType {
    
}



/*
class UserService: SilverCloudService {
    /*
    let session: SPTSession
    
    init(session: SPTSession, endPoint: String) {
        self.session = session
        super.init(endPoint: endPoint)
    }
    */
    
    typealias SilverCloudCompletion = (_ user: SCPUser?, _ error: Error?) -> ()
    //var delegate: NetworkDelegate?
    
    /*
    func fetchRequest(withToken token: String, completion: @escaping SilverCloudCompletion) {
        guard let url = url else {
            completion(nil, NetworkRequestError.unableToCreateURL)
            return
        }
        let networkOperation = NetworkOperation()
        //networkOperation.delegate = delegate
        networkOperation.downloadJSON {
            (jsonDictionary, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            do {
                let scpUser = try User(jsonDictionary: jsonDictionary)
                //completion(try Moon(moonsDictionary: JSONDictionary))
                completion(scpUser, nil)
            } catch {
                completion(nil, ObjectError.unableToCreateFromJson)
                //self.delegate?.catchErrorNicely(NetworkRequestError.InvalidHTTPResponse)
            }
        }
    }*/
    /*
    func fetch(sptSession: SPTSession) {
        
        guard let token = session.accessToken else {
            // throw some error
            return
            
        }
        SPTUser.requestCurrentUser(withAccessToken: token) {
            (error, userResponse) in
            //userObjectDictionary
            guard error == nil else {
                print("didn't get user")
                //FIXME: handle error
                return
            }
            do {
                let scpUser = try SCPUser(sptUser: userResponse as? SPTUser)
                //completion(try Moon(moonsDictionary: JSONDictionary))
                self.saveUser(user: scpUser)
            } catch {
                // didn't build user
                
            }
        }
        
        
    }*/
    /*
    func saveUser(user: SCPUser) {
        //demo only
        let userDefaults = UserDefaults.standard
        let sessionData = NSKeyedArchiver.archivedData(withRootObject: user)
        userDefaults.set(sessionData, forKey: UserDefaultsKey.user.rawValue)
        //userDefaults.set(true, forKey: Session.hasSession.rawValue)
        userDefaults.synchronize()
        
    }*/
    
}*/

//GET "https://api.spotify.com/v1/users/wizzler/playlists" -H "Accept: application/json"

//GET "https://api.spotify.com/v1/me" -H "Authorization: Bearer {your access token}"

// GET "https://api.spotify.com/v1/me" -H "Accept: application/json" -H "Authorization: Bearer BQCY8kYQL5a3zTS4kRFotNikTfnGQ1bkAsPVexIza2Shjh4Phynzkuxdsq7xkw0JlS4DoM2ELkvD0_CrEb7WSZbkEz9ym7xJsLpjTBeC0NN0kcBk_MoAIfD4wt9_2r6D8YnBYdZ47tG2UNNDE2YkgRGlmP67goFzOCgIJN9NVi7ZtwCLmSeumQBWXhdzA-wvEy4QLscJKZFm63sx_HvHHai0FEy2"
/*
class SilverCloudService {
    
    var baseURL: URL?{
        return URL(string: "https://api.spotify.com/v1/")
    }
    let endPoint: String
    var url: URL? {
        return URL(string: endPoint, relativeTo: baseURL)
    }
    
    init(endPoint: String) {
        self.endPoint = endPoint
    }

}*/
/*
protocol FetchType {
    associatedtype SilverCloudCompletion
    func fetchRequest(withToken token: String, completion: SilverCloudCompletion)
}*/
/*
enum NetworkRequestError: Error {
    case invalidHTTPResponse(String)
    case unableToUnWrapJson(String)
    case unableToCreateURL(String)
    
}*/


