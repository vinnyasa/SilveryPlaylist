//
//  LoginViewController.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 11/27/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, AuthDelegate {
    
    @IBOutlet weak var loginButton: UIButton?
    //let clientId = "80c010b7d70b4ae39d75bf5a1f0bc791"
    //let callbackUri = "silvercloudlogin://spotify/callback"
    //let tokenSwapURL = "https://silvercloudswap.herokuapp.com/swap"
    //let tokenRefreshURL = "https://silvercloudswap.herokuapp.com/refresh"
    var silverCloudAuth = SilverCloudAuth()
    var auth: SPTAuth = SPTAuth.defaultInstance()
    
    /*
    var hasSession = false {
        didSet { if hasSession { performSegue(withIdentifier: SegueIdentifier.loginComplete.rawValue, sender: nil)}
        }
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        if let loginButton = loginButton  {
            configureButtonLayout(loginButton)
        }
        addCallbackObserver()
        setUpAuth()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addCallbackObserver() {
        //NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: Notification.Name(callbackNotification), object: nil)
        //NotificationCenter.default.addObserver(forName: Notification.Name(callbackNotification), object: nil, queue: nil, using: handleNotification)
        let loginCallback = NotificationIdentifier.loginCallback.rawValue
        NotificationCenter.default.addObserver(forName: Notification.Name(loginCallback), object: nil, queue: nil) {
            (_) in
            self.performSegue(withIdentifier: SegueIdentifier.loginComplete.rawValue, sender: nil)
            //self.hasSession = true
        }
    }
    
    
    @IBAction func loginToSpotify() {
        
        print("requestingLoginUrl")
        /* manual url:
        guard let manualLoginUrl =  try? createLoginUrl(sptClientId: clientId, scopes: scopes, redirectUri: callbackUri) else {
            //FIXME: handle error
            print ("have authError")
            return
        }
         guard let loginUrl = SPTAuth.loginURL(forClientId: silverCloudAuth.clientId, withRedirectURL: URL(string: silverCloudAuth.redirectURI)!, scopes: silverCloudAuth.scopes, responseType: silverCloudAuth.responseType) else {
         return
         }
        */
        
        guard let loginUrl = auth.spotifyWebAuthenticationURL() else {
            print("don't have spotifyWebAuthenticationURL() ")
            return
        }
        openSpotifyLogin(url: loginUrl)
        
        
        //testingSegue
        //hasSession = true
    }
    
    func openSpotifyLogin(url: URL) {
        guard UIApplication.shared.canOpenURL(url) else {
            //FIXME: handle unableToOpenSafari
            return
        }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            print("opening from iOS10 to url: \(url)")
        } else {
            UIApplication.shared.openURL(url)
            print("Opened from olded iOS")
        }
    }
    //https://accounts.spotify.com/authorize?nolinks=true&nosignup=false&response_type=code&scope=playlist-modify-private%20playlist-modify-public%20playlist-read-private%20playlist-read-collaborative%20user-read-private%20user-read-email&utm_source=spotify-sdk&utm_medium=ios-sdk&utm_campaign=ios-sdk&redirect_uri=silvercloudlogin%3A%2F%2Fspotify%2Fcallback&show_dialog=true&client_id=80c010b7d70b4ae39d75bf5a1f0bc791

    ///authorize/?client_id=80c010b7d70b4ae39d75bf5a1f0bc791&response_type=code&redirect_uri=silvercloudlogin:%2F%2Fspotify%2Fcallback&scope=playlist-modify-private%20playlist-modify-public%20playlist-read-private%20playlist-read-collaborative&show_dialog=false 
    

    /*
    func configureLoginUrl() throws -> URL {
        guard let redirectURL = URL(string: silverCloudAuth.redirectURI) else {
            throw AuthError.badCallbackUri
        }
        guard let loginUrl = SPTAuth.loginURL(forClientId: silverCloudAuth.clientId, withRedirectURL: redirectURL, scopes: silverCloudAuth.scopes, responseType: silverCloudAuth.responseType) else {
            throw AuthError.unableToCreateLoginUrl
        }
        return loginUrl
    }*/

    
   

}
extension LoginViewController {
    func configureButtonLayout(_ button: UIButton) {
        button.layer.borderWidth = 0.8
        button.layer.cornerRadius = 8.0
    }
    /*
    func createLoginUrl(sptClientId: String, scopes: [Any], redirectUri: String) throws -> URL? {
        var scopesString = ""
        var count = scopes.count - 1
        
        for scope in scopes {
            var scopeStr: String
            if count > 0 {
                scopeStr = ("\(scope)%20")
                count -= 1
            } else {
                scopeStr = ("\(scope)")
            }
            scopesString.append(scopeStr)
        }
        guard !scopesString.isEmpty else {
            throw AuthError.invalidScopes
        }
        let loginUrlString = "https://accounts.spotify.com/authorize/?client_id=\(sptClientId)&response_type=code&redirect_uri=\(redirectUri)&scope=\(scopesString)&show_dialog=false"
        
        guard let url = URL(string: loginUrlString) else {
            throw AuthError.unableToCreateLoginUrl
        }
        return url
    }*/
}

enum SegueIdentifier: String {
    case showLogin = "showLogin"
    case loginComplete = "loginComplete"
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

