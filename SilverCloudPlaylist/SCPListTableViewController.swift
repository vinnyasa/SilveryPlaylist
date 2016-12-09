//
//  SCPListTableViewController.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/1/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import UIKit

class SCPListTableViewController: UITableViewController, SessionHandler {

    var playlists = [SCPlaylist]()
    var auth: SPTAuth = SPTAuth.defaultInstance()
    var silverCloudAuth = SilverCloudAuth()
    var isInitial = true
    var playlistsToDelete = [SCPlaylist]()
    @IBOutlet weak var playlistImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isInitial {
            sessionUpdate()
            isInitial = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Session
    
    func sessionUpdate() {
        guard let _ = spotifySession else {
            performSegue(withIdentifier: SegueIdentifier.showLogin.rawValue, sender: self)
            return
        }
        // firstLoginDidHappen
        handleSession() {
            (error, accessToken) in
            guard error == nil, let token = accessToken else {
                return
            }
            print("this is token: \(token), finished there")
            self.updatePlaylists(withtoken: token)
        }
    }
    
    func testOwner(token: String) {
        SPTUser.requestCurrentUser(withAccessToken: token) {
        (error, user) in
            if let user = user as? SPTUser, let display = user.displayName, let canonical = user.canonicalUserName {
                print("user displayName is: \(display)")
                print("user displayName is: \(canonical)")
            }
        }
    }
    
    // MARK: - Playlists
    func updatePlaylists(withtoken token: String) {
        if let sptUser = spotifySession?.canonicalUsername {
            let service = SCPListService(username: sptUser)
            // let's try this
            service.updateSCPList(withToken: token) {
                (error, scpPlaylists) in
                guard let playlists = scpPlaylists else {
                    //handle errors
                    print("scpServiceHandler has error: \(error)")
                    guard  let playlistError = error as? SCPListServiceError else {
                        print ("error in request, error: \(error)")
                        return
                    }
                    switch playlistError {
                    case .missing(let identifier):
                        print("scpServiceHandler has error at: \(identifier)")
                        //could have if identifier == "items", invite them to create playlist feature
                        if identifier == ErrorIdentifier.sptPlaylistListItems.rawValue {
                            self.playlistCreateInvite()
                        }
                    }
                    return
                }
                //should put an activity indicator
                print("in main thread")
                self.playlists = playlists
                self.tableView.reloadData()
            }
        }
    }
    
    func playlistCreateInvite() {
        // a tour or something to teach them how to add playlists
        print("inviting user to create playlists")
    }
    
    // MARK: - configure view
    func configureTable() {
        tableView.rowHeight = 77
        self.title = Title.playlist.rawValue
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "silverCloudCell", for: indexPath) as! SCPListTableViewCell
        print("loading cell")
        let playlist = playlists[indexPath.row]
        if let name = playlist.name, let image = playlist.smallImage {
            cell.scpNameLabel?.text = name
            cell.scpImageView?.image = image
        }
        if let scpImageView = cell.scpImageView  {
            //configureImageView(scpImageView, radius: 15.0)
            scpImageView.rounded()
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
            let playlist = playlists.remove(at: indexPath.row)
            playlistsToDelete.append(playlist)
            // delete from spotify. They don't have endpoint for deleting a playlist in the Web API; the notion of deleting a playlist is not relevant within the Spotify’s playlist system. Even if you are the playlist’s owner and you choose to manually remove it from your own list of playlists, you are simply unfollowing it. So that would be the way to handle it.
            if let username = spotifySession?.canonicalUsername, let playlistId = playlist.id {
                let playlistService = PlaylistService()
                playlistService.unfollowPlaylist(username: username , playlist: playlistId) {
                    (error, success) in
                    guard success else {
                        //FIXME: unable to unfollow, maybe trigger some alert ?
                        return
                    }
                }
            }
            
            
            //delete playlist from dataBase
            tableView.deleteRows(at: [indexPath], with: .fade)
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
    
    @IBAction func savePlaylist(_ segue:UIStoryboardSegue) {
         let newPlaylistVC = segue.source as? NewPlaylistTableViewController
        //activityIndicator.isAnimating = true
         if let name = newPlaylistVC?.name, let tracks = newPlaylistVC?.tracks {
            //createNewPlaylist, then add tracks then create an SCPPlaylist and add to array. regardless if tracks are added
            handleSession() {
                (error, token) in
                if let accessToken = token {
                    PlaylistService().handleCreateNewPlaylist(withName: name, accessToken: accessToken, tracks: tracks) {
                        (error, scpPlaylist) in
                        guard error == nil, let playlist = scpPlaylist else {
                            return
                        }
                        //activityIndicator.isAnimating = false
                        self.playlists.append(playlist)
                        self.tableView.reloadData()
                    }
                }
            }
         }
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // pass title for detailViewController as Playlist
    }
    
    enum SegueIdentifier: String {
        case showLogin = "showLogin"
    }
    
}


