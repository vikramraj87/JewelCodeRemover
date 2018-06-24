//
//  KVOperation.swift
//  JewelCodeRemover
//
//  Created by Vikram Raj Gopinathan on 09/06/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Foundation
import Cocoa

class AsyncOperation: Operation {
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    func setExecuting(_ executing: Bool) {
        _executing = executing
    }
    
    func setFinished(_ finished: Bool) {
        _finished = finished
    }
}
