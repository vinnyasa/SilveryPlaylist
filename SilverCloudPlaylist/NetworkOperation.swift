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



class SCPListService: SilverCloudService, SessionHandler {
    let username: String
    
    init(username: String) {
        self.username = username
    }
    
    typealias SCPListCompletion = ((_ error: Error?, _ scpPlaylistList: SCPList?) -> ())
    
    func updateSCPList(withToken token: String!, completion: @escaping SCPListCompletion) {
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
            
            if  let playlists = playlistsList.items as? [SPTPlaylistSnapshot] {
                for playlist in playlists  {
                    print("playlist: \(playlist.name)")
                }
            }
            
            func toSCPList(from partialPlaylists: [SPTPartialPlaylist]) {
                var scplaylistList = [SCPlaylist]()
                for partial in partialPlaylists {
                    let trackService = TracksService(tracksUri: partial.uri)
                    //handleTracks(withUri: partial.uri)
                    trackService.handleTracks(withUri: partial.uri) {
                        (error, partialTracks) in
                        guard let tracks = partialTracks, error == nil else {
                            completion(error, nil)
                            return
                        }
                        guard let scpPlaylist = SCPlaylist(spotifyPlaylist: partial, sptTracks: tracks) else {
                            completion(error, nil)
                            return
                        }
                        scplaylistList.append(scpPlaylist)
                    }
                }
                completion(nil, SCPList(playlists: scplaylistList))
            }

            do {
                let partialPlaylists = try self.unwrapPlaylistList(sptPlaylistList: playlistsList)
                toSCPList(from: partialPlaylists)
            } catch {
                completion(error, nil)
            }
        }
    }


    
    func unwrapPlaylistList(sptPlaylistList: SPTPlaylistList?) throws -> [SPTPartialPlaylist]  {
        var sptPartialPlaylists: [SPTPartialPlaylist] = []
        guard let playlistList = sptPlaylistList else {
            throw PlaylistError.missing(ErrorIdentifier.sptPlaylistList.rawValue)
        }
        print("have a sptPlaylistList: \(playlistList)")
        guard let playlistListItems = playlistList.items as? [SPTPartialPlaylist] else {
            //if user hasn't created any playlists there is still a SPTPlaylistList Object with 0 iitems == nil
            //could have feature to invite them to create a playlist
            print("user has 0 playlists")
            throw PlaylistError.missing(ErrorIdentifier.sptPlaylistListItems.rawValue)
        }
        print("printing playlistList: \(playlistList)")
        
        for playlist in playlistListItems  {
            sptPartialPlaylists.append(playlist)
        }
        
        guard !sptPartialPlaylists.isEmpty else {
            throw PlaylistError.missing(ErrorIdentifier.sptPartialPlaylists.rawValue)
        }
        return sptPartialPlaylists
    }
    
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


enum ValidationError: Error {
    case noSCPListWith(String)
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


