//
//  NSOpenPanel+selectDirectory.swift
//  JewelCodeRemover
//
//  Created by Vikram Raj Gopinathan on 05/06/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation
import Cocoa

extension NSOpenPanel {
    var selectDirectory: URL? {
        title = "Select folder containing images"
        allowsMultipleSelection = false
        canChooseFiles = false
        canChooseDirectories = true
        return runModal() == .OK ? urls.first : nil
    }
}
