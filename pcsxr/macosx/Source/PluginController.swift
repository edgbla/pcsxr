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
	
	@IBAction func doAbout(sender: AnyObject?) {
		let plugin = plugins[pluginMenu.indexOfSelectedItem]
		plugin.aboutAs(pluginType)
	}
	
	@IBAction func doConfigure(sender: AnyObject?) {
		let plugin = plugins[pluginMenu.indexOfSelectedItem]
		plugin.configureAs(pluginType)
	}

	@IBAction func selectPlugin(sender: AnyObject?) {
		if sender === pluginMenu {
			let index = pluginMenu.indexOfSelectedItem
			if index != -1 {
				let plugin = plugins[index];
				
				if !PluginList.sharedList!.setActivePlugin(plugin, type: pluginType) {
					/* plugin won't initialize */
				}
				
				// write selection to defaults
				NSUserDefaults.standardUserDefaults().setObject(plugin.path, forKey: defaultKey)
				
				// set button states
				aboutButton.enabled = plugin.hasAboutAs(pluginType)
				configureButton.enabled = plugin.hasConfigureAs(pluginType)
			} else {
				// set button states
				aboutButton.enabled = false
				configureButton.enabled = false
			}
		}
	}

	/// must be called before anything else
	func setPluginsTo(list: [PcsxrPlugin], withType type: Int32) {
		// remember the list
		pluginType = type
		plugins = list.sort({ (lhs, rhs) -> Bool in
			let sortOrder = lhs.description.localizedStandardCompare(rhs.description)
			return sortOrder == .OrderedAscending
		})
		defaultKey = PcsxrPlugin.defaultKeyForType(pluginType)
		
		// clear the previous menu items
		pluginMenu.removeAllItems()
		
		// load the currently selected plugin
		let sel = NSUserDefaults.standardUserDefaults().stringForKey(defaultKey)
		
		// add the menu entries
		for plug in plugins {
			let description = plug.description
			pluginMenu.addItemWithTitle(description)
			
			// make sure the currently selected is set as such
			if let sel = sel where sel == plug.path {
				pluginMenu.selectItemWithTitle(description)
			}
		}
		
		selectPlugin(pluginMenu)
	}
}
