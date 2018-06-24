//
//  CodeRemovalService.swift
//  JewelCodeRemover
//
//  Created by Vikram Raj Gopinathan on 02/06/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation
import Alamofire

struct CodeRemovalService {
    let url: URL
    
    init(host: String, port: Int) {
        url = URL(string: "http://\(host):\(port)/")!
    }
    
    func removeDetectedTextData(_ results: String, for imageURL: URL, removalCompletion: @escaping (String) -> ()) {
        Alamofire.upload(multipartFormData: { multipartFormData in
            guard let charBoxesData = results.data(using: String.Encoding.utf8) else {
                print("Error encoding character boxes data")
                return
            }
            guard let origFileName = imageURL.lastPathComponent.data(using: String.Encoding.utf8) else {
                print("Not able to encode original file name")
                return
            }
            multipartFormData.append(imageURL, withName: "image")
            multipartFormData.append(charBoxesData, withName: "char_boxes_data")
            multipartFormData.append(origFileName, withName: "original_filename")
        }, to: url,
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    guard let jsonResponse = response.result.value as? [String: Any] else { return }
                    guard let fileName = jsonResponse["filename"] as? String else { return }
                    removalCompletion(fileName)
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    func editedURL(forFileName fileName: String) -> URL {
        return url.appendingPathComponent("edited").appendingPathComponent(fileName)
    }
    
    func rawURL(forFileName fileName: String) -> URL {
        return url.appendingPathComponent("raw").appendingPathComponent(fileName)
    }
}
