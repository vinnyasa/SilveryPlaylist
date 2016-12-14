//
//  SCPListTableViewController.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/1/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import UIKit

class SCPListTableViewController: UITableViewController, SessionHandler, SegueHandler {

    var playlists = [SCPlaylist]()
    var auth: SPTAuth = SPTAuth.defaultInstance()
    var silverCloudAuth = SilverCloudAuth()
    var isInitial = true
    var playlistsToDelete = [SCPlaylist]()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
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
    
    func handleUpdateError(error: Error?) {
        print("scpServiceHandler has error: \(error)")
        guard  let playlistError = error as? SCPListServiceError else {
            print ("error in request, error: \(error)")
            self.unableToUpdatePlaylists()
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
    }
    
    // MARK: - Playlists
    func updatePlaylists(withtoken token: String) {
        if let sptUser = spotifySession?.canonicalUsername {
            let service = SCPListService(username: sptUser)
            // let's try this
            service.updateSCPList(withToken: token) {
                (error, scpPlaylists) in
                //enter main thread
                DispatchQueue.main.async {
                    print("in main delivering update")
                    self.activityIndicator.stopAnimating()
                    guard let playlists = scpPlaylists else {
                        self.handleUpdateError(error: error)
                        /*//handle errors
                        print("scpServiceHandler has error: \(error)")
                        
                        guard  let playlistError = error as? SCPListServiceError else {
                            print ("error in request, error: \(error)")
                            self.unableToUpdatePlaylists()
                            return
                        }
                        switch playlistError {
                        case .missing(let identifier):
                            print("scpServiceHandler has error at: \(identifier)")
                            //could have if identifier == "items", invite them to create playlist feature
                            if identifier == ErrorIdentifier.sptPlaylistListItems.rawValue {
                                self.playlistCreateInvite()
                            }
                        }*/
                        return
                    }
                    
                    self.playlists = playlists
                    print(playlists)
                    self.tableView.reloadData()
                    
                }
            }
        }
    }
    
    func unableToUpdatePlaylists() {
        // right know just presenting this alert for general error, but should be taylored to different error scenarios
        let alertView = UIAlertController(title: "Network Error", message: "Unable to update playlist", preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
        alertView.addAction(ok)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func playlistCreateInvite() {
        // a tour or something to teach them how to add playlists
        print("inviting user to create playlists")
        let alertView = UIAlertController(title: "No Playlists Detected", message: "It appears you haven't created any playlists yet, would you like to create one today, just use the '+' button", preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
        alertView.addAction(ok)
        self.present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - configure view
    func configureTable() {
        tableView.rowHeight = 77
        title = Title.playlist.rawValue
        navigationItem.leftBarButtonItem = self.editButtonItem
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - 60.0)
        //activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
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
        
        return cell
    }
    
    // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let playlist = playlists.remove(at: indexPath.row)
            playlistsToDelete.append(playlist)
            // delete from spotify, the notion of deleting a playlist is not relevant within the Spotify’s playlist system. Even if you are the playlist’s owner and you choose to manually remove it from your own list of playlists, you are simply unfollowing it. 
            if let username = spotifySession?.canonicalUsername, let playlistId = playlist.id {
                let playlistService = PlaylistService()
                print("playliist id: \(playlistId)")
                playlistService.unfollowPlaylist(username: username , playlist: playlistId) {
                    (error, success) in
                    guard success else {
                        //FIXME: unable to unfollow, maybe trigger some alert ?
                        print("you have just deleted this playlist: \(success)")
                        return
                    }
                }
            }
            //delete playlist from dataBase
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    @IBAction func loginSuccessFul(_ segue:UIStoryboardSegue) {
    }
    
    @IBAction func savePlaylist(_ segue:UIStoryboardSegue) {
         let newPlaylistVC = segue.source as? NewPlaylistTableViewController
        activityIndicator.startAnimating()
        print("saving new playlist")
         if let name = newPlaylistVC?.name?.capitalized, let tracks = newPlaylistVC?.tracks, let publicFlag = newPlaylistVC?.playlistStatus?.toBool {
            //createNewPlaylist, then add tracks then create an SCPPlaylist and add to array. regardless if tracks are added
            handleSession() {
                (error, token) in
                if let accessToken = token {
                    print("requesting save")
                    PlaylistService().handleCreateNewPlaylist(withName: name, accessToken: accessToken, tracks: tracks, publicFlag: publicFlag) {
                        (error, scpPlaylist) in
                        //enter main thread
                        DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        guard error == nil, let playlist = scpPlaylist else {
                            return
                        }
                        print("adding playlist: ")
                        self.playlists.append(playlist)
                        self.tableView.reloadData()
                        }
                    }
                }
            }
         }
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let _ = SegueIdentifier(rawValue: identifier) else {
            fatalError("segue identifier not found in \(self)")
        }
        switch segueIdentifierForSegue(segue) {
        case .showPlaylist:
            if let indexPath = tableView.indexPathForSelectedRow, let playlistVC =  segue.destination as? PlaylistTableViewController {
                let playlist = playlists[indexPath.row]
                playlistVC.playlist = playlist
                playlistVC.title = Title.playlist.rawValue
            }
        case .showNewPlaylist:
            (segue.destination as? NewPlaylistTableViewController)?.title = Title.newPlaylist.rawValue
            (segue.destination as? NewPlaylistTableViewController)?.viewMode = NewPlaylistTableViewController.ViewMode.newPlaylist
            
        default:
            break
        }
    }
    
    enum SegueIdentifier: String {
        case showLogin = "showLogin"
        case showPlaylist = "showPlaylist"
        case showNewPlaylist = "showNewPlaylist"
    }
}


