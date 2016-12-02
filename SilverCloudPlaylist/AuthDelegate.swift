//
//  AuthDelegate.swift
//  SilverCloudPlaylist
//
//  Created by Ayah Effi-yah on 11/30/16.
//  Copyright © 2016 TrhUArrayLUV. All rights reserved.
//

import Foundation

protocol AuthDelegate {
    var auth: SPTAuth { get set }
    var silverCloudAuth: SilverCloudAuth { get }
}
