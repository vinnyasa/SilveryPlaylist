/*********************************************************************
 ** Program name: SilverCloudPlaylist - Spotify playlists
 ** Author: Vinny Harris-Riviello
 ** Date: Dec 4, 2016
 ** Description: SearchViewController.swift - View controller to
 ** handle the serach of a track.
 *********************************************************************/


import UIKit

class SearchViewController: UIViewController, UIPopoverPresentationControllerDelegate, SegueHandler, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navigationView: UIView!
    //var tableView: UITableView?
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var searchResult: SearchResult?
    var tracksToAdd: [SPTPartialTrack] = []
    
    var searchType: SPTSearchQueryType = .queryTypeTrack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        setupSearchBar()
        navigationView.addBottomBorder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupDelegates() {
        tableView?.delegate = self
        tableView?.dataSource = self
        searchBar?.delegate = self
        tableView?.isHidden = true
    }
    
    // MARK: SearchBarMethods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.addSubview(activityIndicator)
        activityIndicator.frame = searchBar.bounds
        activityIndicator.startAnimating()
        tableView?.isHidden = false
        if let searchTerm = searchBar.text{
            searchSpotify(with: searchTerm, queryType: searchType)
        }
        searchBar.text = nil
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        //tableView?.reloadData()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: false)
    }
    
    func setupSearchBar(){
        guard searchBar != nil else {
            return
        }
        //searchBar.isHidden = false
        searchBar?.tintColor = SilverCloudColor.aquaGreen.toColor
        searchBar?.placeholder = "search music"
        self.definesPresentationContext = true
        
        if #available(iOS 8, *) {
            self.searchBar.searchBarStyle = .prominent
        } else {
            
            searchBar?.searchBarStyle = .minimal
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let search = searchResult else {
            return 0
        }
        return search.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        guard let name = searchResult?.name(atIndex: indexPath.row) else {
            return cell
        }
        
        cell.textLabel?.text = name
        addAccessory(cell, cellAccessory: .add)
        return cell
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //change accesoryView
        if let cell  = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .none {
                cell.accessoryView = nil
                cell.accessoryType = .checkmark
                if let track = searchResult?.tracks[indexPath.row] {
                    tracksToAdd.append(track)
                }
            } else {
                cell.accessoryType = .none
                addAccessory(cell, cellAccessory: .add)
                if let track = searchResult?.tracks[indexPath.row] {
                    tracksToAdd = tracksToAdd.filter() { $0 != track }
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    enum CellAccesory: String {
        case selected = "✓"
        case add = "+"
    }
    
    func addAccessory(_ cell: UITableViewCell, cellAccessory: CellAccesory) {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 26.0, height: 44.0))
        label.text = cellAccessory.rawValue
        label.textColor = SilverCloudColor.aquaGreen.toColor
        label.textAlignment = .center
        cell.accessoryView = label as UIView
    }
    
    func tableView(_ tableV: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            addAccessory(cell, cellAccessory: .add)
        }
        //delete from tracks to add
        if let track = searchResult?.tracks[indexPath.row] {
            tracksToAdd = tracksToAdd.filter() { $0 != track }
        }
    }
    
    // MARK: - Search 
    
    func searchSpotify(with query: String, queryType: SPTSearchQueryType) {
        let searchService = SearchService()
        searchService.searchSpotify(with: query, searchType: queryType) {
            (error, searchResults) in
            DispatchQueue.main.async {
                guard error == nil, let searchResult = searchResults else {
                    print("invalidSearch, error: \(error)")
                    // handle error
                    return
                }
                self.searchResult = searchResult
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Navigation

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)

    }
    
    enum SegueIdentifier: String {
        case showSearchMenuPop = "showSearchMenuPop"
        case addTracks = "addTracks"
    }
}
