/*********************************************************************
 ** Program name: SilverCloudPlaylist - Spotify playlists
 ** Author: Vinny Harris-Riviello
 ** Date: Dec 1, 2016
 ** Description: SCPListTableViewController app has several tables, to
 see the playlists created, see the songs to add to playlists, etc.
 This contoller is for the main list of playlists.
 *********************************************************************/


import UIKit

class SCPListTableViewController: UITableViewController, SessionHandler, SegueHandler, PlaylistDelegate {

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
    
    // MARK: ActivityIndicator
    
    func addIndicator() {
        
        let activityView: UIView = UIView(frame: CGRect(x: 0.0, y: 60.0, width: view.frame.width, height: 32.0))
        let label: UILabel = UILabel(frame: CGRect(x: 16.0, y: 0.0, width: activityView.frame.width - 32.0, height: 28.0))
        label.font = label.font.withSize(12.0)
        label.textAlignment = NSTextAlignment.center
        label.textColor = .white
        label.text = "Fetching Your Spotify Playlists"
        activityView.addSubview(label)
        activityView.backgroundColor = .lightGray
        self.tableView.tableHeaderView = activityView
        
    }
    
    func hideIndicator() {
        tableView.tableHeaderView = nil
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
            guard let token = accessToken else {
                //self.hideIndicator()
                self.unableToUpdatePlaylists(description: error?.localizedDescription)
                return
            }
            self.updatePlaylists(withtoken: token)
        }
    }
    
    func handleUpdateError(error: Error?) {
        //hideIndicator()
        guard  let playlistError = error as? SCPListServiceError else {
            self.unableToUpdatePlaylists(description: nil)
            return
        }
        switch playlistError {
        case .missing(let identifier):
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
            service.updateSCPList(withToken: token) {
                (error, scpPlaylists) in
                
                DispatchQueue.main.async {
                    self.hideIndicator()
                    guard let playlists = scpPlaylists else {
                        self.handleUpdateError(error: error)
                        return
                    }
                    self.playlists = playlists
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func unableToUpdatePlaylists(description: String?) {
        // right now just presenting this alert for general error, but should be taylored to different error scenarios
        var message = "Unable to update and process playlists."
        message += " \((description ?? "please check your connection"))"
        let alertView = UIAlertController(title: "Network Error", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
        alertView.addAction(ok)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func playlistCreateInvite() {
        // a tour or something to teach them how to add playlists
        let alertView = UIAlertController(title: "No Playlists Detected", message: "It appears you haven't created any playlists yet, would you like to create one today, just use the '+' button", preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
        alertView.addAction(ok)
        self.present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - configure view
    func configureTable() {
        tableView.rowHeight = 77
        title = Title.playlists.rawValue
        navigationItem.leftBarButtonItem = self.editButtonItem
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - 60.0)
        view.addSubview(activityIndicator)
        if isInitial {
            addIndicator()
        }
        /*
        if let isHiden = tableView.tableHeaderView?.isHidden, isHiden == true {
            adjustTable()
        }*/
   
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
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
        let playlist = playlists[indexPath.row]
        if let name = playlist.name {
            cell.scpNameLabel?.text = name
        }
        let image = playlist.smallImage ?? UIImage(assetIdentifier: .music)
        if let image = image {
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
    
    @IBAction func savePlaylist(_ segue:UIStoryboardSegue) {
         let newPlaylistVC = segue.source as? NewPlaylistTableViewController
        activityIndicator.startAnimating()
         if let name = newPlaylistVC?.name?.capitalized, let tracks = newPlaylistVC?.tracks {
            handleSession() {
                (error, token) in
                if let accessToken = token {
                    PlaylistService().handleCreateNewPlaylist(withName: name, accessToken: accessToken, tracks: tracks, publicFlag: newPlaylistVC?.isPublic ?? true) {
                        (error, scpPlaylist) in
                        //enter main thread
                        DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        guard error == nil, let playlist = scpPlaylist else {
                            return
                        }
                        let indexPath = IndexPath(row: self.playlists.count, section: 0)
                        self.playlists.append(playlist)
                        self.tableView.insertRows(at: [indexPath], with: .automatic)
                        }
                    }
                }
            }
         }
    }
    
    // MARK: - Playlist
    func addEditedPlaylist(playlist: SCPlaylist) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            playlists[selectedIndexPath.row] = playlist
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
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
                playlistVC.delegate = self
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
        case showAlert = "showAlert"
    }
}


