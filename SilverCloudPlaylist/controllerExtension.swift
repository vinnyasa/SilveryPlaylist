//
//  controllerExtension.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 12/4/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation



enum Title: String {
    case album = "Album"
    case playlist = "Playlist"
    case Playlists = "Playlists"
}


extension SegueHandler where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    func performSegueWithIdentifier(_ segueIdentifier: SegueIdentifier, sender: Any?) {
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
    }
    func segueIdentifierForSegue(_ segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            fatalError()
        }
        return segueIdentifier
    }
}

protocol SegueHandler {
    associatedtype SegueIdentifier: RawRepresentable
}

extension UIViewController {
    func setButtonWithIconTintColor(_ button: UIButton?, imageIdentifier: AssetIdentifier, color: UIColor) {
        button?.setImage(UIImage(assetIdentifier: imageIdentifier).withRenderingMode(.alwaysTemplate), for: UIControlState())
        button?.imageView?.tintColor = color
    }
}

enum AssetIdentifier: String {
    case menu = "menu"
}

extension UIImage {
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
}

extension UIViewController {
    func configureButtonLayout(_ button: UIButton, radius: CGFloat) {
        button.layer.borderWidth = 0.8
        button.layer.cornerRadius = radius
    }
    
    func configureImageView(_ imageView: UIImageView, radius: CGFloat) {
        imageView.layer.cornerRadius = radius
    }
}

extension UIImageView {
    func rounded() {
        self.layer.cornerRadius = 24.0
    }
}
