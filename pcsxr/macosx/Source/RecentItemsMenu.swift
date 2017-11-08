//
//  RecentItemsMenu.swift
//  Pcsxr
//
//  Created by C.W. Betts on 1/18/15.
//
//

import Cocoa

final class RecentItemsMenu: NSMenu {
	@IBOutlet weak var pcsxr: PcsxrController! = nil
	
	/// Initialization
	override func awakeFromNib() {
		super.awakeFromNib()
		
		autoenablesItems = true
		
		// Populate the menu
		let recentDocuments = NSDocumentController.shared.recentDocumentURLs
		for (i, url) in recentDocuments.enumerated() {
			let tempItem = newMenuItem(url)
			addMenuItem(tempItem, index: i)
		}
	}
	
	private func addMenuItem(_ item: NSMenuItem, index: Int = 0) {
		insertItem(item, at: index)
		
		// Prevent menu from overflowing; the -2 accounts for the "Clear..." and the separator items
		let maxNumItems = NSDocumentController.shared.maximumRecentDocumentCount
		if numberOfItems - 2 > maxNumItems {
			removeItem(at: maxNumItems)
		}
	}
	
	private func newMenuItem(_ documentURL: URL) -> NSMenuItem {
		let documentPath = documentURL.path
		let lastName = FileManager.default.displayName(atPath: documentPath)
		let fileImage = NSWorkspace.shared.icon(forFile: documentPath)
		fileImage.size = NSSize(width: 16, height: 16)
		
		let newItem = NSMenuItem(title: lastName, action: #selector(RecentItemsMenu.openRecentItem(_:)), keyEquivalent: "")
		newItem.representedObject = documentURL
		newItem.image = fileImage
		newItem.target = self
		
		return newItem
	}
	
	@objc func addRecentItem(_ documentURL: URL) {
		NSDocumentController.shared.noteNewRecentDocumentURL(documentURL)
		
		if let item = findMenuItem(by: documentURL) {
			removeItem(item)
			insertItem(item, at: 0)
		} else {
			addMenuItem(newMenuItem(documentURL))
		}
	}
	
	private func findMenuItem(by url: URL) -> NSMenuItem? {
		for item in items {
			if let repItem = item.representedObject as? URL, repItem == url {
				return item
			}
		}
		
		return nil
	}
	
	@objc private func openRecentItem(_ sender: NSMenuItem) {
		if let url = sender.representedObject as? URL {
			addRecentItem(url)
			pcsxr.run(url)
		}
	}
	
	@IBAction func clearRecentDocuments(_ sender: AnyObject?) {
		removeDocumentItems()
		NSDocumentController.shared.clearRecentDocuments(sender)
	}
	
	// Document items are menu items with tag 0
	private func removeDocumentItems() {
		var removeItemsArray = [NSMenuItem]()
		for item in items {
			if item.tag == 0 {
				removeItemsArray.append(item)
			}
		}
		
		for item in removeItemsArray {
			removeItem(item)
		}
	}
}
