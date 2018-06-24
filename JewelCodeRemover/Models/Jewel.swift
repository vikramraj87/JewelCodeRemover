//
//  Jewel.swift
//  JewelCodeRemover
//
//  Created by Vikram Raj Gopinathan on 22/06/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import AppKit

class Jewel {
    let original: URL
    var codeRemoved: URL?
    var captionAdded: URL? 
    
    var encodedCaptionData: String?
    
    var isBlackListed = false
    
    var format = CaptionFormat()
    var code: Int?
    
    // Customizations
    private let padding: CGFloat = 20.0
    private let fontSize: CGFloat = 36.0
    
    init(original: URL) {
        self.original = original
    }
}

extension Jewel {
    var fileName: String {
        return original.lastPathComponent
    }
    
    var displayCode: String {
        guard let c  = code else { return "" }
        return "Code \(c)"
    }
    
    var editedURL: URL? {
        return captionAdded ?? codeRemoved
    }
    
    var codeString: String {
        guard let c = code else { return "" }
        return "\(c)"
    }
}
