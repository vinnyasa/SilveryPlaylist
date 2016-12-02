//
//  User.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 11/30/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation


struct SCPUser {
    let id: String?
    let email: String?
    
    
    init(sptUser: SPTUser) throws {
        id = sptUser.canonicalUserName
        email = sptUser.emailAddress
        
    }
}

enum UserDefaultsKey: String {
    case user = "UserKey"
    case spotifySession = "SpotifySession"
}
//GET "https://api.spotify.com/v1/users/wizzler/playlists" -H "Accept: application/json"

//GET "https://api.spotify.com/v1/me" -H "Authorization: Bearer {your access token}"

// GET GET "https://api.spotify.com/v1/me" -H "Accept: application/json" -H "Authorization: Bearer BQCY8kYQL5a3zTS4kRFotNikTfnGQ1bkAsPVexIza2Shjh4Phynzkuxdsq7xkw0JlS4DoM2ELkvD0_CrEb7WSZbkEz9ym7xJsLpjTBeC0NN0kcBk_MoAIfD4wt9_2r6D8YnBYdZ47tG2UNNDE2YkgRGlmP67goFzOCgIJN9NVi7ZtwCLmSeumQBWXhdzA-wvEy4QLscJKZFm63sx_HvHHai0FEy2"
