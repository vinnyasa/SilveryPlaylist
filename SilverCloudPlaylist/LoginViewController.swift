//
//  LoginViewController.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 11/27/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton?
    //let clientId = "80c010b7d70b4ae39d75bf5a1f0bc791"
    //let callbackUri = "silvercloudlogin://spotify/callback"
    //let tokenSwapURL = "https://silvercloudswap.herokuapp.com/swap"
    //let tokenRefreshURL = "https://silvercloudswap.herokuapp.com/refresh"
    let silverCloudAuth = SilverCloudAuth()
    //usingFroTestingsegue delete before sending
    var hasSession = false {
        didSet { if hasSession { performSegue(withIdentifier: SegueIdentifier.loginComplete.rawValue, sender: nil)}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        if let loginButton = loginButton  {
            configureButtonLayout(loginButton)
        }
        addCallbackObserver()
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
            self.performSegue(withIdentifier: "loginSuccesful", sender: nil)
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
        */
        
        guard let loginUrl = SPTAuth.loginURL(forClientId: silverCloudAuth.clientId, withRedirectURL: URL(string: silverCloudAuth.redirectURI)!, scopes: silverCloudAuth.scopes, responseType: silverCloudAuth.responseType) else {
            return
        }
        setUpAuth()
        openSpotifyLogin(url: loginUrl)
        //openSpotifyLogin(url: URL(string: "https://www.google.com")!)
        
        //testingSegue
        hasSession = true
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
    
    func setUpAuth() {
        //SPTAuth.defaultInstance().clientID = silverCloudAuth.clientId
        //SPTAuth.defaultInstance().redirectURL = URL(string: silverCloudAuth.redirectURI)
        //SPTAuth.defaultInstance().requestedScopes = silverCloudAuth.scopes
        SPTAuth.defaultInstance().tokenSwapURL = URL(string: silverCloudAuth.tokenSwapURL)
        SPTAuth.defaultInstance().tokenRefreshURL = URL(string: silverCloudAuth.tokenRefreshURL)
        SPTAuth.defaultInstance().sessionUserDefaultsKey = silverCloudAuth.sessionUserDefaultsKey
    }
    
    func configureLoginUrl() throws -> URL {
        guard let redirectURL = URL(string: silverCloudAuth.redirectURI) else {
            throw AuthError.badCallbackUri
        }
        guard let loginUrl = SPTAuth.loginURL(forClientId: silverCloudAuth.clientId, withRedirectURL: redirectURL, scopes: silverCloudAuth.scopes, responseType: silverCloudAuth.responseType) else {
            throw AuthError.unableToCreateLoginUrl
        }
        return loginUrl
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: WebView Delegate
    /*
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        /*if request.URLString.hasPrefix(SpotifyRedirectURI) {
            // Example of a correct response::
            // projectName://spotify/callback?code=AQCY0mycN16svdc7Edj3jH1BUw...
            if let fragment = request.URL!.query,
                code = parameterValue(CodeKey, fragment: fragment) {
                // Now transfer URL to Spotify sessions’ constructor
                SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(request.URL, callback: { (error: NSError!, session: SPTSession!) -> Void in
                    if session != nil {
                        // Notification about the login’s success
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        // Notification about the login’s mistake
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            } else if let fragment = request.URL!.query,
                error = parameterValue(ErrorKey, fragment: fragment) {
                if error == "access_denied" {
                    // Cancel
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.presentViewController(Alert.alertWithText(error, cancelAction: {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }), animated: true, completion: nil)
                }
            }
        }*/
        print(request)
        if let _ = request.url?.absoluteString.hasPrefix(callbackUri) {
            if let path = request.url?.query, let code = parameterValue(name: CodeKey, path: path)
        }
        
        return true
    }
    
    private func parameterValue(name: String, path: String) -> String? {
        let pairs = fragment.componentsSeparatedByString("&")
        for pair in pairs {
            let components = pair.componentsSeparatedByString("=")
            if components.first == name {
                return components.last
            }
        }
        return nil
    }
    */
}
extension LoginViewController {
    func configureButtonLayout(_ button: UIButton) {
        button.layer.borderWidth = 0.8
        button.layer.cornerRadius = 8.0
    }
    
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
    }
}

extension UIViewController {
    enum SegueIdentifier: String {
        case showLogin = "showLogin"
        case loginComplete = "loginComplete"
    }
    
}

