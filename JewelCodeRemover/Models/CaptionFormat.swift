//
//  CaptionFormat.swift
//  JewelCodeRemover
//
//  Created by Vikram Raj Gopinathan on 14/06/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation

struct CaptionFormat: Codable {
    enum CaptionColor: Int, Codable {
        case light = 0
        case dark
    }
    
    enum HorizontalAlignment: Int, Codable {
        case left = 0
        case right
    }
    
    enum VerticalAlignment: Int, Codable {
        case top = 0
        case bottom
    }
    
    var color: CaptionColor = .light
    var horizontalAlignment: HorizontalAlignment = .left
    var verticalAlignment: VerticalAlignment = .top
}
