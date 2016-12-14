//
//  PlaylistTableViewController.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/4/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import UIKit

class PlaylistTableViewController: UITableViewController, SegueHandler, SessionHandler, UIPopoverPresentationControllerDelegate {
    
    var playlist: SCPlaylist?
    var tracks = [SPTPartialTrack]()
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var playlistImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel?
    var auth: SPTAuth = SPTAuth.defaultInstance()
    var silverCloudAuth = SilverCloudAuth()
    
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
        if let playlist = playlist, let name = playlist.name, let image = playlist.smallImage, let isPublic = playlist.snapshot?.isPublic  {
            nameLabel?.text = name
            playlistImageView.image = image
            statusLabel?.text = isPublic ? Status.publicPl.rawValue : Status.privatePl.rawValue
            if let tracks = playlist.tracks  {
                self.tracks.append(contentsOf: tracks)
            }
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
        }
    }
    
    //MARK: Error Handling Alerts
    func unableToSaveChanges() {
        //at refactor would create a class for alerts so I wouldn't have to recreate so many of them or a protocol ?
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
        tableView.reloadData()
    }
    
    func changeName(snapshot: SPTPlaylistSnapshot, name: String, accessToken: String){
        snapshot.changePlaylistDetails(["name": "\(name)"], withAccessToken: accessToken) {
            (error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.unableToSaveChanges()
                    return
                }
            }
            self.nameLabel?.text = name
        }
    }
    
    @IBAction func saveChanges(_ segue:UIStoryboardSegue) {
        if let editPlaylistVC = segue.source as? NewPlaylistTableViewController, let name = editPlaylistVC.name, let playlistName = playlist?.name, let snapshot = playlist?.snapshot {
            
            handleSession() {
                (error, token) in
                //name
                guard let accessToken = token else {
                    //invalid token handle
                    return
                }
                print("processing request after token")
                if name != playlistName {
                    //push change to spotify
                    print("have different name")
                    self.changeName(snapshot: snapshot, name: name, accessToken: accessToken)
                }
                snapshot.replaceTracks(inPlaylist: editPlaylistVC.tracks, withAccessToken: accessToken) {
                    (error) in
                    DispatchQueue.main.async {
                        self.handleTracks(tracks: editPlaylistVC.tracks, error: error)
                    }
                }

                /*
                print("tracksEditOperation is: \(editPlaylistVC.tracksEditOperation)")
                if let editOperation = editPlaylistVC.tracksEditOperation {
                    switch editOperation {
                    case .replace:
                        print("replacing")
                        snapshot.replaceTracks(inPlaylist: editPlaylistVC.tracks, withAccessToken: accessToken) {
                            (error) in
                            DispatchQueue.main.async {
                                self.handleTracks(tracks: editPlaylistVC.tracks, editOperation: editOperation, error: error)
                            }
                        }
                    case .add:
                        print("adding")
                        guard !editPlaylistVC.tracksToAdd.isEmpty else {
                            //should've had some tracks to add
                            fatalError("should've had tracks to add")
                        }
                        snapshot.addTracks(toPlaylist: editPlaylistVC.tracksToAdd, withAccessToken: accessToken) {
                            (error) in
                            DispatchQueue.main.async {
                                self.handleTracks(tracks: editPlaylistVC.tracks, editOperation: editOperation, error: error)
                            }
                        }
                    case .remove:
                        print("removing")
                        guard !editPlaylistVC.tracksToDelete.isEmpty else {
                            //should've had some tracks to delete
                            return
                        }
                        snapshot.removeTracks(fromPlaylist: editPlaylistVC.tracksToAdd, withAccessToken: accessToken) {
                            (error) in
                            DispatchQueue.main.async {
                                self.handleTracks(tracks: editPlaylistVC.tracks, editOperation: editOperation, error: error)
                            }
                            
                        }
                    }
                }*/
            }
        }
        
        //maybe show an alert saying, changes will disply once Spotify accepts them in a few moments or changes may take a few moments, waiting for Spotify's confirmation.
        
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
                
            }
        case .showTrack:
        print("segue track")
            if let indexPath = tableView.indexPathForSelectedRow, let trackVC =  segue.destination as? TrackViewController {
                let sptTrack = tracks[indexPath.row]
                guard let track = Track(track: sptTrack) else {
                    fatalError("unable to create track")
                }
                trackVC.track = track
                trackVC.popoverPresentationController?.delegate = self
                let y = self.view.frame.height/2 - 77.0
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
    
    /*
    override func adaptivePresentationStyle(for controller:UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    
    // Mark: - UIPopoverPresentationControllerDelegate
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.any
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier, let _ = SegueIdentifier(rawValue: identifier) else {
            fatalError("segue identifier not found in \(self)")
        }
        switch segueIdentifierForSegue(segue) {
            
        case .showSearchMenuPop:
            if let searchTypeVC =  segue.destination as? SearchTypePopTableViewController, let frame = searchMenuButton?.frame {
                searchTypeVC.popoverPresentationController?.delegate = self
                configurePopOverController(popVC: searchTypeVC, cgSize: CGSize(width: 108, height: 132), sourceRect: frame, sourceView: view, barButtonItem: nil, backgroundColor: .white)
                /*
                 searchTypeVC.modalPresentationStyle = UIModalPresentationStyle.popover
                 searchTypeVC.popoverPresentationController?.delegate = self
                 searchTypeVC.popoverPresentationController?.sourceView = view
                 searchTypeVC.popoverPresentationController?.sourceRect = frame
                 searchTypeVC.preferredContentSize = CGSize(width: 108, height: 132)
                 searchTypeVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
                 searchTypeVC.popoverPresentationController?.backgroundColor = .white
                 */
            }
        default:
            break
        }
    }
*/
    
}

