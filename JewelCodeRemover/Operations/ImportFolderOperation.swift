//
//  ImportOperation.swift
//  JewelCodeRemover
//
//  Created by Vikram Raj Gopinathan on 09/06/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation
import Cocoa


class ImportFolderOperation: Operation {
    var fileTypes: [String]
    let jewels: Jewels
    
    init(fileTypes: [String], jewels: Jewels) {
        self.fileTypes = fileTypes.map {
            return $0.uppercased()
        }
        self.jewels = jewels
    }
    
    override func main() {
        if self.isCancelled { return }
        
        if let url = NSOpenPanel().selectDirectory {
            jewels.selectedFolderURL = url
            jewels.files = nil
            guard let files = try? FileManager.default.contentsOfDirectory(atPath: url.path) else {
                print("Files not accessible from directory: \(url.path)")
                return
            }
            jewels.files = files.map { (file: String) -> URL in
                return url.appendingPathComponent(file)
            }.filter { (fileURL: URL) -> Bool in
                return fileTypes.contains(fileURL.pathExtension.uppercased())
            }
        } else {
            self.cancel()
        }
    }
}
