//
//  JewelTableCellView.swift
//  JewelCodeRemover
//
//  Created by Vikram Raj Gopinathan on 02/06/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

protocol JewelTableCellViewDelegate: class {
    func actualCodeChanged(to newValue: Int, in cell: JewelTableCellView)
    func computedCodeChanged(to newValue: Int, in cell: JewelTableCellView)
    func changeBlackListStatus(_ blacklisted: Bool, in cell: JewelTableCellView)
}

class JewelTableCellView: NSTableCellView {
    @IBOutlet var rawImageView: NSImageView!
    @IBOutlet var editedImageView: NSImageView! {
        didSet {
            if editedImageView != nil {
                enableInputs()
            } else {
                disableInputs()
            }
        }
    }
    @IBOutlet var actualCodeTextField: NSTextField!
    @IBOutlet var computedCodeTextField: NSTextField!
    @IBOutlet var blackListCheckBox: NSButton!
    
    weak var delegate: JewelTableCellViewDelegate?
    
    @IBAction func actualCodeChanged(_ sender: NSTextField) {
        delegate?.actualCodeChanged(to: sender.integerValue, in: self)
    }
    
    @IBAction func computedCodeChaged(_ sender: NSTextField) {
        delegate?.computedCodeChanged(to: sender.integerValue, in: self)
    }
    
    @IBAction func blackListJewel(_ sender: NSButton) {
        let blackListed = sender.state == .on ? true : false
        delegate?.changeBlackListStatus(blackListed, in: self)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func prepareForReuse() {
        self.rawImageView.image = nil
        self.editedImageView.image = nil
        self.delegate = nil
        
        self.blackListCheckBox.state = .off
        self.actualCodeTextField.stringValue = ""
        self.computedCodeTextField.stringValue = ""
    }
    
    private func enableInputs() {
        self.blackListCheckBox.isEnabled = true
        self.actualCodeTextField.isEnabled = true
        self.computedCodeTextField.isEnabled = true
    }
    
    private func disableInputs() {
        self.blackListCheckBox.isEnabled = false
        self.actualCodeTextField.isEnabled = false
        self.computedCodeTextField.isEnabled = false
    }
}
    

