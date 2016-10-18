//
//  PluginController.swift
//  Pcsxr
//
//  Created by C.W. Betts on 5/2/15.
//
//

import Cocoa

final class PluginController: NSObject {
	@IBOutlet weak var aboutButton: NSButton!
	@IBOutlet weak var configureButton: NSButton!
	@IBOutlet weak var pluginMenu: NSPopUpButton!

	private var plugins = [PcsxrPlugin]()
	private var defaultKey = ""
	private var pluginType: Int32 = 0
	
	@IBAction func doAbout(_ sender: AnyObject?) {
		let plugin = plugins[pluginMenu.indexOfSelectedItem]
		plugin.about(as: pluginType)
	}
	
	@IBAction func doConfigure(_ sender: AnyObject?) {
		let plugin = plugins[pluginMenu.indexOfSelectedItem]
		plugin.configure(as: pluginType)
	}

	@IBAction func selectPlugin(_ sender: AnyObject?) {
		if sender === pluginMenu {
			let index = pluginMenu.indexOfSelectedItem
			if index != -1 {
				let plugin = plugins[index];
				
				if !PluginList.shared!.setActivePlugin(plugin, type: pluginType) {
					/* plugin won't initialize */
				}
				
				// write selection to defaults
				UserDefaults.standard.set(plugin.path, forKey: defaultKey)
				
				// set button states
				aboutButton.isEnabled = plugin.hasAbout(as: pluginType)
				configureButton.isEnabled = plugin.hasConfigure(as: pluginType)
			} else {
				// set button states
				aboutButton.isEnabled = false
				configureButton.isEnabled = false
			}
		}
	}

	/// must be called before anything else
	func setPluginsTo(_ list: [PcsxrPlugin], withType type: Int32) {
		// remember the list
		pluginType = type
		plugins = list.sorted(by: { (lhs, rhs) -> Bool in
			let sortOrder = lhs.description.localizedStandardCompare(rhs.description)
			return sortOrder == .orderedAscending
		})
		defaultKey = PcsxrPlugin.defaultKey(forType: pluginType)
		
		// clear the previous menu items
		pluginMenu.removeAllItems()
		
		// load the currently selected plugin
		let sel = UserDefaults.standard.string(forKey: defaultKey)
		
		// add the menu entries
		for plug in plugins {
			let description = plug.description
			pluginMenu.addItem(withTitle: description)
			
			// make sure the currently selected is set as such
			if let sel = sel, sel == plug.path {
				pluginMenu.selectItem(withTitle: description)
			}
		}
		
		selectPlugin(pluginMenu)
	}
}
