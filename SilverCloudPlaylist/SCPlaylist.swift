/*********************************************************************
 ** Program name: SilverCloudPlaylist - Spotify playlists
 ** Author: Vinny Harris-Riviello
 ** Date: Dec 1, 2016
 ** Description: Playlist struct. Part of the Model, a Playlist
 ** represents a list of tracks.  
 *********************************************************************/


import Foundation

struct SCPlaylist {
    
    let snapshot: SPTPlaylistSnapshot?
    var tracks: [SPTPartialTrack]?
    var largeImage: UIImage?
    var smallImage: UIImage?
    var tracksOnLocal: [SPTPartialTrack]?
    var name: String?
    var isPublic: Bool?
    var uri: URL? {
        return snapshot!.uri
    }
    var id: String? {
        guard let uri = snapshot?.uri else {
            return nil
        }
        let separatedUri = String(describing: uri).characters.split { $0 == ":" }
        let uriArray = separatedUri.map(String.init)
        return uriArray.last
    }
    
    //change to init with SPTPlaylistSnapshot
    init?(sptPlaylistSnapshot: SPTPlaylistSnapshot) {
        
        guard  let _ = sptPlaylistSnapshot.uri, let name = sptPlaylistSnapshot.name else {
            return nil
        }
        self.snapshot = sptPlaylistSnapshot
        self.name = name
        //tracks
        
        if let tracks = snapshot?.firstTrackPage.items as? [SPTPartialTrack] {
            self.tracks = tracks
        } else { tracks = nil }
        if let largeImage = sptPlaylistSnapshot.largestImage {
            self.largeImage = largeImage.toImage
        } else { largeImage = nil }
        
        if let smallImage = sptPlaylistSnapshot.smallestImage {
            self.smallImage = smallImage.toImage
        } else { smallImage = nil }
        if let isPublic = snapshot?.isPublic {
            self.isPublic = isPublic 
        }
    }
}

enum Share: String {
    
    case publicMode = "public"
    case privateMode = "private"
}

extension SPTImage {
    var toImage: UIImage? {
        guard let url = self.imageURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
}

enum PlaylistError: Error {
    case missing(String)
}

enum ErrorIdentifier: String {
    case sptPlaylistList = "sptPlaylistList"
    case sptPlaylistListItems = "sptPlaylistListItems"
    case partialList = "partialPlaylist"
    case sptPartialPlaylists = "sptPartialPlaylists"
    case sptPlaylistSnapshot = "sptPlaylistSnapshot"
    case sptPlaylistArraySnapshot = "sptPlaylistArraySnapshot"
    case newPlaylistSnapshot = "newPlaylistSnapshot"
    case newPlaylistSnapshotWithTracks = "withNewPlaylistSnapshotWithTracks"
    case localPlaylist = "localPlaylist"
    case json = "jsonDictionary"
}
