//
//  RecentItemsMenu.swift
//  Pcsxr
//
//  Created by C.W. Betts on 1/18/15.
//
//

import Cocoa

private func NSDocumentSharedController() -> NSDocumentController {
	return NSDocumentController.sharedDocumentController()
}

final class RecentItemsMenu: NSMenu {
	@IBOutlet weak var pcsxr: PcsxrController! = nil
	
	/// Initialization
	override func awakeFromNib() {
		super.awakeFromNib()
		
		autoenablesItems = true
		
		// Populate the menu
		let recentDocuments = NSDocumentSharedController().recentDocumentURLs
		for (i, url) in recentDocuments.enumerate() {
			let tempItem = newMenuItem(url)
			addMenuItem(tempItem, index: i)
		}
	}
	
	private func addMenuItem(item: NSMenuItem, index: Int = 0) {
		insertItem(item, atIndex: index)
		
		// Prevent menu from overflowing; the -2 accounts for the "Clear..." and the separator items
		let maxNumItems = NSDocumentSharedController().maximumRecentDocumentCount
		if numberOfItems - 2 > maxNumItems {
			removeItemAtIndex(maxNumItems)
		}
	}
	
	private func newMenuItem(documentURL: NSURL) -> NSMenuItem {
		let documentPath = documentURL.path!
		let lastName = NSFileManager.defaultManager().displayNameAtPath(documentPath)
		let fileImage = NSWorkspace.sharedWorkspace().iconForFile(documentPath)
		fileImage.size = NSSize(width: 16, height: 16)
		
		let newItem = NSMenuItem(title: lastName, action: #selector(RecentItemsMenu.openRecentItem(_:)), keyEquivalent: "")
		newItem.representedObject = documentURL
		newItem.image = fileImage
		newItem.target = self
		
		return newItem
	}
	
	func addRecentItem(documentURL: NSURL) {
		NSDocumentSharedController().noteNewRecentDocumentURL(documentURL)
		
		if let item = findMenuItemByURL(documentURL) {
			removeItem(item)
			insertItem(item, atIndex: 0)
		} else {
			addMenuItem(newMenuItem(documentURL))
		}
	}
	
	private func findMenuItemByURL(url: NSURL) -> NSMenuItem? {
		for item in itemArray {
			if let repItem = item.representedObject as? NSURL where repItem == url {
				return item
			}
		}
		
		return nil
	}
	
	@objc private func openRecentItem(sender: NSMenuItem) {
		if let url = sender.representedObject as? NSURL {
			addRecentItem(url)
			pcsxr.runURL(url)
		}
	}
	
	@IBAction func clearRecentDocuments(sender: AnyObject?) {
		removeDocumentItems()
		NSDocumentSharedController().clearRecentDocuments(sender)
	}
	
	// Document items are menu items with tag 0
	private func removeDocumentItems() {
		var removeItemsArray = [NSMenuItem]()
		for item in itemArray as [NSMenuItem] {
			if item.tag == 0 {
				removeItemsArray.append(item)
			}
		}
		
		for item in removeItemsArray {
			removeItem(item)
		}
	}
}
