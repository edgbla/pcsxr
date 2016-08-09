//
//  LaunchArg.swift
//  Pcsxr
//
//  Created by C.W. Betts on 11/9/14.
//
//

import Cocoa

@objc enum LaunchArgOrder: UInt32 {
	case preRun = 0
	case run = 200
	case postRun = 400
}

final class LaunchArg: NSObject {
	let launchOrder: UInt32
	let theBlock: ()->()
	let argument: String

	init(launchOrder order: UInt32, argument arg: String, block: ()->()) {
		launchOrder = order
		argument = arg
		theBlock = block
		
		super.init()
	}
	
	func addToDictionary(_ toAdd: NSMutableDictionary) {
		toAdd[argument] = self;
	}
	
	override var description: String {
		return "Arg: \(argument), order: \(launchOrder), block addr: \(theBlock)"
	}
}
