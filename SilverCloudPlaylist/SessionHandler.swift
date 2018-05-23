/*********************************************************************
 ** Program name: SilverCloudPlaylist - Spotify playlists
 ** Author: Vinny Harris-Riviello
 ** Date: Dec 1, 2016
 ** Description: protocol SessionHandler. Handles the session, which
 ** will remain acive until it expires. 
 *********************************************************************/


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
            setUpAuth()
            SPTAuth.defaultInstance().renewSession(scpSession) {
                (error, session) in
                guard let renewedSession = session, let token = renewedSession.accessToken else {
                    completion(error, nil)
                    return
                }
                self.sessionToUserDefaults(session: renewedSession)
                completion(nil, token)
            }
            return
        }
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
