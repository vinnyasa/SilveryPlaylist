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

class NetworkOperationSDK {
    
    lazy var session:URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    typealias SPTPlaylisyListCompletion = (_ error: Error?, _ playlistList: SPTPlaylistList?) -> ()
    
    
    func downloadJSON(fromRequest request: URLRequest, completion: @escaping SPTPlaylisyListCompletion) {
        
        let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse ,  200...299 ~= httpResponse.statusCode else {
                //handle error
                completion(error, nil)
                return
            }
            /*
            guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] else {
                completion(NetworkError.unableToUnWrapJson, nil)
                return
            }
            completion(nil, json)
            */
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
    
    
    /*
    func requestPlaylistsList(user: String, token: String, completion: @escaping SCPlaylistsCompletion) {
       
        let path = "v1/users/\(user)/playlists"
        guard let baseUrl = self.url, let url = URL(string: path, relativeTo: baseUrl) else {
            //handle no url
            return
        }
        
        let request = createRequestUrl(url: url, token: token)
        let networkOperation = NetworkOperation()
        networkOperation.downloadJson(request: request) {
            (error, success) in
                completion(error, success)
            }
        }
    }*/
    /*
    func createRequestUrl(url: URL, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }*/
    
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
        print("partials count is: \(partialPlaylists.count)")
        var uris = [URL]()
        
        
        for partial in partialPlaylists {
            if let uri = partial.uri, let name = partial.name {
                uris.append(uri)
                print("name for partial: \(name)")
            } else { print("have no uri") }
        }
        print("uris count: \(uris.count)")
        SPTPlaylistSnapshot.playlists(withURIs: uris, accessToken: token) {
            (error, playlistsSnapshotArray) in
            if let playlistsSnapshots = playlistsSnapshotArray as? [SPTPlaylistSnapshot] {
                for snapshot in playlistsSnapshots {
                    print("snapShotName: \(snapshot.name)")
                    if let playlist = SCPlaylist(sptPlaylistSnapshot: snapshot) {
                        print("playlist name: \(playlist.name)")
                        playlists.append(playlist)
                    }
                }
                print("playlists count: \(playlists.count)")
                completion(nil, playlists)
            }
        }
    }
    
    func unwrapPlaylistList(sptPlaylistList: SPTPlaylistList?) throws -> [SPTPartialPlaylist]  {
        
        guard let playlistList = sptPlaylistList else {
            throw SCPListServiceError.missing(ErrorIdentifier.sptPlaylistList.rawValue)
        }
        print("have a sptPlaylistList: \(playlistList.items)")
        
        guard let partials = playlistList.items as? [SPTPartialPlaylist] else {
            //if user hasn't created any playlists there is still a SPTPlaylistList Object with items == nil
            //could have feature to invite them to create a playlist
            throw SCPListServiceError.missing(ErrorIdentifier.sptPlaylistListItems.rawValue)
        }
        print("printing playlistList: \(playlistList)")
        
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
            }
        }
    }
    
    typealias SCPlaylistCompletion = (_ error: Error?, _ newPlaylistSnapshot: SCPlaylist?) -> ()
    //local playlist
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
                        print("unable to create local playlist")
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
    }
    
    func addTracks(to playlistSnapshot: SPTPlaylistSnapshot, token: String, tracks: [SPTPartialTrack]) {
        playlistSnapshot.addTracks(toPlaylist: tracks, withAccessToken: token) {
            (error) in
            guard error == nil else {
                return
            }
        }
    }

    
    func handleCreateNewPlaylist(withName name: String, accessToken token: String, tracks: [SPTPartialTrack]?, completion: @escaping SCPlaylistCompletion) {
        if let username = self.spotifySession?.canonicalUsername {
            print("username at creating: \(username)")
            SPTPlaylistList.createPlaylist(withName: name, forUser: username, publicFlag: true, accessToken: token) {
                (error, sptPlaylistSnapshot) in
                guard let playlistSnapshot = sptPlaylistSnapshot else {
                    completion(error, nil)
                    return
                }
                if let owner = sptPlaylistSnapshot?.owner, let name = sptPlaylistSnapshot?.name {
                    print("owner at created snapshot is \(owner)")
                    print("name of playlist at returned snap is \(name)")
                } else { print("no owner at snapshot") }
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
                        if let owner = sptPlaylistWithTracks.owner, let name = sptPlaylistWithTracks.name {
                            print("owner at created snapshotwithtracks is \(owner)")
                            print("name of playlist at returned snapwithtracks is \(name)")
                        } else { print("no owner at snapshotwithtracks") }
                        

                        completion(nil, scpPlaylistWithTracks)
                    }
                }
                
                /*
                if let playlistTracks = tracks {
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
                }  else {
                    guard let scpPlaylist = SCPlaylist(sptPlaylistSnapshot: playlistSnapshot) else {
                        completion(PlaylistServiceError.unableToCreateSCPlaylist(ErrorIdentifier.newPlaylistSnapshot.rawValue), nil)
                        return
                    }
                    completion(nil, scpPlaylist)
                
                }
                */
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


protocol RequestHandler {
    
}


class SearchService: SilverCloudService, SessionHandler {
    
    typealias SearchResultsCompletion = ((_ error: Error?, _ searchResults: SearchResult?) -> ())
    func searchSpotify(with query: String, searchType: SPTSearchQueryType, completion: @escaping SearchResultsCompletion ) {
        handleSession() {
            (error, token) in
            guard let accessToken = token else {
                print("no token")
                completion(error, nil)
                return
            }
            print("perfoming query")
            SPTSearch.perform(withQuery: query, queryType: searchType, accessToken: accessToken) {
                (error, queryResults) in
                guard error == nil else {
                    print("error in query")
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



