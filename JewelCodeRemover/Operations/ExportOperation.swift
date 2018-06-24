//
//  ExportOperation.swift
//  JewelCodeRemover
//
//  Created by Vikram Raj Gopinathan on 17/06/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation
import Cocoa

class ExportOperation: Operation {
    enum ExportType {
        case raw
        case edited
    }
    
    let jewel: Jewel
    let type: ExportType
    let currentFolder: URL
    
    init(jewel: Jewel, type: ExportType, currentFolder: URL) {
        self.jewel = jewel
        self.type = type
        self.currentFolder = currentFolder
    }
    
    override func main() {
        if self.isCancelled { return }
        
        let subFoldderName = type == .edited ? "edited" : "raw"
        let destFolder = currentFolder.appendingPathComponent(subFoldderName)
        let dest = destFolder.appendingPathComponent(jewel.fileName)
        
        if type == .raw {
            guard let img = NSImage(contentsOf: jewel.original) else { return }
            try! img.writeJPEG(to: dest)
        } else {
            guard let url = jewel.editedURL,
                let img = NSImage(contentsOf: url) else {
                    print("Not able to get edited image")
                    return
                    
            }
            try! img.writeJPEG(to: dest)
        }
    }    
}
