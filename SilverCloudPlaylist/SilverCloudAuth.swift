/*********************************************************************
 ** Program name: SilverCloudPlaylist - Spotify playlists
 ** Author: Vinny Harris-Riviello
 ** Date: Dec 1, 2016
 ** Description: SilverCloudAuth struct. Handles the autherization
 ** and swaping of keys.
 *********************************************************************/

import Foundation

enum AuthParam: String {
    case responseType = "code"
    case redirectURI = "redirectURI"
    case tokenSwapURL = "tokenSwapURL"
    case tokenRefreshURL = "tokenRefreshURL"
    case clientId = "client"
}

enum Session: String {
    case hasSession = "hasSPTSession"
}

struct SilverCloudAuth {
    
    let responseType = AuthParam.responseType.rawValue
    let scopes = [SPTAuthPlaylistModifyPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistReadCollaborativeScope, SPTAuthUserReadPrivateScope, SPTAuthUserReadEmailScope]
    let sessionUserDefaultsKey = UserDefaultsKey.spotifySession.rawValue
}

enum AuthError: Error {
    case unableToCreateLoginUrl
    case invalidScopes
    case badCallbackUri
    case invalidClient
}

enum NotificationIdentifier: String {
    case loginCallback = "loginCallback"
}

extension AuthDelegate {
    func setUpAuth() {
        auth.requestedScopes = silverCloudAuth.scopes
        auth.sessionUserDefaultsKey = silverCloudAuth.sessionUserDefaultsKey
        if let client = client {
            auth.clientID = client
            print("auth has client")
        } else { print("unable to get clientID") }
        if let redirectUri = redirectURI {
            auth.redirectURL = URL(string: redirectUri)
            print("auth has redirectIRI")
        } else { print("unable to get redirectURI") }
        if let tokenSwapURL = tokenSwapURL {
            auth.tokenSwapURL = URL(string: tokenSwapURL)
            print("auth has tokenSwapURL")
        } else { print("unable to get tokenSwapURL") }
        if let tokenRefreshURL = tokenRefreshURL {
            auth.tokenRefreshURL = URL(string: tokenRefreshURL)
            print("auth has token refreshURL")
        } else { print("unable to get tokenRefreshURL") }
    }
    
    
    var client: String? {
        if let clientId = fetchPath(key: AuthParam.clientId.rawValue) {
            return clientId
        } else { return nil }
    }
    func fetchPath(key: String) -> String? {
        guard let path = Bundle.main.path(forResource: "Client", ofType: "plist"), let id = NSDictionary(contentsOfFile: path) as? [String: Any], let client = id[key] as? String  else {
            return nil
        }
        return client
    }
    var redirectURI: String? {
        if let uri = fetchPath(key: AuthParam.redirectURI.rawValue) {
            return uri
        } else { return nil }
    }
    
    var tokenSwapURL: String? {
        if let uri = fetchPath(key: AuthParam.tokenSwapURL.rawValue) {
            return uri
        } else { return nil }
    }
    var tokenRefreshURL: String? {
        if let uri = fetchPath(key: AuthParam.tokenRefreshURL.rawValue) {
            return uri
        } else { return nil }
    }
}

extension UIViewController {
    var spotifySession: SPTSession? {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKey.spotifySession.rawValue) else { return nil }
        guard let session = NSKeyedUnarchiver.unarchiveObject(with: data) as? SPTSession else { return nil }
        return session
    }
}
