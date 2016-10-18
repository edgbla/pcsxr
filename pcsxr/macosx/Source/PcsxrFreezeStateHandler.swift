//
//  PcsxrFreezeStateHandler.swift
//  Pcsxr
//
//  Created by C.W. Betts on 1/18/15.
//
//

import Cocoa

final class PcsxrFreezeStateHandler: NSObject, PcsxrFileHandle {
	static let supportedUTIs = ["com.codeplex.pcsxr.freeze"]
	
	func handleFile(_ theFile: String) -> Bool {
		if CheckState((theFile as NSString).fileSystemRepresentation) != 0 {
			return false
		}
		
		if !EmuThread.active {
			let pluginList = PluginList.shared
			if UserDefaults.standard.bool(forKey: "NetPlay") {
				pluginList!.enableNetPlug()
			} else {
				pluginList!.disableNetPlug()
			}
			
			EmuThread.run()
		}
		
		return EmuThread.defrost(at: theFile)
	}
}
