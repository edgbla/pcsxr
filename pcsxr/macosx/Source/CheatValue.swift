//
//  CheatValue.swift
//  Pcsxr
//
//  Created by C.W. Betts on 11/10/14.
//
//

import Cocoa

func ==(rhs: CheatValue, lhs: CheatValue) -> Bool {
	return rhs.cheatValue == lhs.cheatValue && rhs.cheatAddress == lhs.cheatAddress
}

class CheatValue: NSObject, NSCopying {
	var cheatAddress: UInt32
	var cheatValue: UInt16
	
	init(address add: UInt32, value val: UInt16) {
		cheatAddress = add
		cheatValue = val
		
		super.init()
	}
	
	convenience override init() {
		self.init(address: 0x10000000, value: 0)
	}
	
	convenience init(cheatCode cc: CheatCode) {
		self.init(address: cc.Addr, value: cc.Val)
	}
	
	override var hashValue: Int {
		return Int(cheatAddress ^ UInt32(cheatValue))
	}
	
	override var hash: Int {
		return self.hashValue
	}

	override var description: String {
		return String(format: "%08x %04x", cheatAddress, cheatValue)
	}
	
	override func isEqual(_ object: AnyObject?) -> Bool {
		if object == nil {
			return false
		}
		
		if let unwrapped = object as? CheatValue {
			return self == unwrapped
		} else {
			return false
		}
	}
	
	func copy(with zone: NSZone?) -> AnyObject {
		return CheatValue(address: cheatAddress, value: cheatValue)
	}
}
