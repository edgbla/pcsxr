//
//  CheatController.swift
//  Pcsxr
//
//  Created by C.W. Betts on 11/11/14.
//
//

import Cocoa
import SwiftAdditions

let kTempCheatCodesName = "cheatValues"
let kCheatsName = "cheats"

final class CheatController: NSWindowController, NSWindowDelegate {
	var cheats: [CheatObject]
	var cheatValues = [CheatValue]()
	@IBOutlet weak var cheatView: NSTableView!
	@IBOutlet weak var editCheatWindow: NSWindow!
	@IBOutlet weak var editCheatView: NSTableView!
	@IBOutlet weak var addressFormatter: PcsxrHexadecimalFormatter!
	@IBOutlet weak var valueFormatter: PcsxrHexadecimalFormatter!
	
	required init?(coder: NSCoder) {
		cheats = [CheatObject]()
		
		super.init(coder: coder)
	}
	
	override init(window: NSWindow?) {
		cheats = [CheatObject]()
		
		super.init(window: window)
	}
	
	class func newController() -> CheatController {
		let toRet = CheatController(windowNibName: "CheatWindow")
		
		return toRet
	}
	
	override var windowNibName: String {
		return "CheatWindow"
	}
	
	func refresh() {
		cheatView.reloadData()
		refreshCheatArray()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		valueFormatter.hexPadding = 4
		addressFormatter.hexPadding = 8
		refreshCheatArray()
		self.addObserver(self, forKeyPath: kCheatsName, options: [.New, .Old], context: nil)
	}
	
	private func refreshCheatArray() {
		var tmpArray = [CheatObject]()
		for i in 0..<Int(NumCheats) {
			let tmpObj = CheatObject(cheat: Cheats[i])
			tmpArray.append(tmpObj)
		}
		cheats = tmpArray
		setDocumentEdited(false)
	}
	
	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if keyPath == kCheatsName {
			setDocumentEdited(true)
		}
	}
	
	private func reloadCheats() {
		let manager = NSFileManager.defaultManager()
		let tmpURL = (try! manager.URLForDirectory(.ItemReplacementDirectory, inDomain: .UserDomainMask, appropriateForURL: NSBundle.mainBundle().bundleURL, create: true)).URLByAppendingPathComponent("temp.cht", isDirectory: false)
		var tmpStr = ""
		let tmp = cheats.map { (val) -> String in
			return val.description
		}
		tmpStr = tmp.joinWithSeparator("\n")
		do {
			try (tmpStr as NSString).writeToURL(tmpURL, atomically: false, encoding: NSUTF8StringEncoding)
		} catch _ {
			NSBeep()
			return
		}
		LoadCheats(tmpURL.fileSystemRepresentation)
		do {
			try manager.removeItemAtURL(tmpURL)
		} catch _ {
		}
	}
	
	@IBAction func loadCheats(sender: AnyObject?) {
		let openDlg = NSOpenPanel()
		openDlg.allowsMultipleSelection = false
		openDlg.allowedFileTypes = PcsxrCheatHandler.supportedUTIs()
		openDlg.beginSheetModalForWindow(window!, completionHandler: { (retVal) -> Void in
			if retVal == NSFileHandlingPanelOKButton {
				let file = openDlg.URL!
				LoadCheats(file.fileSystemRepresentation)
				self.refresh()
			}
		})
	}
	
	@IBAction func saveCheats(sender: AnyObject?) {
		let saveDlg = NSSavePanel()
		saveDlg.allowedFileTypes = PcsxrCheatHandler.supportedUTIs()
		saveDlg.canSelectHiddenExtension = true
		saveDlg.canCreateDirectories = true
		saveDlg.prompt = NSLocalizedString("Save Cheats", comment: "")
		saveDlg.beginSheetModalForWindow(window!, completionHandler: { (retVal) -> Void in
			if retVal == NSFileHandlingPanelOKButton {
				let url = saveDlg.URL!
				let saveString: NSString = {
					var toRet = ""
					for ss in self.cheats {
						toRet += ss.description + "\n"
					}
					
					return toRet as NSString
					}()
				do {
					//let saveString = (self.cheats as NSArray).componentsJoinedByString("\n") as NSString
					try saveString.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
				} catch _ {
					NSBeep()
				}
			}
		})
	}
	
	@IBAction func clear(sender: AnyObject?) {
		cheats = []
	}
	
	@IBAction func closeCheatEdit(sender: NSButton) {
		window!.endSheet(editCheatWindow, returnCode: sender.tag == 1 ? NSCancelButton : NSOKButton)
	}
	
	@IBAction func changeCheat(sender: AnyObject?) {
		self.setDocumentEdited(true)
	}
	
	@IBAction func removeCheatValue(sender: AnyObject?) {
		if editCheatView.selectedRow < 0 {
			NSBeep()
			return
		}
		
		let toRemoveIndex = editCheatView.selectedRowIndexes
		willChange(.Removal, valuesAtIndexes: toRemoveIndex, forKey: kTempCheatCodesName)
		removeObjects(inArray: &cheatValues, atIndexes: toRemoveIndex)
		didChange(.Removal, valuesAtIndexes: toRemoveIndex, forKey: kTempCheatCodesName)
	}
	
	@IBAction func addCheatValue(sender: AnyObject?) {
		let newSet = NSIndexSet(index: cheatValues.count)
		willChange(.Insertion, valuesAtIndexes: newSet, forKey: kTempCheatCodesName)
		cheatValues.append(CheatValue())
		didChange(.Insertion, valuesAtIndexes: newSet, forKey: kTempCheatCodesName)
	}
	
	
	@IBAction func editCheat(sender: AnyObject?) {
		if cheatView.selectedRow < 0 {
			NSBeep();
			return;
		}
		let tmpArray = cheats[cheatView.selectedRow].values
		let newCheats: [CheatValue] = {
			var tmpCheat = [CheatValue]()
			for che in tmpArray {
				tmpCheat.append(che.copy() as! CheatValue)
			}
			
			return tmpCheat
		}()
		
		cheatValues = newCheats
		editCheatView.reloadData()
		window!.beginSheet(editCheatWindow, completionHandler: { (returnCode) -> Void in
			if returnCode == NSOKButton {
				let tmpCheat = self.cheats[self.cheatView.selectedRow]
				if tmpCheat.values != self.cheatValues {
					tmpCheat.values = self.cheatValues
					self.setDocumentEdited(true)
				}
			}
			self.editCheatWindow.orderOut(nil)
		})
	}
	
	@IBAction func addCheat(sender: AnyObject?) {
		let newSet = NSIndexSet(index: cheats.count)
		willChange(.Insertion, valuesAtIndexes: newSet, forKey: kCheatsName)
		let tmpCheat = CheatObject(name: NSLocalizedString("New Cheat", comment: "New Cheat Name"))
		cheats.append(tmpCheat)
		didChange(.Insertion, valuesAtIndexes: newSet, forKey: kCheatsName)
		setDocumentEdited(true)
	}
	
	@IBAction func applyCheats(sender: AnyObject?) {
		reloadCheats()
		setDocumentEdited(false)
	}
	
	func windowShouldClose(sender: AnyObject) -> Bool {
		if let windSender = sender as? NSWindow where (!windSender.documentEdited || windSender != window) {
			return true
		} else {
			let alert = NSAlert()
			alert.messageText = NSLocalizedString("Unsaved Changes", comment: "Unsaved changes")
			alert.informativeText = NSLocalizedString("The cheat codes have not been applied. Unapplied cheats will not run nor be saved. Do you wish to save?", comment: "")
			alert.addButtonWithTitle(NSLocalizedString("Save", comment: "Save"))
			alert.addButtonWithTitle(NSLocalizedString("Don't Save", comment: "Don't Save"))
			alert.addButtonWithTitle(NSLocalizedString("Cancel", comment:"Cancel"))
			
			alert.beginSheetModalForWindow(window!, completionHandler: { (response) -> Void in
				switch response {
				case NSAlertFirstButtonReturn:
					self.reloadCheats()
					self.close()
					
				case NSAlertThirdButtonReturn:
					break
					
				case NSAlertSecondButtonReturn:
					self.refreshCheatArray()
					self.close()
					
				default:
					break
				}
			})
			return false
		}
	}
	
	@IBAction func removeCheats(sender: AnyObject?) {
		if cheatView.selectedRow < 0 {
			NSBeep()
			return
		}
		
		let toRemoveIndex = cheatView.selectedRowIndexes
		willChange(.Removal, valuesAtIndexes: toRemoveIndex, forKey: kCheatsName)
		removeObjects(inArray: &cheats, atIndexes: toRemoveIndex)
		didChange(.Removal, valuesAtIndexes: toRemoveIndex, forKey: kCheatsName)
		setDocumentEdited(true)
	}
}
