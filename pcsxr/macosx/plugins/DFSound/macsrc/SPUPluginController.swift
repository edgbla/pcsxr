//
//  SPUPluginController.swift
//  Pcsxr
//
//  Created by C.W. Betts on 11/9/14.
//
//

import Cocoa

private var PrefsKey: String {
	return APP_ID + " Settings"
}

class SPUPluginController: NSWindowController {
	@IBOutlet var hiCompBox: NSCell!
	@IBOutlet var interpolValue: NamedSlider!
	@IBOutlet var irqWaitBox: NSCell!
	@IBOutlet var monoSoundBox: NSCell!
	@IBOutlet var reverbValue: NamedSlider!
	@IBOutlet var xaEnableBox: NSCell?
	@IBOutlet var xaSpeedBox: NSCell!
	@IBOutlet var volumeValue: NamedSlider!
	
	var keyValues = [String: Any]()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		let spuBundle = Bundle(for: type(of: self))
		
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
	
	@objc func loadValues() {
		let defaults = UserDefaults.standard
		ReadConfig()
		
		// Verify good preferences
		if defaults.dictionary(forKey: PrefsKey) == nil {
			defaults.removeObject(forKey: PrefsKey)
		}
		
		/* load from preferences */
		keyValues = defaults.dictionary(forKey: PrefsKey)!
		
		hiCompBox.state = (keyValues[kHighCompMode] as! Bool) ? .on : .off
		irqWaitBox.state = (keyValues[kSPUIRQWait] as! Bool) ? .on : .off
		monoSoundBox.state = (keyValues[kMonoSoundOut] as! Bool) ? .on : .off
		xaSpeedBox.state = (keyValues[kXAPitch] as! Bool) ? .on : .off
		
		interpolValue.integerValue = (keyValues[kInterpolQual] as! Int)
		reverbValue.integerValue = (keyValues[kReverbQual] as! Int)
		volumeValue.integerValue = (keyValues[kVolume] as! Int)
	}
	
	@IBAction func ok(_ sender: AnyObject?) {
		let defaults = UserDefaults.standard
		
		var writeDic = self.keyValues
		
		writeDic[kHighCompMode] = hiCompBox.state == .on ? true : false
		writeDic[kSPUIRQWait] = irqWaitBox.state == .on ? true : false
		writeDic[kMonoSoundOut] = monoSoundBox.state == .on ? true : false
		writeDic[kXAPitch] = xaSpeedBox.state == .on ? true : false

		writeDic[kInterpolQual] = interpolValue.integerValue
		writeDic[kReverbQual] = reverbValue.integerValue
		writeDic[kVolume] = volumeValue.integerValue
		
		// write to defaults
		defaults.set(writeDic, forKey: PrefsKey)
		defaults.synchronize()
		
		// and set global values accordingly
		ReadConfig()
		
		close()
	}
	
	@IBAction func cancel(_ sender: AnyObject?) {
		close()
	}
	
	@IBAction func reset(_ sender: AnyObject?) {
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: PrefsKey)
		loadValues()
	}
}
