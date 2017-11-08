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
	@objc let launchOrder: UInt32
	@objc let theBlock: ()->()
	@objc let argument: String

	@objc init(launchOrder order: UInt32, argument arg: String, block: @escaping ()->()) {
		launchOrder = order
		argument = arg
		theBlock = block
		
		super.init()
	}
	
	@objc(addToDictionary:) func add(to toAdd: NSMutableDictionary) {
		toAdd[argument] = self;
	}
	
	func add(to toAdd: inout [String: LaunchArg]) {
		toAdd[argument] = self;
	}
	
	override var description: String {
		return "Arg: \(argument), order: \(launchOrder), block addr: \(theBlock)"
	}
}
