//
//  NewPlaylistTableViewController.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/2/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import UIKit

class NewPlaylistTableViewController: UITableViewController, UITextFieldDelegate {
 
    @IBOutlet weak var saveButton: UIButton?
    @IBOutlet weak var addMusicButton: UIButton?
    @IBOutlet weak var playlistNameTextField: UITextField?
    var name: String?
    var tracks = [SPTPartialTrack]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        addMusicButton?.titleLabel?.textAlignment = .left
        playlistNameTextField?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Text field
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //could add a minimum of characters for name? does Spotify have minimum
        guard let name = playlistNameTextField?.text, name.characters.count > 1 else {
            return false
        }
        print("enabling save button, \(saveButton?.isEnabled)")
        saveButton?.isEnabled = true
        print("enabling save button, \(saveButton?.isEnabled)")
        self.name = name.capitalized
        return true
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "newPlaylistCell", for: indexPath)
        if let name = tracks[indexPath.row].name, let album = tracks[indexPath.row].album.name {
            cell.textLabel?.text = name
            cell.detailTextLabel?.text = album
        }
        return cell
    }
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tracks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            print("tracks after deleting some tracks: \(tracks)")
        }
    }
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let trackToMove = tracks.remove(at: fromIndexPath.row)
        tracks.insert(trackToMove, at: to.row)
        print("tracks after moving: \(tracks)")
     }
   
    // MARK: - Tracks
    @IBAction func addTracks(_ segue:UIStoryboardSegue) {
         if let searchVC = segue.source as? SearchViewController {
            tracks += searchVC.tracksToAdd
            tableView.reloadData()
            tableView.isEditing = true
         }
    }

    // MARK: - Navigation
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
