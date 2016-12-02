//
//  SCPListTableViewController.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/1/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import UIKit

class SCPListTableViewController: UITableViewController, AuthDelegate {

    var playlists = [SCPlaylist]()
    
    
    var auth: SPTAuth = SPTAuth.defaultInstance()
    var silverCloudAuth = SilverCloudAuth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        configureTable()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("callingViewDidAppear")
        handleSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Session
    
    func handleSession() {
        guard let scpSession = spotifySession else {
            performSegue(withIdentifier: SegueIdentifier.showLogin.rawValue, sender: self)
            return
        }
        // firstLoginDidHappen
        guard scpSession.isValid() else {
            print("session not valid")
            setUpAuth()
            //not valid session, renew session, might have to set again?: setUpAuth()
            SPTAuth.defaultInstance().renewSession(scpSession) { (error, session)
                in
                guard let renewedSession = session, error == nil else {
                    //FIXME: unable to renew, handle error
                    print("unable to renew session")
                    return
                }
                //self.session = session
                
                self.updatePlaylists(token: renewedSession.accessToken)
                //sdk should be saving session to defaults, test this behavior
                //FIXME: renewed session is not being saved to NSUserDefaults by sdk, why?? fix... pronto
            }
            return
        }
        print("session is valid")
        // have valid session: good to go done with authentication
        //self.handleSCPUser(session: scpSession)
        self.updatePlaylists(token: scpSession.accessToken)
    }
    //for testing: func handleSCPUser(session: SPTSession) {
    func handleSCPUser(session: SPTSession) {
        print("getting user")
        SPTUser.requestCurrentUser(withAccessToken: session.accessToken) {
            (error, userResponse) in
            //userObjectDictionary
            guard error == nil else {
                print("didn't get user")
                //FIXME: handle error
                return
            }
            if let user = userResponse as? SPTUser {
                //self.id = user.canonicalUserName
                print("haveUserFromRequest")
                self.userToUserDefaults(user: user)
            }
        }
    }

    func userToUserDefaults(user: SPTUser) {
        //demo only
        print("userToUD")
        let userString = user.canonicalUserName
        let userDefaults = UserDefaults.standard
        userDefaults.set(userString, forKey: UserDefaultsKey.user.rawValue)
        userDefaults.synchronize()
        print("ud syncronized")
    }

    // MARK: - Playlists

    func updatePlaylists(token: String) {
        
        if let sptUser = spotifyUserName {
            print("have user in UD: \(sptUser), getting playlists")
            let service = SCPListService(username: sptUser)
            service.updateSCPList(withToken: token) {
                (error, playlists) in
                guard let scpList = playlists else {
                    //FIXME: handle error
                    print("scpServiceHandler has error: \(error)")
                    if let playlistError = error as? PlaylistError {
                        switch playlistError {
                        case .missing(let identifier):
                            print("scpServiceHandler has error at: \(identifier)")
                            //could have if identifier == "items", invite them to create playlist feature
                        }
                    } else { print ("error in request, error: \(error)")}
                    return
                }
                print("have Playlists: count: \(scpList.playlists.count) ")
                self.playlists = scpList.playlists
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - configure view
    func configureTable() {
        tableView.rowHeight = 77
        self.title = "Playlists"
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return playlists.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SilverCloudCell", for: indexPath) as! SCPListTableViewCell
        
        for playlist in playlists {
            if let name = playlist.name, let image = playlist.images[1] {
                cell.scpNameLabel?.text = name
                cell.scpImageView?.image = image
            }
        }
        return cell
    }
    
    
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
    
    
    
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
 
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    @IBAction func loginSuccessFul(_ segue:UIStoryboardSegue) {
        //hasSession = true
        /*
         let loginVC = segue.source as? LoginViewController
         if let _ = loginVC?.hasSession {
         
         }*/
    }
    
    // MARK: - Navigation
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}


