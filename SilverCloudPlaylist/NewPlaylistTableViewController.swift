//
//  NewPlaylistTableViewController.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/2/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import UIKit

class NewPlaylistTableViewController: UITableViewController, UITextFieldDelegate, SegueHandler, UIPopoverPresentationControllerDelegate {
 
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var navigationView: UIView?
    @IBOutlet weak var saveButton: UIButton?
    @IBOutlet weak var addMusicButton: UIButton?
    @IBOutlet weak var playlistNameTextField: UITextField?
    
    @IBOutlet weak var privacyMenuButton: UIButton!
    @IBOutlet weak var playlistTypeLabel: UILabel!
    var name: String?
    var tracks: [SPTPartialTrack] = []
    var isPublic: Bool?
    //var share: Share?
    var viewMode: ViewMode?
    
    //ToProcessOnExistingPlaylist
    var tracksToDelete: [SPTPartialTrack] = []
    var tracksToAdd: [SPTPartialTrack] = []
    var tracksEditOperation: EditOperation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Configure View
    func configureView() {
        addMusicButton?.titleLabel?.textAlignment = .left
        playlistNameTextField?.delegate = self
        navigationView?.addBottomBorder()
        setupDoneButtons()
        setupTextField()
        tableView.isEditing = true
    }
    /*
    func setupBorder(forView view: UIView?) {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        let color = UIColor(colorLiteralRed: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 0.88).cgColor
        border.borderColor = color
        if let width = navigationView?.frame.size.width, let height = navigationView?.frame.size.height {
            border.frame = CGRect(x: 0, y: height - borderWidth, width:  width, height: height)
            
            border.borderWidth = borderWidth
            view?.layer.addSublayer(border)
            view?.layer.masksToBounds = true
        }
    }*/
    
    // MARK: - Text field
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing called")
        if let textCount = textField.text?.characters.count, textCount > 1, let name = playlistNameTextField?.text {
            print("have name for new pl: \(name)")
            self.name = name.capitalized
            buttonsEnabled(allow: true)
        } else if let textCount = textField.text?.characters.count, textCount <= 1 {
            buttonsEnabled(allow: false)
            print("sorry you need a longer name")
            //show alert
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        playlistNameTextField?.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        buttonsEnabled(allow: false)
    }
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        playlistNameTextField?.resignFirstResponder()
    }
    
    // MARK: - Manage View for PresentingController
    
    
    func setupDoneButtons() {
        guard let viewMode = viewMode else { // unableTosetUp
            print("unable to read viewMode")
            return
        }
        switch viewMode {
        case .editPlaylist:
            saveButton?.isHidden = true
        case .newPlaylist:
            doneButton.isHidden = true
        }
    }
    
    func setupTextField() {
        guard let viewMode = viewMode, let name = name, let isPublic = isPublic else{ // unableTosetUp
            return
        }
        switch viewMode {
        case .editPlaylist:
            playlistNameTextField?.text = name
            playlistTypeLabel?.text = shareMode(isPublic: isPublic)
            playlistTypeLabel.isHidden = false
        default:
            break
        }
    }
    
    func buttonsEnabled(allow: Bool) {
        guard let viewMode = viewMode else {
            // need mode to setUP
            return
        }
        switch viewMode {
        case .editPlaylist:
            doneButton.isEnabled = allow
        case .newPlaylist:
            saveButton?.isEnabled = allow
        }
    }
    
    func handleChanges(editOperation: EditOperation) {
        print("editOperation before processing: \(tracksEditOperation)")
        if  tracksEditOperation == nil {
            tracksEditOperation = editOperation
            print("tracksEditOperation set to: \(tracksEditOperation)")
        } else if let edit = tracksEditOperation, edit == editOperation { } else {
            tracksEditOperation = .replace
            print("tracks editOperation should be replace: \(tracksEditOperation)")
        }
        // right now moving operation is handle as a replace, but with a large playlist, this could be costly so would have to keep track of indexed and tracks to move, even if I have to make 2 network calls.
        /*
        guard self.editOperation == nil else {
            self.editOperation = .replace
            return
        }
        self.editOperation = editOperation*/
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
        if indexPath.row == 0 {
            cell.addTopBorder(view: self.view)
        }
        return cell
    }
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let viewMode = viewMode else {
                fatalError("no viewMode at deleting track")
            }
            switch viewMode {
            case .editPlaylist:
                tracksToDelete.append(tracks[indexPath.row])
            default:
                break
            }
            tracks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            handleChanges(editOperation: .remove)
        }
    }
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let trackToMove = tracks.remove(at: fromIndexPath.row)
        tracks.insert(trackToMove, at: to.row)
        handleChanges(editOperation: .replace)
     }
   
    // MARK: - Tracks
    @IBAction func addTracks(_ segue:UIStoryboardSegue) {
         if let searchVC = segue.source as? SearchViewController {
            tracks += searchVC.tracksToAdd
            tableView.reloadData()
            tableView.isEditing = true
         }
        handleChanges(editOperation: .add)
    }
    

    // MARK: - Navigation
    @IBAction func playlistStatusSelected(_ segue:UIStoryboardSegue) {
        print("unwind segue method being called")
        let playlistPopVC = segue.source as? PlaylistTypePopTableViewController
        /*if let share = playlistPopVC?.share {
            print("share in unwind is: \(share)")
            self.share = share
            playlistTypeLabel.text = share.rawValue
            playlistTypeLabel.isHidden = false
        }*/
        if let isPublic = playlistPopVC?.isPublic {
            print("share in unwind is: \(isPublic)")
            self.isPublic = isPublic
            //let shareMode = isPublic ? "public" : "private"
            playlistTypeLabel.text = shareMode(isPublic: isPublic)
            playlistTypeLabel.isHidden = false
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let _ = SegueIdentifier(rawValue: identifier) else {
            fatalError("segue identifier not found in \(self)")
        }
        switch segueIdentifierForSegue(segue) {
        case .showPlaylistTypePop:
            if let playlistTypeVC =  segue.destination as? PlaylistTypePopTableViewController, let frame = privacyMenuButton?.frame {
                print("presenting pop")
                playlistTypeVC.popoverPresentationController?.delegate = self
                configurePopOverController(popVC: playlistTypeVC, cgSize: CGSize(width: 108, height: 88), sourceRect: frame, sourceView: view, barButtonItem: nil, backgroundColor: .white)
            }
        case .saveNewPlaylist:
            print("name before exit: \(name)")
        default:
            break
        }
    }
    
    /*
    override func adaptivePresentationStyle(for controller:UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }*/
    // MARK: Status bar
    /*
    override var prefersStatusBarHidden: Bool {
        return true
    }*/
    enum SegueIdentifier: String {
        case saveChangesToPlaylist = "saveChangesToPlaylist"
        case saveNewPlaylist = "saveNewPlaylist"
        case showSearchView = "showSearchView"
        case showPlaylistTypePop = "showPlaylistTypePop"
    }
    
    enum ViewMode {
        case editPlaylist
        case newPlaylist
    }
    enum EditOperation {
        case add
        case remove
        case replace
    }
}
