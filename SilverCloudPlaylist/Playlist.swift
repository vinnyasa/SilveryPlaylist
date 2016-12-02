//
//  Playlist.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 11/30/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation

struct Playlist {

    //let id: String?
    let name: String?
    //let snapshot_id: String?
    let uri: URL?
    //var tracks: [Track] = []
    //var tracks: (tracksUrl: String, count: Int)
    //var trackUrls = [String]()
    var sptTracks: [SPTTrack] = []
     //var coverArt: [CoverArt] = []
    var images: [UIImage?] = []
    var largeImage: SPTImage?
    var smallImage: SPTImage?
    
    
    init?(spotifyPlaylist: SPTPartialPlaylist)  {
        //in real app handle individually and give proper handling to each case
        /*
        guard let id = spotifyPlaylist["id"] as? String, let name = spotifyPlaylist["name"] as? String, let snapshot_id = spotifyPlaylist["snapshot_id"] as? String, let images = spotifyPlaylist["images"] as? [[String: Any]], let sptTracks = spotifyPlaylist["tracks"] as? [String: Any], let tracksUrl = sptTracks["tracks"] as? String, let total = sptTracks["total"] as? Int, let uri = spotifyPlaylist["uri"] as? String else {
            return nil
        }*/
        
        guard let name = spotifyPlaylist.name, let uri = spotifyPlaylist.uri, let largeImage = spotifyPlaylist.largestImage, let smallImage = spotifyPlaylist.smallestImage else {
            return nil
        }
        self.name = name
        self.uri = uri
        self.largeImage = largeImage
        self.smallImage = smallImage
        
        
        /*
        for image in images {
            if let coverArt = CoverArt(imageDictionary: image), let image = coverArt.image  {
                //self.coverArt.append(coverArt)
                self.images.append(image)
            }
        }
        tracks = (tracksUrl, total)*/
        
    }
    
    func toTracks() {
        
    }
}

extension String {
    func toTracks() {
        guard let url = URL(string: self) else {
            return //nil
        }
        //TracksService
        
        var image: UIImage? {
            guard let url = URL(string: self), let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
                return nil
            }
            return image
        }
    }
}
