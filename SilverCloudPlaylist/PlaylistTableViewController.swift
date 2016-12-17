//
//  PlaylistTableViewController.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/4/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import UIKit

class PlaylistTableViewController: UITableViewController, SegueHandler, SessionHandler, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var playlistImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel?
    var auth: SPTAuth = SPTAuth.defaultInstance()
    var silverCloudAuth = SilverCloudAuth()
    var delegate: PlaylistDelegate?
    var playlist: SCPlaylist?
    var tracks = [SPTPartialTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurePlaylistView()
        loadPlaylist()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - View
    func configurePlaylistView() {
        tableView.rowHeight = 77
        playlistImageView.rounded()
    }
    
    func loadPlaylist() {
        if let name = playlist?.name {
            nameLabel?.text = name
        }
        if let isPublic = playlist?.isPublic {
            statusLabel?.text = isPublic ? Share.publicMode.rawValue : Share.privateMode.rawValue
        }
        let image = playlist?.smallImage ?? UIImage(assetIdentifier: .music)
        /*
        if let image = image {
            playlistImageView.image = image
        }*/
        playlistImageView.image = image

        
        if let tracks = playlist?.tracks  {
            self.tracks.append(contentsOf: tracks)
        }
    }
    
    func cancelPressed() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tracks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        // Configure the cell...
        let track = tracks[indexPath.row]
        if let name = track.name, let album = track.album.name {
            cell.textLabel?.text = name
            cell.detailTextLabel?.text = album
        }
        if indexPath.row == 0 {
            cell.addTopBorder(view: self.view)
        }
        return cell
    }
    
    
    //MARK: Error Handling Alerts
    func unableToSaveChanges() {
        //at refactor create a class for alert
        let alertView = UIAlertController(title: "Network Error", message: "Unable to save changes to Spotify", preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
        alertView.addAction(ok)
        self.present(alertView, animated: true, completion: nil)
    }
    
    
    //MARK: Edit Methods

    func handleTracks(tracks: [SPTPartialTrack], error: Error?) {
        print("have changes")
        guard error == nil else {
            unableToSaveChanges()
            return
        }
        print("loading tracks")
        self.tracks = tracks
        playlist?.tracks = tracks
        tableView.reloadData()
    }
    
    func changedetails(snapshot: SPTPlaylistSnapshot, details: [AnyHashable: Any], accessToken: String) {
        snapshot.changePlaylistDetails(details, withAccessToken: accessToken) {
            (error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.unableToSaveChanges()
                    return
                }
                if let name = details[SPTPlaylistSnapshotNameKey] as? String {
                    print("returned from changing name")
                    self.nameLabel?.text = name
                    self.playlist?.name = self.nameLabel?.text
                }
                if let isPublic = details[SPTPlaylistSnapshotPublicKey] as? Bool {
                    print("returned from changing isPublic to: \(isPublic)")
                    self.statusLabel?.text = self.shareMode(isPublic: isPublic)
                    self.playlist?.isPublic = isPublic
                }
                
            }
            
        }
    }

    
    @IBAction func saveChanges(_ segue:UIStoryboardSegue) {
        if let editPlaylistVC = segue.source as? NewPlaylistTableViewController, let name = editPlaylistVC.name, let playlistName = playlist?.name, let snapshot = playlist?.snapshot, let editedIsPublic = editPlaylistVC.isPublic, let isPublic = playlist?.isPublic {
            
            handleSession() {
                (error, token) in
                //name
                guard let accessToken = token else {
                    //invalid token handle
                    return
                }
                var details: [AnyHashable: Any] = [:]
                
                print("edited name: \(name)")
                print("playlist name is: \(playlistName)")
                if name != playlistName {
                    //push change to spotify
                    print("have different name")
                    //self.changeName(snapshot: snapshot, name: name, accessToken: accessToken)
                    details[SPTPlaylistSnapshotNameKey] = name
                }
                if editedIsPublic != isPublic {
                    print("edited is public: \(editedIsPublic)")
                    details[SPTPlaylistSnapshotPublicKey] = editedIsPublic
                }
                if !details.isEmpty {
                    print("changing details")
                    self.changedetails(snapshot: snapshot, details: details, accessToken: accessToken)
                }
                print("checking editOperation")
                if editPlaylistVC.tracksEditOperation != nil {
                    snapshot.replaceTracks(inPlaylist: editPlaylistVC.tracks, withAccessToken: accessToken) {
                        (error) in
                        DispatchQueue.main.async {
                            self.handleTracks(tracks: editPlaylistVC.tracks, error: error)
                        }
                    }
                }
                
            }
        }
        
        //maybe show an alert saying, changes will disply once Spotify accepts them in a few moments or changes may take a few moments, waiting for Spotify's confirmation.
        
    }
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil, let editedPlaylist = playlist {
            delegate?.addEditedPlaylist(playlist: editedPlaylist)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let identifier = segue.identifier, let _ = SegueIdentifier(rawValue: identifier) else {
            fatalError("segue identifier not found in \(self)")
        }
        switch segueIdentifierForSegue(segue) {
        
        case .showEditPlaylist:
            if let editPlaylistVC = segue.destination as? NewPlaylistTableViewController, let name = playlist?.name {
                editPlaylistVC.viewMode = NewPlaylistTableViewController.ViewMode.editPlaylist
                editPlaylistVC.saveButton?.isHidden = true
                editPlaylistVC.name = name
                editPlaylistVC.playlistNameTextField?.text = name
                editPlaylistVC.tracks = tracks
                editPlaylistVC.isPublic = playlist?.isPublic ?? true
                
                
            }
        case .showTrack:
            if let indexPath = tableView.indexPathForSelectedRow, let trackVC =  segue.destination as? TrackViewController {
                let sptTrack = tracks[indexPath.row]
                guard let track = Track(track: sptTrack) else {
                    fatalError("unable to create track")
                }
                trackVC.track = track
                trackVC.popoverPresentationController?.delegate = self
                //let y = self.view.frame.height/2 - 77.0
                let popHeight:CGFloat = 144.0
                let y = self.view.frame.height - popHeight
                let rect = CGRect(x: 0, y: y, width: 1.0, height: 1.0)
                let cgSize = CGSize(width: self.view.frame.width, height: 144.0)
                configurePopOverController(popVC: trackVC, cgSize: cgSize, sourceRect: rect, sourceView: view, barButtonItem: nil, backgroundColor: nil)
            }
        }
    }
    
    enum SegueIdentifier: String {
        case showEditPlaylist = "showEditPlaylist"
        case showTrack = "showTrack"
    }
    
    
}


