//
//  PlaylistTypePopTableViewController.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/13/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import UIKit

class PlaylistTypePopTableViewController: UITableViewController {
    
    let playlistStatus: [Status] = [.publicPl, .privatePl]
    var status: Status?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = UIEdgeInsets.zero
        }
        // Prevent the cell from inheriting the Table View's margin settings "setPreservesSuperviewLayoutMargins:"
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        // Explictly set your cell's layout margins "setLayoutMargins:"
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        status = playlistStatus[(indexPath as NSIndexPath).row]
        print(status?.rawValue ?? "no search type")
        performSegue(withIdentifier: SegueIdentifier.searchTypeSelected.rawValue, sender: nil)
        //self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return playlistStatus.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchTypeCell", for: indexPath)
        
        // Configure the cell...
        let playlistType = playlistStatus[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = playlistType.rawValue
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let identifier = segue.identifier, let _ = SegueIdentifier(rawValue: identifier) else {
            fatalError("segue identifier not found in \(self)")
        }
        
    }
    enum SegueIdentifier: String {
        case searchTypeSelected = "searchTypeSelected"
    }

}