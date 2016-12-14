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
    case playlists = "Playlists"
    case newPlaylist = "New Playlist"
}

// MARK: extension Segue

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

enum AssetIdentifier: String {
    case menu = "menu"
}

protocol SegueHandler {
    associatedtype SegueIdentifier: RawRepresentable
}

// MARK: extension View

extension UIViewController {
    func setButtonWithIconTintColor(_ button: UIButton?, imageIdentifier: AssetIdentifier, color: UIColor) {
        button?.setImage(UIImage(assetIdentifier: imageIdentifier).withRenderingMode(.alwaysTemplate), for: UIControlState())
        button?.imageView?.tintColor = color
    }
    func configureButtonLayout(_ button: UIButton, radius: CGFloat) {
        button.layer.borderWidth = 0.8
        button.layer.cornerRadius = radius
    }
    
    func configureImageView(_ imageView: UIImageView, radius: CGFloat) {
        imageView.layer.cornerRadius = radius
    }
}


extension UIVisualEffectView {
    func roundCorners(radius: CGFloat) {
        self.layer.borderWidth = 0.8
        self.layer.cornerRadius = self.frame.width / 2

    }
}

extension UITableViewCell {
    func  addTopBorder(view: UIView) {
        let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 1))
        topBorder.backgroundColor = UIColor(colorLiteralRed: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 0.88)
        self.contentView.addSubview(topBorder)
    }
}
extension UIView {
    func addBottomBorder() {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        let color = UIColor(colorLiteralRed: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 0.88).cgColor
        border.borderColor = color
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}



extension UIViewController {
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.any
    }
    
    @objc(adaptivePresentationStyleForPresentationController:) func adaptivePresentationStyle(for controller:UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    /*
     func adaptivePresentationStyle(for controller:UIPresentationController) -> UIModalPresentationStyle {
     return UIModalPresentationStyle.none
     }
     */
    
    func configurePopOverController(popVC: UIViewController, cgSize: CGSize, sourceRect: CGRect?, sourceView: UIView?, barButtonItem: UIBarButtonItem?, backgroundColor: UIColor?) {
        popVC.modalPresentationStyle = UIModalPresentationStyle.popover
        //popVC.popoverPresentationController?.delegate = self
        popVC.preferredContentSize = cgSize
        popVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        if let sourceRect = sourceRect {
            popVC.popoverPresentationController?.sourceRect = sourceRect
        }
        if let sourceView = sourceView {
            popVC.popoverPresentationController?.sourceView = sourceView
        }
        
        if let barButtonItem = barButtonItem {
            popVC.popoverPresentationController?.barButtonItem = barButtonItem
        }
        if let backgroundColor = backgroundColor {
            popVC.popoverPresentationController?.backgroundColor = backgroundColor
        }
    }
}


// MARK: extension Image

extension UIImage {
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
}

extension UIImageView {
    func rounded() {
        //self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
    }
}


