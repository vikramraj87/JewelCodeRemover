//
//  RemoveCodeOperation.swift
//  JewelCodeRemover
//
//  Created by Vikram Raj Gopinathan on 09/06/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation
import Cocoa

class RemoveCodeOperation: AsyncOperation {
    let service: CodeRemovalService
    let jewel: Jewel
    
    init(jewel: Jewel, service: CodeRemovalService) {
        self.jewel = jewel
        self.service = service
    }
    
    override func main() {
        guard !isCancelled else {
            setFinished(true)
            return
        }
        
        guard let captionData = jewel.encodedCaptionData else {
            print("Caption data is nil")
            setFinished(true)
            return
        }
        
        guard !captionData.isEmpty else {
            self.jewel.codeRemoved = self.jewel.original
            setFinished(true)
            return
        }
        
        setExecuting(true)
        service.removeDetectedTextData(captionData, for: jewel.original, removalCompletion: {
            fileName in
            let editedURL = self.service.editedURL(forFileName: fileName)
            self.jewel.codeRemoved = editedURL
            self.setExecuting(false)
            self.setFinished(true)
        })
    }
    
}
