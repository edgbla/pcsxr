//
//  SPUPluginController.swift
//  Pcsxr
//
//  Created by C.W. Betts on 11/9/14.
//
//

import Cocoa

private let PrefsKey = APP_ID + " Settings"

class SPUPluginController: NSWindowController {
	@IBOutlet var hiCompBox: NSCell!
	@IBOutlet var interpolValue: NamedSlider!
	@IBOutlet var irqWaitBox: NSCell!
	@IBOutlet var monoSoundBox: NSCell!
	@IBOutlet var reverbValue: NamedSlider!
	@IBOutlet var xaEnableBox: NSCell?
	@IBOutlet var xaSpeedBox: NSCell!
	@IBOutlet var volumeValue: NamedSlider!
	
	var keyValues = NSMutableDictionary()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		let spuBundle = NSBundle(forClass: self.dynamicType)
		
		interpolValue.strings = [NSLocalizedString("(No Interpolation)", bundle: spuBundle, comment: "(No Interpolation)"),
			NSLocalizedString("(Simple Interpolation)", bundle: spuBundle, comment: "(Simple Interpolation)"),
			NSLocalizedString("(Gaussian Interpolation)", bundle: spuBundle, comment: "(Gaussian Interpolation)"),
			NSLocalizedString("(Cubic Interpolation)", bundle: spuBundle, comment: "(Cubic Interpolation)")]
		
		reverbValue.strings = [NSLocalizedString("(No Reverb)", bundle: spuBundle, comment: "(No Reverb)"),
			NSLocalizedString("(Simple Reverb)", bundle: spuBundle, comment: "(Simple Reverb)"),
			NSLocalizedString("(PSX Reverb)", bundle: spuBundle, comment: "(PSX Reverb)")]
		
		volumeValue.strings = [NSLocalizedString("(Muted)", bundle: spuBundle, comment: "(Muted)"),
			NSLocalizedString("(Low)", bundle: spuBundle, comment: "(Low)"),
			NSLocalizedString("(Medium)", bundle: spuBundle, comment: "(Medium)"),
			NSLocalizedString("(Loud)", bundle: spuBundle, comment: "(Loud)"),
			NSLocalizedString("(Loudest)", bundle: spuBundle, comment: "(Loudest)")]
	}
	
	func loadValues() {
		let defaults = NSUserDefaults.standardUserDefaults()
		ReadConfig()
		
		/* load from preferences */
		keyValues = NSMutableDictionary(dictionary: defaults.dictionaryForKey(PrefsKey)!)
		
		hiCompBox.integerValue = (keyValues[kHighCompMode] as! Bool) ? NSOnState : NSOffState
		irqWaitBox.integerValue = (keyValues[kSPUIRQWait] as! Bool) ? NSOnState : NSOffState
		monoSoundBox.integerValue = (keyValues[kMonoSoundOut] as! Bool) ? NSOnState : NSOffState
		xaSpeedBox.integerValue = (keyValues[kXAPitch] as! Bool) ? NSOnState : NSOffState
		
		interpolValue.integerValue = (keyValues[kInterpolQual] as! Int)
		reverbValue.integerValue = (keyValues[kReverbQual] as! Int)
		volumeValue.integerValue = (keyValues[kVolume] as! Int)
	}
	
	@IBAction func ok(sender: AnyObject?) {
		let defaults = NSUserDefaults.standardUserDefaults()
		
		let writeDic = NSMutableDictionary(dictionary: self.keyValues)
		
		writeDic[kHighCompMode] = hiCompBox.integerValue == NSOnState ? true : false
		writeDic[kSPUIRQWait] = irqWaitBox.integerValue == NSOnState ? true : false
		writeDic[kMonoSoundOut] = monoSoundBox.integerValue == NSOnState ? true : false
		writeDic[kXAPitch] = xaSpeedBox.integerValue == NSOnState ? true : false

		writeDic[kInterpolQual] = interpolValue.integerValue
		writeDic[kReverbQual] = reverbValue.integerValue
		writeDic[kVolume] = volumeValue.integerValue
		
		// write to defaults
		defaults.setObject(writeDic, forKey: PrefsKey)
		defaults.synchronize()
		
		// and set global values accordingly
		ReadConfig()
		
		close()
	}
	
	@IBAction func cancel(sender: AnyObject?) {
		close()
	}
	
	@IBAction func reset(sender: AnyObject?) {
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.removeObjectForKey(PrefsKey)
		loadValues()
	}
}
