//
//  NamedSlider.swift
//  Pcsxr
//
//  Created by C.W. Betts on 11/9/14.
//
//

import Cocoa

final class NamedSlider: NSSlider {
	var strings: [String]? = nil
	
	override var stringValue: String {
		get {
			if let ourStrs = strings {
				let index = self.integerValue
				if index >= 0 && index < ourStrs.count {
					return ourStrs[index];
				}
				
			}
			return NSLocalizedString("(Unknown)", bundle: Bundle(for: type(of: self)), comment: "Unknown")
		}
		set {
			
		}
	}
	
	override var intValue: Int32 {
		didSet {
			sendAction(self.action, to: self.target)
		}
	}
	
	override var integerValue: Int {
		didSet {
			sendAction(self.action, to: self.target)
		}
	}
}
