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
	case Deleted
	case Free
	case Used
	case Link
	case EndLink
};

private func imagesFromMcd(theBlock: UnsafePointer<McdBlock>) -> [NSImage] {
	struct PSXRGBColor {
		var r: UInt8
		var g: UInt8
		var b: UInt8
	}

	var toRet = [NSImage]()
	let unwrapped = theBlock.memory
	let iconArray: [Int16] = try! arrayFromObject(reflecting: unwrapped.Icon)
	for i in 0..<unwrapped.IconCount {
		if let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 16, pixelsHigh: 16, bitsPerSample: 8, samplesPerPixel: 3, hasAlpha: false, isPlanar: false, colorSpaceName: NSCalibratedRGBColorSpace, bytesPerRow: 16 * 3, bitsPerPixel: 24) {
			let cocoaImageData = UnsafeMutablePointer<PSXRGBColor>(imageRep.bitmapData)
			for v in 0..<256 {
				//let x = v % 16
				//let y = v / 16
				let c = iconArray[Int(i * 256) + v]
				let r: Int32 = Int32(c & 0x001F) << 3
				let g: Int32 = (Int32(c & 0x03E0) >> 5) << 3
				let b: Int32 = (Int32(c & 0x7C00) >> 10) << 3
				cocoaImageData[v] = PSXRGBColor(r: UInt8(r), g: UInt8(g), b: UInt8(b))
			}
			let memImage = NSImage()
			memImage.addRepresentation(imageRep)
			memImage.size = NSSize(width: 32, height: 32)
			toRet.append(memImage)
		}
	}
	return toRet
}

private func memoryLabelFromFlag(flagNameIndex: PCSXRMemFlag) -> String {
	switch (flagNameIndex) {
	case .EndLink:
		return MemLabelEndLink;
		
	case .Link:
		return MemLabelLink;
		
	case .Used:
		return MemLabelUsed;
		
	case .Deleted:
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
		NSColor.blackColor().set()
		NSBezierPath.fillRect(imageRect)
		anImg.unlockFocus()
		imageBlank = anImg
	}
	return imageBlank!.copy() as! NSImage
}

func MemFlagsFromBlockFlags(blockFlags: UInt8) -> PCSXRMemFlag {
	if ((blockFlags & 0xF0) == 0xA0) {
		if ((blockFlags & 0xF) >= 1 && (blockFlags & 0xF) <= 3) {
			return .Deleted;
		} else {
			return .Free
		}
	} else if ((blockFlags & 0xF0) == 0x50) {
		if ((blockFlags & 0xF) == 0x1) {
			return .Used
		} else if ((blockFlags & 0xF) == 0x2) {
			return .Link
		} else if ((blockFlags & 0xF) == 0x3) {
			return .EndLink
		}
	} else {
		return .Free;
	}
	
	//Xcode complains unless we do this...
	NSLog("Unknown flag %x", blockFlags)
	return .Free;
}

final class PcsxrMemoryObject: NSObject {
	let title: String
	let name: String
	let identifier: String
	let imageArray: [NSImage]
	let flag: PCSXRMemFlag
	let indexes: NSIndexSet
	let hasImages: Bool
	
	var blockSize: Int {
		return indexes.count
	}
	
	init(mcdBlock infoBlock: UnsafePointer<McdBlock>, blockIndexes: NSIndexSet) {
		self.indexes = blockIndexes
		let unwrapped = infoBlock.memory
		flag = MemFlagsFromBlockFlags(unwrapped.Flags)
		if flag == .Free {
			imageArray = []
			hasImages = false
			title = "Free block"
			identifier = ""
			name = ""
		} else {
			let sjisName: [CChar] = try! arrayFromObject(reflecting: unwrapped.sTitle, appendLastObject: 0)
			if let aname = String(CString: sjisName, encoding:NSShiftJISStringEncoding) {
				title = aname
			} else {
				let usName: [CChar] = try! arrayFromObject(reflecting: unwrapped.Title, appendLastObject: 0)
				title = String(CString: usName, encoding: NSASCIIStringEncoding)!
			}
			imageArray = imagesFromMcd(infoBlock)
			if imageArray.count == 0 {
				hasImages = false
			} else {
				hasImages = true
			}
			let memNameCArray: [CChar] = try! arrayFromObject(reflecting: unwrapped.Name, appendLastObject: 0)
			let memIDCArray: [CChar] = try! arrayFromObject(reflecting: unwrapped.ID, appendLastObject: 0)
			name = String(UTF8String: memNameCArray)!
			identifier = String(UTF8String: memIDCArray)!
		}
		
		super.init()
	}
	
	convenience init(mcdBlock infoBlock: UnsafePointer<McdBlock>, startingIndex startIdx: Int, size memSize: Int) {
		self.init(mcdBlock: infoBlock, blockIndexes: NSIndexSet(indexesInRange: NSRange(location: startIdx, length: memSize)))
	}
	
	var iconCount: Int {
		return imageArray.count
	}

	class func memFlagsFromBlockFlags(blockFlags: UInt8) -> PCSXRMemFlag {
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
			let imageRef = theImage.CGImageForProposedRect(nil, context: nil, hints: nil)!
			CGImageDestinationAddImage(dst, imageRef, gifPrep)
		}
		CGImageDestinationFinalize(dst);
		
		let _memImage = NSImage(data: gifData)!
		_memImage.size = NSMakeSize(32, 32)
		return _memImage
		}()
	
	private static var attribsInit: dispatch_once_t = 0
	var attributedFlagName: NSAttributedString {
		dispatch_once(&PcsxrMemoryObject.attribsInit) {
			func SetupAttrStr(mutStr: NSMutableAttributedString, txtclr: NSColor) {
				let wholeStrRange = NSMakeRange(0, mutStr.string.characters.count);
				let ourAttrs: [String: AnyObject] = [NSFontAttributeName : NSFont.systemFontOfSize(NSFont.systemFontSizeForControlSize(.SmallControlSize)),
					NSForegroundColorAttributeName: txtclr]
				mutStr.addAttributes(ourAttrs, range: wholeStrRange)
				mutStr.setAlignment(.Center, range: wholeStrRange)
			}
			
			var tmpStr = NSMutableAttributedString(string: MemLabelFree)
			SetupAttrStr(tmpStr, txtclr: NSColor.greenColor())
			attribMemLabelFree = NSAttributedString(attributedString: tmpStr)
			
			#if DEBUG
				tmpStr = NSMutableAttributedString(string: MemLabelEndLink)
				SetupAttrStr(tmpStr, txtclr: NSColor.blueColor())
				attribMemLabelEndLink = NSAttributedString(attributedString: tmpStr)
				
				tmpStr = NSMutableAttributedString(string: MemLabelLink)
				SetupAttrStr(tmpStr, txtclr: NSColor.blueColor())
				attribMemLabelLink = NSAttributedString(attributedString: tmpStr)
				
				tmpStr = NSMutableAttributedString(string: MemLabelUsed)
				SetupAttrStr(tmpStr, txtclr: NSColor.controlTextColor())
				attribMemLabelUsed = NSAttributedString(attributedString: tmpStr)
			#else
				tmpStr = NSMutableAttributedString(string: MemLabelMultiSave)
				SetupAttrStr(tmpStr, txtclr: NSColor.blueColor())
				attribMemLabelEndLink = NSAttributedString(attributedString: tmpStr)
				attribMemLabelLink = attribMemLabelEndLink

				//display nothing
				attribMemLabelUsed = NSAttributedString(string: "")
			#endif
			
			tmpStr = NSMutableAttributedString(string: MemLabelDeleted)
			SetupAttrStr(tmpStr, txtclr: NSColor.redColor())
			attribMemLabelDeleted = NSAttributedString(attributedString: tmpStr)
		}
		
		switch (flag) {
		case .EndLink:
			return attribMemLabelEndLink;
			
		case .Link:
			return attribMemLabelLink;
			
		case .Used:
			return attribMemLabelUsed;
			
		case .Deleted:
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
	
	class func memoryLabelFromFlag(flagNameIdx: PCSXRMemFlag) -> String {
		return memoryLabelFromFlag(flagNameIdx)
	}
	
	var flagName: String {
		return memoryLabelFromFlag(flag)
	}

	override var description: String {
		return "\(title): Name: \(name) ID: \(identifier), type: \(flagName), indexes: \(indexes)"
	}
	
	var showCount: Bool {
		if flag == .Free {
			//Always show the size of the free blocks
			return true;
		} else {
			return blockSize != 1;
		}
	}
}
