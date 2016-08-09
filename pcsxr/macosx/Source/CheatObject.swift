//
//  CheatObject.swift
//  Pcsxr
//
//  Created by C.W. Betts on 11/10/14.
//
//

import Cocoa
import SwiftAdditions

func ==(rhs: CheatObject, lhs: CheatObject) -> Bool {
	return rhs.cheatName == lhs.cheatName && rhs.values == lhs.values
}

class CheatObject: NSObject, Sequence {
	var cheatName: String
	var values: [CheatValue]
	var enabled: Bool
	
	init(cheat: Cheat) {
		cheatName = String(validatingUTF8: cheat.Descr)!
		enabled = cheat.Enabled == 0 ? false : true
		values = [CheatValue]()
		for i in 0..<cheat.n {
			let aCheat = CheatValue(cheatCode: CheatCodes[Int(i + cheat.First)])
			values.append(aCheat)
		}
		
		super.init()
	}
	
	func addValuesObject(_ aVal: CheatValue) {
		values.append(aVal)
	}
	
	func addValueObject(_ aVal: CheatValue) {
		addValuesObject(aVal)
	}
	
	var countOfValues: Int {
		return values.count
	}
	
	subscript(index: Int) -> CheatValue {
		get {
			return values[index]
		}
		set {
			values[index] = newValue
		}
	}
	
	func makeIterator() -> IndexingIterator<[CheatValue]> {
		return values.makeIterator()
	}
	
	init(name: String, enabled: Bool = false) {
		cheatName = name
		self.enabled = enabled
		values = [CheatValue()]
		
		super.init()
	}
	
	override convenience init() {
		self.init(name: "")
	}
	
	override var hashValue: Int {
		return cheatName.hashValue ^ values.count
	}
	
	override var hash: Int {
		return self.hashValue
	}
	
	override func isEqual(_ object: AnyObject?) -> Bool {
		if object == nil {
			return false
		}
		
		if let unwrapped = object as? CheatObject {
			return self == unwrapped
		} else {
			return false
		}
	}
	
	override var description: String {
		var valueString = ""
		for aCheat in values {
			valueString += aCheat.description + "\n"
		}
		return "[" + (enabled ? "*" : "") + cheatName + "]\n" + valueString
	}
}
