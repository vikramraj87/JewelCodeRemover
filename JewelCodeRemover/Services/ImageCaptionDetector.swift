//
//  CharacterDataEncoder.swift
//  JewelCodeRemover
//
//  Created by Vikram Raj Gopinathan on 02/06/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation
import Cocoa
import Vision

class ImageCaptionDetector {
    lazy var textDetectionRequest: VNDetectTextRectanglesRequest = {
        let detRequest = VNDetectTextRectanglesRequest(completionHandler: completionHandler)
        detRequest.reportCharacterBoxes = true
        return detRequest
    }()
    
    let url: URL
    let resultsHandler: (URL, String) -> ()
    
    init(url: URL, resultsHandler: @escaping (URL, String) -> ()) {
        self.url = url
        self.resultsHandler = resultsHandler
    }
    
    func completionHandler(request: VNRequest, error: Error?) {
        guard let results = request.results else {
            print("No observations...")
            return
        }
        
        let observations = results.compactMap { $0 as? VNTextObservation }
        
        let encoded = ImageCaptionDetector.encode(observations)
        
        self.resultsHandler(url, encoded)
    }
    
    func detect() {
        guard let img = NSImage(contentsOf: url) else {
            print("Invalid URL. Cannot create NSImage from URL")
            return
        }
        guard let cgImg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Error during NSImage -> CGImage")
            return
        }
        let imgRequestHandler = VNImageRequestHandler(cgImage: cgImg, options: [:])
        do {
            try imgRequestHandler.perform([self.textDetectionRequest])
        } catch {
            print(error)
        }
        
    }
    
    static func encode(_ observations: [VNTextObservation]) -> String {
        return observations.reduce([]) { (accumulator: [VNRectangleObservation], current: VNTextObservation) -> [VNRectangleObservation] in
            let currCharBoxes: [VNRectangleObservation] = current.characterBoxes ?? []
            return accumulator + currCharBoxes
            }.map { (charBox: VNRectangleObservation) -> String in
                let bbox = charBox.boundingBox
                return "\(bbox.origin.x),\(bbox.origin.y),\(bbox.size.width),\(bbox.size.height)"
            }.joined(separator: ";")
    }
}
