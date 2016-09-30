//
//  PcsxrMemoryObject.swift
//  Pcsxr
//
//  Created by C.W. Betts on 11/9/14.
//
//

import Cocoa
import SwiftAdditions

@objc enum PCSXRMemFlag: Int8 {
	case deleted
	case free
	case used
	case link
	case endLink
};

private func imagesFromMcd(_ theBlock: UnsafePointer<McdBlock>) -> [NSImage] {
	struct PSXRGBColor {
		var r: UInt8
		var g: UInt8
		var b: UInt8
	}

	var toRet = [NSImage]()
	let unwrapped = theBlock.pointee
	let iconArray: [Int16] = try! arrayFromObject(reflecting: unwrapped.Icon)
	for i in 0..<unwrapped.IconCount {
		if let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 16, pixelsHigh: 16, bitsPerSample: 8, samplesPerPixel: 3, hasAlpha: false, isPlanar: false, colorSpaceName: NSCalibratedRGBColorSpace, bytesPerRow: 16 * 3, bitsPerPixel: 24) {
			imageRep.bitmapData?.withMemoryRebound(to: PSXRGBColor.self, capacity: 256, { (cocoaImageData) -> Void in
				for v in 0..<256 {
					//let x = v % 16
					//let y = v / 16
					let c = iconArray[Int(i * 256) + v]
					let r: Int32 = Int32(c & 0x001F) << 3
					let g: Int32 = (Int32(c & 0x03E0) >> 5) << 3
					let b: Int32 = (Int32(c & 0x7C00) >> 10) << 3
					cocoaImageData[v] = PSXRGBColor(r: UInt8(r), g: UInt8(g), b: UInt8(b))
				}
			})
			let memImage = NSImage()
			memImage.addRepresentation(imageRep)
			memImage.size = NSSize(width: 32, height: 32)
			toRet.append(memImage)
		}
	}
	return toRet
}

private func memoryLabelFromFlag(_ flagNameIndex: PCSXRMemFlag) -> String {
	switch (flagNameIndex) {
	case .endLink:
		return MemLabelEndLink;
		
	case .link:
		return MemLabelLink;
		
	case .used:
		return MemLabelUsed;
		
	case .deleted:
		return MemLabelDeleted;
		
	default:
		return MemLabelFree;
	}
}

private let MemLabelDeleted		= NSLocalizedString("MemCard_Deleted", comment: "MemCard_Deleted")
private let MemLabelFree		= NSLocalizedString("MemCard_Free", comment: "MemCard_Free")
private let MemLabelUsed		= NSLocalizedString("MemCard_Used", comment: "MemCard_Used")
private let MemLabelLink		= NSLocalizedString("MemCard_Link", comment: "MemCard_Link")
private let MemLabelEndLink		= NSLocalizedString("MemCard_EndLink", comment: "MemCard_EndLink")
private let MemLabelMultiSave	= NSLocalizedString("MemCard_MultiSave", comment: "MemCard_MultiSave")

private var attribMemLabelDeleted	= NSAttributedString()
private var attribMemLabelFree		= NSAttributedString()
private var attribMemLabelUsed		= NSAttributedString()
private var attribMemLabelLink		= NSAttributedString()
private var attribMemLabelEndLink	= NSAttributedString()
private var attribMemLabelMultiSave	= NSAttributedString()

private var imageBlank: NSImage? = nil
private func blankImage() -> NSImage {
	if imageBlank == nil {
		let imageRect = NSRect(x: 0, y: 0, width: 16, height: 16)
		let anImg = NSImage(size: imageRect.size)
		anImg.lockFocus()
		NSColor.black.set()
		NSBezierPath.fill(imageRect)
		anImg.unlockFocus()
		imageBlank = anImg
	}
	return imageBlank!.copy() as! NSImage
}

func MemFlagsFromBlockFlags(_ blockFlags: UInt8) -> PCSXRMemFlag {
	if ((blockFlags & 0xF0) == 0xA0) {
		if ((blockFlags & 0xF) >= 1 && (blockFlags & 0xF) <= 3) {
			return .deleted;
		} else {
			return .free
		}
	} else if ((blockFlags & 0xF0) == 0x50) {
		if ((blockFlags & 0xF) == 0x1) {
			return .used
		} else if ((blockFlags & 0xF) == 0x2) {
			return .link
		} else if ((blockFlags & 0xF) == 0x3) {
			return .endLink
		}
	} else {
		return .free;
	}
	
	//Xcode complains unless we do this...
	NSLog("Unknown flag %x", blockFlags)
	return .free;
}

final class PcsxrMemoryObject: NSObject {
	private static var __once: () = {
			func SetupAttrStr(_ mutStr: NSMutableAttributedString, txtclr: NSColor) {
				let wholeStrRange = NSMakeRange(0, mutStr.string.utf16.count);
				let ourAttrs: [String: AnyObject] = [NSFontAttributeName : NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small)),
					NSForegroundColorAttributeName: txtclr]
				mutStr.addAttributes(ourAttrs, range: wholeStrRange)
				mutStr.setAlignment(.center, range: wholeStrRange)
			}
			
			var tmpStr = NSMutableAttributedString(string: MemLabelFree)
			SetupAttrStr(tmpStr, txtclr: NSColor.green)
			attribMemLabelFree = NSAttributedString(attributedString: tmpStr)
			
			#if DEBUG
				tmpStr = NSMutableAttributedString(string: MemLabelEndLink)
				SetupAttrStr(tmpStr, txtclr: NSColor.blue)
				attribMemLabelEndLink = NSAttributedString(attributedString: tmpStr)
				
				tmpStr = NSMutableAttributedString(string: MemLabelLink)
				SetupAttrStr(tmpStr, txtclr: NSColor.blue)
				attribMemLabelLink = NSAttributedString(attributedString: tmpStr)
				
				tmpStr = NSMutableAttributedString(string: MemLabelUsed)
				SetupAttrStr(tmpStr, txtclr: NSColor.controlTextColor)
				attribMemLabelUsed = NSAttributedString(attributedString: tmpStr)
			#else
				tmpStr = NSMutableAttributedString(string: MemLabelMultiSave)
				SetupAttrStr(tmpStr, txtclr: NSColor.blue)
				attribMemLabelEndLink = AttributedString(attributedString: tmpStr)
				attribMemLabelLink = attribMemLabelEndLink

				//display nothing
				attribMemLabelUsed = AttributedString(string: "")
			#endif
			
			tmpStr = NSMutableAttributedString(string: MemLabelDeleted)
			SetupAttrStr(tmpStr, txtclr: NSColor.red)
			attribMemLabelDeleted = NSAttributedString(attributedString: tmpStr)
		}()
	let title: String
	let name: String
	let identifier: String
	let imageArray: [NSImage]
	let flag: PCSXRMemFlag
	let indexes: IndexSet
	let hasImages: Bool
	
	var blockSize: Int {
		return indexes.count
	}
	
	init(mcdBlock infoBlock: UnsafePointer<McdBlock>, blockIndexes: IndexSet) {
		self.indexes = blockIndexes
		let unwrapped = infoBlock.pointee
		flag = MemFlagsFromBlockFlags(unwrapped.Flags)
		if flag == .free {
			imageArray = []
			hasImages = false
			title = "Free block"
			identifier = ""
			name = ""
		} else {
			let sjisName: [CChar] = try! arrayFromObject(reflecting: unwrapped.sTitle, appendLastObject: 0)
			if let aname = String(cString: sjisName, encoding: String.Encoding.shiftJIS) {
				title = aname
			} else {
				let usName: [CChar] = try! arrayFromObject(reflecting: unwrapped.Title, appendLastObject: 0)
				title = String(cString: usName, encoding: String.Encoding.ascii)!
			}
			imageArray = imagesFromMcd(infoBlock)
			if imageArray.count == 0 {
				hasImages = false
			} else {
				hasImages = true
			}
			let memNameCArray: [CChar] = try! arrayFromObject(reflecting: unwrapped.Name, appendLastObject: 0)
			let memIDCArray: [CChar] = try! arrayFromObject(reflecting: unwrapped.ID, appendLastObject: 0)
			name = String(validatingUTF8: memNameCArray)!
			identifier = String(validatingUTF8: memIDCArray)!
		}
		
		super.init()
	}
	
	convenience init(mcdBlock infoBlock: UnsafePointer<McdBlock>, startingIndex startIdx: Int, size memSize: Int) {
		self.init(mcdBlock: infoBlock, blockIndexes: IndexSet(integersIn: NSRange(location: startIdx, length: memSize).toRange() ?? startIdx ..< (startIdx + memSize)))
	}
	
	var iconCount: Int {
		return imageArray.count
	}

	class func memFlagsFromBlockFlags(_ blockFlags: UInt8) -> PCSXRMemFlag {
		return MemFlagsFromBlockFlags(blockFlags)
	}
	
	private(set) lazy var image: NSImage = {
		if (self.hasImages == false) {
			let tmpBlank = blankImage()
			tmpBlank.size = NSMakeSize(32, 32)
			return tmpBlank
		}
		
		let gifData = NSMutableData()
		
		let dst = CGImageDestinationCreateWithData(gifData, kUTTypeGIF, self.iconCount, nil)!
		let gifPrep: NSDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: Float(0.30)]];
		for theImage in self.imageArray {
			let imageRef = theImage.cgImage(forProposedRect: nil, context: nil, hints: nil)!
			CGImageDestinationAddImage(dst, imageRef, gifPrep)
		}
		CGImageDestinationFinalize(dst);
		
		let _memImage = NSImage(data: gifData as Data)!
		_memImage.size = NSMakeSize(32, 32)
		return _memImage
		}()
	
	private static var attribsInit: Int = 0
	var attributedFlagName: NSAttributedString {
		_ = PcsxrMemoryObject.__once
		
		switch (flag) {
		case .endLink:
			return attribMemLabelEndLink;
			
		case .link:
			return attribMemLabelLink;
			
		case .used:
			return attribMemLabelUsed;
			
		case .deleted:
			return attribMemLabelDeleted;
			
		default:
			return attribMemLabelFree;
		}
	}
	
	var firstImage: NSImage {
		if hasImages == false {
			return blankImage()
		}
		return imageArray[0]
	}
	
	class func memoryLabelFromFlag(_ flagNameIdx: PCSXRMemFlag) -> String {
		return memoryLabelFromFlag(flagNameIdx)
	}
	
	var flagName: String {
		return memoryLabelFromFlag(flag)
	}

	override var description: String {
		return "\(title): Name: \(name) ID: \(identifier), type: \(flagName), indexes: \(indexes)"
	}
	
	var showCount: Bool {
		if flag == .free {
			//Always show the size of the free blocks
			return true;
		} else {
			return blockSize != 1;
		}
	}
}
