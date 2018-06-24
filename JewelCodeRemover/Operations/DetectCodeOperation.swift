//
//  DetectCodeOperation.swift
//  JewelCodeRemover
//
//  Created by Vikram Raj Gopinathan on 09/06/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation
import Cocoa

class DetectCodeOperation: AsyncOperation {
    let jewel: Jewel
    
    init(jewel: Jewel) {
        self.jewel = jewel
    }
    
    override func main() {
        guard !isCancelled else {
            setFinished(true)
            return
        }
        
        setExecuting(true)
        let captionDetector = ImageCaptionDetector(url: jewel.original, resultsHandler: {
            (_, results: String) in
            self.jewel.encodedCaptionData = results
            self.setExecuting(false)
            self.setFinished(true)
        })
        captionDetector.detect()
    }
}
