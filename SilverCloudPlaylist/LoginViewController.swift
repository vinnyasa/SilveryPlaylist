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
    
    var silverCloudAuth = SilverCloudAuth()
    var auth: SPTAuth = SPTAuth.defaultInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        if let loginButton = loginButton  {
            configureButtonLayout(loginButton, radius: 8.0)
        }
        addCallbackObserver()
        setUpAuth()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addCallbackObserver() {
        let loginCallback = NotificationIdentifier.loginCallback.rawValue
        NotificationCenter.default.addObserver(forName: Notification.Name(loginCallback), object: nil, queue: nil) {
            (_) in
            self.performSegue(withIdentifier: SegueIdentifier.loginComplete.rawValue, sender: nil)
        }
    }
    
    
    @IBAction func loginToSpotify() {
        guard let loginUrl = auth.spotifyWebAuthenticationURL() else {
            return
        } 
        openSpotifyLogin(url: loginUrl)
    }
    
    func openSpotifyLogin(url: URL) {
        guard UIApplication.shared.canOpenURL(url) else {
            //FIXME: handle unableToOpenSafari
            return
        }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    enum SegueIdentifier: String {
        case showLogin = "showLogin"
        case loginComplete = "loginComplete"
    }
}






