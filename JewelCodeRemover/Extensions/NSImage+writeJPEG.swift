//
//  NSImage+writeJPEG.swift
//  JewelCodeRemover
//
//  Created by Vikram Raj Gopinathan on 22/06/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

extension NSImage {
    func writeJPEG(to url: URL) throws {
        guard let imageData = self.tiffRepresentation,
            let imageRep = NSBitmapImageRep(data: imageData),
            let fileData = imageRep.representation(using: .jpeg, properties: [.compressionFactor: 1.0])
            else {
                return
        }
        try fileData.write(to: url)
    }
}
