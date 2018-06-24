//
//  AddCaptionOperation.swift
//  JewelCodeRemover
//
//  Created by Vikram Raj Gopinathan on 22/06/18.
//  Copyright © 2018 Vikram Raj Gopinathan. All rights reserved.
//

import Cocoa

class AddCaptionOperation: Operation {
    let jewel: Jewel
    
    // Customizations
    private let padding: CGFloat = 20.0
    private let fontSize: CGFloat = 36.0
    
    init(jewel: Jewel) {
        self.jewel = jewel
    }
    
    override func main() {
        guard !self.isCancelled else { return }
        
        guard let codeRemovedURL = jewel.codeRemoved,
            let codeRemoved = NSImage(contentsOf: codeRemovedURL)
        else {
            return
        }
        
        let captionAddded = drawText(jewel.displayCode, in: codeRemoved)
        
        guard let dest = url(for: jewel) else {
            print("Cannot get cache url")
            return
        }
        
        try? captionAddded.writeJPEG(to: dest)
        jewel.captionAdded = dest
    }
    
    private func url(for jewel: Jewel) -> URL? {
        let fm = FileManager.default
        guard let cachesDirectory = fm.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        
        guard let appId = Bundle.main.bundleIdentifier else { return nil }
        let appCache = cachesDirectory.appendingPathComponent(appId)
        return appCache.appendingPathComponent(jewel.fileName)
    }
    
    private func drawText(_ text: String, in image: NSImage) -> NSImage {
        let font = NSFont.boldSystemFont(ofSize: fontSize)
        let imageRect = CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height)
        let textRect = textRectForImageSize(image.size, withPointSize: font.pointSize)
        
        let output = NSImage(size: image.size)
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                   pixelsWide: Int(image.size.width),
                                   pixelsHigh: Int(image.size.height),
                                   bitsPerSample: 8,
                                   samplesPerPixel: 4,
                                   hasAlpha: true,
                                   isPlanar: false,
                                   colorSpaceName: NSColorSpaceName.calibratedRGB ,
                                   bytesPerRow: 0,
                                   bitsPerPixel: 0)!
        output.addRepresentation(rep)
        output.lockFocus()
        image.draw(in: imageRect)
        (text as NSString).draw(in: textRect, withAttributes: getFontAttributes())
        output.unlockFocus()
        return output
    }
    
    private func getFontAttributes() -> [NSAttributedStringKey: Any] {
        let format = jewel.format
        let fontColor: NSColor = format.color == .light ? NSColor.white : NSColor.black
        let font = NSFont.boldSystemFont(ofSize: fontSize)
        
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = format.horizontalAlignment == .left ? .left : .right
        
        return [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.foregroundColor: fontColor,
            NSAttributedStringKey.paragraphStyle: textStyle
        ]
    }
    
    private func textRectForImageSize(_ size: NSSize, withPointSize pointSize: CGFloat) -> CGRect {
        let format = jewel.format
        var rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        if size.width > padding * 3 {
            rect.origin.x = padding
            rect.size.width = size.width - padding * 2.0
        }
        
        if size.height > padding * 3 {
            rect.origin.y = padding
            if format.verticalAlignment == .bottom {
                rect.size.height = pointSize
            } else {
                rect.size.height = size.height - padding * 2.0
            }
        }
        
        return rect
    }
}
