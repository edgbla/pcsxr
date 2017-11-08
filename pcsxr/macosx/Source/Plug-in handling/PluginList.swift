//
//  PluginList.swift
//  Pcsxr
//
//  Created by C.W. Betts on 5/2/15.
//
//

import Foundation

private weak var sPluginList: PluginList? = nil
private let typeList = [PSE_LT_GPU, PSE_LT_SPU, PSE_LT_CDR, PSE_LT_PAD, PSE_LT_NET, PSE_LT_SIO1]

final class PluginList: NSObject {
	private var pluginList: [PcsxrPlugin]
	private var missingPlugins = false
	private var activeGpuPlugin: PcsxrPlugin?
	private var activeSpuPlugin: PcsxrPlugin?
	private var activeCdrPlugin: PcsxrPlugin?
	private var activePadPlugin: PcsxrPlugin?
	private var activeNetPlugin: PcsxrPlugin?
	private var activeSIO1Plugin: PcsxrPlugin?
	
	@objc(sharedList) class var shared: PluginList? {
		return sPluginList
	}
	
	override init() {
		let defaults = UserDefaults.standard
		pluginList = []
		
		super.init()
		
		for plugType in typeList {
			if let path = defaults.string(forKey: PcsxrPlugin.defaultKey(forType: plugType)) {
				if path == "Disabled" {
					continue
				}
				
				if !hasPluginAtPath(path) {
					autoreleasepool() {
						if let plugin = PcsxrPlugin(path: path) {
							pluginList.append(plugin)
							if !setActivePlugin(plugin, type: plugType) {
								missingPlugins = true
							}
						} else {
							missingPlugins = true
						}
					}
				}
			} else {
				missingPlugins = true
			}
		}
		
		if missingPlugins {
			refreshPlugins()
		}
		
		sPluginList = self
	}

	@objc func refreshPlugins() {
		let fm = FileManager.default
		
		// verify that the ones that are in list still works
		pluginList = pluginList.filter({ (plugIn) -> Bool in
			return plugIn.verifyOK()
		})
		
		// look for new ones in the plugin directory
		for plugDir in PcsxrPlugin.pluginsPaths {
			if let dirEnum = fm.enumerator(atPath: plugDir) {
				while let pName = dirEnum.nextObject() as? String {
					if (pName as NSString).pathExtension == "psxplugin" ||
						(pName as NSString).pathExtension == "so" {
							dirEnum.skipDescendants() /* don't enumerate this directory */
							if !(hasPluginAtPath((plugDir as NSString).appendingPathComponent(pName)) || hasPluginAtPath(pName)) {
								if let plugin = PcsxrPlugin(path: pName) {
									pluginList.append(plugin)
								} else if let plugIn = PcsxrPlugin(path: (plugDir as NSString).appendingPathComponent(pName)) {
									pluginList.append(plugIn)
								}
							}
					}
				}
			}
		}
		
		// check the we have the needed plugins
		missingPlugins = false
		for i in 0..<4 {
			let plugin = activePlugin(for: typeList[i])
			if plugin == nil {
				let list = pluginsForType(typeList[i])
				var j = 0
				while j < list.count {
					if setActivePlugin(list[j], type: typeList[i]) {
						break;
					}
					j += 1
				}
				if j == list.count {
					missingPlugins = true
				}
			}
		}
	}

	@objc func pluginsForType(_ typeMask: Int32) -> [PcsxrPlugin] {
		return pluginList.filter({ (plug) -> Bool in
			return (plug.type & typeMask) == typeMask
		})
	}
	
	@objc func hasPluginAtPath(_ path: String) -> Bool {
		for plugin in pluginList {
			if plugin.path == path {
				return true
			}
		}
		
		return false
	}
	
	/// returns true if all the required plugins are available
	@objc var configured: Bool {
		return !missingPlugins
	}
	
	@objc(activePluginForType:) func activePlugin(for type: Int32) -> PcsxrPlugin? {
		switch (type) {
		case PSE_LT_GPU:
			return activeGpuPlugin
			
		case PSE_LT_CDR:
			return activeCdrPlugin
			
		case PSE_LT_SPU:
			return activeSpuPlugin
			
		case PSE_LT_PAD:
			return activePadPlugin
			
		case PSE_LT_NET:
			return activeNetPlugin
			
		case PSE_LT_SIO1:
			return activeSIO1Plugin
			
		default:
			return nil
		}
	}
	
	@objc(setActivePlugin:forType:) func setActivePlugin(_ plugina: PcsxrPlugin, type: Int32) -> Bool {
		var pluginPtr: PcsxrPlugin?
		var plugin: PcsxrPlugin? = plugina
		switch type {
		case PSE_LT_SIO1, PSE_LT_GPU, PSE_LT_CDR, PSE_LT_SPU, PSE_LT_PAD, PSE_LT_NET:
			pluginPtr = activePlugin(for: type)
			
		default:
			return false
		}
		
		if plugin === pluginPtr {
			return true
		}
		
		let active = (pluginPtr != nil) && EmuThread.active
		var wasPaused = false
		if active {
			//TODO: temporary freeze?
			wasPaused = EmuThread.pauseSafe()
			ClosePlugins()
			ReleasePlugins()
		}
		
		// stop the old plugin and start the new one
		if let aPlug = pluginPtr {
			aPlug.shutdown(as: type)
			pluginPtr = nil;
		}

		if plugin!.run(as: type) != 0 {
			plugin = nil
		}
		
		switch (type) {
		case PSE_LT_GPU:
			activeGpuPlugin = plugin;

		case PSE_LT_CDR:
			activeCdrPlugin = plugin;

		case PSE_LT_SPU:
			activeSpuPlugin = plugin;

		case PSE_LT_PAD:
			activePadPlugin = plugin;

		case PSE_LT_NET:
			activeNetPlugin = plugin;

		case PSE_LT_SIO1:
			activeSIO1Plugin = plugin;
			
		default:
			assertionFailure("We shouldn't get here... at all!")
			
		}

		// write path to the correct config entry
		var str: Array<Int8>
		if let plugin = plugin {
			let strA = (plugin.path as NSString).fileSystemRepresentation
			// Include the null terminator
			let tmpStr = UnsafeBufferPointer(start: strA, count: Int(strlen(strA)) + 1)
			str = Array(tmpStr)
		} else {
			str = "Invalid Plugin".cString(using: String.Encoding.utf8)!
		}

		var dst = PcsxrPlugin.configEntries(forType: type)
		while dst.pointee != nil {
			strlcpy(dst.pointee, str, Int(MAXPATHLEN))
			dst = dst.successor()
		}
		
		if active {
			LoadPlugins()
			OpenPlugins()
			
			if !wasPaused {
				EmuThread.resume()
			}
		}
		
		return plugin != nil;
	}
	
	@objc func disableNetPlug() {
		var dst = PcsxrPlugin.configEntries(forType: PSE_LT_NET)
		while dst.pointee != nil {
			strcpy(dst.pointee, "Disabled");
			dst = dst.successor();
		}
	}
	
	@objc func enableNetPlug() {
		if let netPlug = activePlugin(for: PSE_LT_NET) {
			let str = (netPlug.path as NSString).fileSystemRepresentation
			var dst = PcsxrPlugin.configEntries(forType: PSE_LT_NET)
			while dst.pointee != nil {
				strlcpy(dst.pointee, str, Int(MAXPATHLEN));
				dst = dst.successor();
			}
		}
	}
	
	subscript(index: Int) -> PcsxrPlugin {
		return pluginList[index]
	}
	
	var count: Int {
		return pluginList.count
	}
}
