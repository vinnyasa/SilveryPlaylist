//
//  AuthParam.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 11/28/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation

enum AuthParam: String {
    case clientId = "80c010b7d70b4ae39d75bf5a1f0bc791"
    case redirectURI = "silvercloudlogin://spotify/callback"
    case tokenSwapURL = "https://silvercloudswap.herokuapp.com/swap"
    case tokenRefreshURL = "https://silvercloudswap.herokuapp.com/refresh"
    case responseType = "code"
    

}

enum Session: String {
    case hasSession = "hasSPTSession"
}

struct SilverCloudAuth {
    
    let redirectURI = AuthParam.redirectURI.rawValue
    let tokenSwapURL = AuthParam.tokenSwapURL.rawValue
    let tokenRefreshURL = AuthParam.tokenRefreshURL.rawValue
    let responseType = AuthParam.responseType.rawValue
    let scopes = [SPTAuthPlaylistModifyPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistReadCollaborativeScope, SPTAuthUserReadPrivateScope, SPTAuthUserReadEmailScope]
    let sessionUserDefaultsKey = UserDefaultsKey.spotifySession.rawValue
    let clientId = AuthParam.clientId.rawValue
}

enum AuthError: Error {
    case unableToCreateLoginUrl
    case invalidScopes
    case badCallbackUri
    
}

enum NotificationIdentifier: String {
    case loginCallback = "loginCallback"
}

extension AuthDelegate {
    func setUpAuth() {
        print("settingAuth")
        /*
         SPTAuth.defaultInstance().clientID = silverCloudAuth.clientId
         SPTAuth.defaultInstance().redirectURL = URL(string: silverCloudAuth.redirectURI)
         SPTAuth.defaultInstance().requestedScopes = silverCloudAuth.scopes
         
         SPTAuth.defaultInstance().tokenSwapURL = URL(string: silverCloudAuth.tokenSwapURL)
         SPTAuth.defaultInstance().tokenRefreshURL = URL(string: silverCloudAuth.tokenRefreshURL)
         SPTAuth.defaultInstance().sessionUserDefaultsKey = silverCloudAuth.sessionUserDefaultsKey
         */
        //auth = SPTAuth.defaultInstance()
        auth.clientID = silverCloudAuth.clientId
        auth.redirectURL = URL(string: silverCloudAuth.redirectURI)
        auth.requestedScopes = silverCloudAuth.scopes
        auth.tokenSwapURL = URL(string: silverCloudAuth.tokenSwapURL)
        auth.tokenRefreshURL = URL(string: silverCloudAuth.tokenRefreshURL)
        auth.sessionUserDefaultsKey = silverCloudAuth.sessionUserDefaultsKey
    }
}


extension UIViewController {
    var spotifySession: SPTSession? {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKey.spotifySession.rawValue) else { return nil }
        guard let session = NSKeyedUnarchiver.unarchiveObject(with: data) as? SPTSession else { return nil }
        return session
    }
    /*
    var spotifyUserName: String? {
        guard let userName = UserDefaults.standard.string(forKey: UserDefaultsKey.user.rawValue) else {
            print("no unarchivedUserName")
            return nil
        }
        print("unarchivedUserName")
        return userName
    }*/
}
