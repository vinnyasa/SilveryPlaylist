//
//  SessionHandler.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/2/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation


protocol SessionHandler:  AuthDelegate {
    
}

extension SessionHandler {
    
    typealias TokenCompletion = ((_ error: Error?, _ token: String?) -> ())
    func handleSession(completion: @escaping TokenCompletion) {
        guard let scpSession = spotifySession else {
            return
        }
        guard scpSession.isValid() else {
            print("session not valid")
            setUpAuth()
            SPTAuth.defaultInstance().renewSession(scpSession) { (error, session)
                in
                guard let renewedSession = session, let token = renewedSession.accessToken else {
                    completion(error, nil)
                    return
                }
                //sdk should be saving session to defaults, test this behavior
                //renewed session is not being saved to NSUserDefaults by sdk, why??
                print("session has canonical as: \(renewedSession.canonicalUsername)")
                self.sessionToUserDefaults(session: renewedSession)
                completion(nil, token)
            }
            return
        }
        print("session is valid")
        // have valid session: good to go done with authentication
        //self.handleSCPUser(session: scpSession)
        print("user from valid session = \(scpSession.canonicalUsername)")
        completion(nil, scpSession.accessToken)
    }
    
    func sessionToUserDefaults(session: SPTSession) {
        let userDefaults = UserDefaults.standard
        let sessionData = NSKeyedArchiver.archivedData(withRootObject: session)
        userDefaults.set(sessionData, forKey: UserDefaultsKey.spotifySession.rawValue)
        userDefaults.synchronize()
    }
    
    var spotifySession: SPTSession? {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKey.spotifySession.rawValue) else { return nil }
        guard let session = NSKeyedUnarchiver.unarchiveObject(with: data) as? SPTSession else { return nil }
        return session
    }
}

enum UserDefaultsKey: String {
    case user = "UserKey"
    case spotifySession = "SpotifySession"
}

enum SessionError: Error {
    case unableToRenewSession
}
