//
//  CoverArt.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 11/25/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation
import UIKit

struct CoverArt {
    
    //currently getting 60, 300, 640
    let smallImage: UIImage?
    let mediumImage: UIImage?
    let largeImage: UIImage?
    
    init(smallImageSource: String?, mediumImageSource: String?, largeImageSource: String?) {
        if let smallImageSource = smallImageSource {
            smallImage = smallImageSource.toImage()
        } else { smallImage = nil }
        if let mediumImageSource = mediumImageSource {
            mediumImage = mediumImageSource.toImage()
        } else { mediumImage = nil }
        if let largeImageSource = largeImageSource {
            largeImage = largeImageSource.toImage()
        } else { largeImage = nil }
    }
}

extension String {
    func toImage() -> UIImage? {
        guard let url = URL(string: self), let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
}

