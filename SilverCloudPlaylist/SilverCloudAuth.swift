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
    case sessionUserDefaultsKey = "SpotifySession"

}

struct SilverCloudAuth {
    
    let redirectURI = AuthParam.redirectURI.rawValue
    let tokenSwapURL = AuthParam.tokenSwapURL.rawValue
    let tokenRefreshURL = AuthParam.tokenRefreshURL.rawValue
    let responseType = AuthParam.responseType.rawValue
    let scopes = [SPTAuthPlaylistModifyPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistReadCollaborativeScope]
    let sessionUserDefaultsKey = AuthParam.sessionUserDefaultsKey.rawValue
    let clientId = AuthParam.clientId.rawValue
}

enum AuthError: Error {
    case unableToCreateLoginUrl
    case invalidScopes
    case badCallbackUri
    
}
