
//  ViewController.swift
//  JewelCodeRemover
//
//  Created by Vikram Raj Gopinathan on 28/05/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa
import Vision
import Alamofire

// TODO:
// 1. Create menu actions
// 2. Ability to save in between
// 3. Track changes. Confirm import before exporting if there are changes


struct CodeGenParams {
    var multiplier: Float = 1.0
    var profit: Float = 0.0
}

enum ExportType {
    case raw
    case edited
}

class ViewController: NSViewController {
    @IBOutlet var tableView: NSTableView!
    
    var jewels: Jewels = Jewels()
    let codeRemovalService = CodeRemovalService(host: "127.0.0.1", port: 5000)
    
    var currentCaptionFormat: CaptionFormat = CaptionFormat()
    var currentCodeParams: CodeGenParams = CodeGenParams()
    
    let changeCodeQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func exportImages(_ sender: Any) {
        guard let currentFolder = jewels.selectedFolderURL else { return }
        guard jewels.jewels.count > 0 else { return }
        
        let editedFolder = currentFolder.appendingPathComponent("edited")
        let rawFolder = currentFolder.appendingPathComponent("raw")
        let fm = FileManager.default
        
        do {
            try fm.createDirectory(at: editedFolder, withIntermediateDirectories: false, attributes: nil)
            try fm.createDirectory(at: rawFolder, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error)
        }
        
        let exportOperations: [ExportOperation] = jewels.jewels.map {
            (jewel: Jewel) in
            let type: ExportOperation.ExportType = jewel.isBlackListed ? .raw : .edited
            return ExportOperation(jewel: jewel, type: type, currentFolder: currentFolder)
        }
        
        let opQueue = OperationQueue()
        opQueue.qualityOfService = .userInitiated
        opQueue.addOperations(exportOperations, waitUntilFinished: false)
    }
    
    @IBAction func importImages(_ sender: Any) {
        let importOperation = ImportFolderOperation(fileTypes: ["jpg", "jpeg"], jewels: jewels)
        let resetOperation = BlockOperation {
            guard !importOperation.isCancelled else {
                print("Import Cancelled")
                return
            }
            
            guard let files = self.jewels.files else {
                print("Something wrong. Import not cancelled. Yet files are empty")
                return
            }

            self.jewels.jewels = files.compactMap { (file: URL) in
                return Jewel(original: file)
            }

            self.tableView.reloadData()
        }
        
        let detectRemoveOperations = BlockOperation {
            guard !importOperation.isCancelled else {
                print("Import Cancelled. Nothing to detect")
                return
            }
            let operationQueue = OperationQueue()
            operationQueue.qualityOfService = .userInitiated
            
            for (row, jewel) in self.jewels.jewels.enumerated() {
                let detectOp = DetectCodeOperation(jewel: jewel)
                let removeOp = RemoveCodeOperation(jewel: jewel, service: self.codeRemovalService)
                removeOp.completionBlock = {
                    DispatchQueue.main.async {
                        self.tableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(integer: 0))
                    }
                }
                removeOp.addDependency(detectOp)
                operationQueue.addOperations([detectOp, removeOp], waitUntilFinished: false)
            }
            
        }
        
        resetOperation.addDependency(importOperation)
        detectRemoveOperations.addDependency(resetOperation)
        OperationQueue.main.addOperations([importOperation, resetOperation, detectRemoveOperations], waitUntilFinished: false)
    }
    
}

// Toolbar actions
extension ViewController {
    @IBAction func changeCaptionColor(_ sender: NSSegmentedControl) {
        currentCaptionFormat.color = CaptionFormat.CaptionColor(rawValue: sender.indexOfSelectedItem)!
    }
    
    @IBAction func changeHorizontalAlignment(_ sender: NSSegmentedControl) {
        currentCaptionFormat.horizontalAlignment = CaptionFormat.HorizontalAlignment(rawValue: sender.indexOfSelectedItem)!
    }
    
    @IBAction func changeVerticalAlignment(_ sender: NSSegmentedControl) {
        currentCaptionFormat.verticalAlignment = CaptionFormat.VerticalAlignment(rawValue: sender.indexOfSelectedItem)!
    }
    
    @IBAction func changeMultiplier(_ sender: NSTextField) {
        currentCodeParams.multiplier = sender.floatValue
    }
    
    @IBAction func changeProfit(_ sender: NSTextField) {
        currentCodeParams.profit = sender.floatValue
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return jewels.jewels.count
    }
}

extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self)
        guard let cellView = vw as? JewelTableCellView else {
            print("Not able to make table cell view")
            return nil
        }
        let jewel = jewels.jewels[row]
        if let edited = jewel.editedURL {
            cellView.editedImageView.image = NSImage(contentsOf: edited)
        }
        
        cellView.rawImageView.image = NSImage(contentsOf: jewel.original)
        cellView.delegate = self
        cellView.computedCodeTextField.stringValue = jewel.codeString
        cellView.blackListCheckBox.state = jewel.isBlackListed ? .on : .off
        return cellView
    }
}

extension ViewController: JewelTableCellViewDelegate {
    func changeBlackListStatus(_ blacklisted: Bool, in cell: JewelTableCellView) {
        // Fetch selected jewel
        let row = tableView.row(for: cell)
        
        guard jewels.jewels.count != 0 else {
            print("Table view must be reloading")
            return
        }
        
        let jewel = jewels.jewels[row]
        jewel.isBlackListed = blacklisted
    }
    
    func actualCodeChanged(to newValue: Int, in cell: JewelTableCellView) {
        guard newValue != 0 else { return }
        // Fetch selected jewel
        let row = tableView.row(for: cell)
        
        guard jewels.jewels.count != 0 else {
            print("Table view must be reloading")
            return
        }
        
        let jewel = jewels.jewels[row]
        
        let code = computeCode(forDealerCode: newValue, params: currentCodeParams)
        
        changeCode(Int(code), for: jewel, in: cell)
        moveToNextRow(currentRow: row)
    }
    
    func computedCodeChanged(to newValue: Int, in cell: JewelTableCellView) {
        guard newValue != 0 else { return }
        // Fetch selected jewel
        let row = tableView.row(for: cell)
        
        guard jewels.jewels.count != 0 else {
            print("Table view must be reloading")
            return
        }
        
        let jewel = jewels.jewels[row]
        
        // Configure jewel based on user settings
        changeCode(Int(newValue), for: jewel, in: cell)
        moveToNextRow(currentRow: row, selectActual: false)
    }
    
    private func computeCode(forDealerCode dealerCode: Int, params: CodeGenParams) -> Int {
        let computedCost = Float(dealerCode) * params.multiplier + params.profit
        let displayCost = ceil(computedCost/10) * 10
        return Int(displayCost/2.0)
    }
    
    
    private func changeCode(_ code: Int, for jewel: Jewel, in cell: JewelTableCellView) {
        jewel.format = currentCaptionFormat
        jewel.code = code
        
        let updateCellOp = BlockOperation {
            guard let url = jewel.editedURL else { return }
            cell.editedImageView.image = NSImage(contentsOf: url)
        }
        
        let addCaptionOp = AddCaptionOperation(jewel: jewel)
        updateCellOp.addDependency(addCaptionOp)
    
        OperationQueue.main.addOperation(updateCellOp)
        changeCodeQueue.addOperation(addCaptionOp)
    }
    
    private func moveToNextRow(currentRow: Int, selectActual: Bool = true) {
        guard currentRow < (tableView.numberOfRows - 1) else { return }
        tableView.selectRowIndexes(IndexSet(integer: currentRow + 1), byExtendingSelection: false)
        guard let vw = tableView.view(atColumn: 0, row: currentRow + 1, makeIfNecessary: true) as? JewelTableCellView else { return }
        tableView.scrollRowToVisible(currentRow + 1)
        if selectActual {
            view.window?.makeFirstResponder(vw.actualCodeTextField)
        } else {
            view.window?.makeFirstResponder(vw.computedCodeTextField)
        }
    }
}

