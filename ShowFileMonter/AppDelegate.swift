//
//  AppDelegate.swift
//  ShowFileMonter
//
//  Created by Nattapong Pullkhow on 11/29/2557 BE.
//  Copyright (c) 2557 Nattapong Pullkhow. All rights reserved.
//

import Cocoa
import Foundation
import Appkit

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet var window: NSWindow
    @IBAction func setQuit(sender : AnyObject) {
        if (window.visible) {
            window.orderOut(window)
        } else if (MainWindow.visible) {
            NSApplication.sharedApplication().terminate(self)
        }
    }

    @IBAction func ShowAboutWindow(sender : AnyObject) {
        if !(self.window.visible) {
            self.window.orderFront(window)
            self.WindowTab.selectTabViewItemAtIndex(1)
        }
    }
    @IBOutlet var WindowTab : NSTabView
    
    @IBAction func ShowPrefWindow(sender : AnyObject) {
        SettingsBTNClick_(self)
    }
    @IBOutlet var MainWindow : NSPanel
    @IBOutlet var SettingsBTN : NSButton
    @IBOutlet var SettingsTEXT : NSTextField
    @IBAction func SettingsBTNClick_(sender : AnyObject) {
        var Config = config()
        if(!self.window.visible) {
            if(Config.getBoolKey("statusbar")) {
                PrefShowStatusCheck.state = 1
            } else  {
                PrefShowStatusCheck.state = 0
            }
            
            VersionTEXT.stringValue = "Version \(Version.Main()) build \(Version.Build())"
            self.window.orderFront(window)
        }
    }
   
    @IBOutlet var ToggleFileBTN : NSButton
    @IBOutlet var ToggleFileTEXT : NSTextField
    @IBAction func ToggleFileBTNClick_(sender : AnyObject) {
        toggleState(self)
    }
    
    @IBOutlet var VersionTEXT : NSTextField
    
    @IBOutlet var PrefShowStatusCheck : NSButton
    @IBAction func PrefShowStatusCheckClick_(sender : AnyObject) {
        var Config = config()
        var oldState = Config.getBoolKey("statusbar")
        var stat:Bool = Config.AnyToBool(PrefShowStatusCheck.state)
        Config.setBoolKey("statusbar", Setting: stat)
        if(!oldState && Config.getBoolKey("statusbar")) {
            statusBarAddAllItems()
        } else if (oldState && !Config.getBoolKey("statusbar")) {
            statusBarClearMenuItems()
        }
    }
    
    var fileBar = NSStatusBar.systemStatusBar()
    var fileToggleBTN : NSStatusItem = NSStatusItem()

    func statusBarAddAllItems() {
        var Config = config()
        if(Config.getBoolKey("statusbar")) {
            if (state()) {
                fileToggleBTN = fileBar.statusItemWithLength(-1)
                let iconHideFile = NSImage(named: "hidefileStatus")
                iconHideFile.setTemplate(true)
                fileToggleBTN.image = iconHideFile
                fileToggleBTN.toolTip = "Hide Hidden File"
                fileToggleBTN.action = Selector("toggleState:")
            } else {
                fileToggleBTN = fileBar.statusItemWithLength(-1)
                let iconShowFile = NSImage(named: "showfileStatus")
                iconShowFile.setTemplate(true)
                fileToggleBTN.image = iconShowFile
                fileToggleBTN.toolTip = "Show Hidden File"
                fileToggleBTN.action = Selector("toggleState:")
            }
        }
    }
    func statusBarSwitchState() {
        var Config = config()
        if(Config.getBoolKey("statusbar")) {
            if(state()) {
                let iconHideFile = NSImage(named: "hidefileStatus")
                iconHideFile.setTemplate(true)
                fileToggleBTN.image = iconHideFile
                fileToggleBTN.toolTip = "Hide Hidden File"
            } else {
                let iconShowFile = NSImage(named: "showfileStatus")
                iconShowFile.setTemplate(true)
                fileToggleBTN.image = iconShowFile
                fileToggleBTN.toolTip = "Show Hidden File"
            }
        }
    }
    func statusBarClearMenuItems() {
        var Config = config()
        if(!Config.getBoolKey("statusbar")) {
            fileBar.removeStatusItem(fileToggleBTN)
        }
    }

    func state()->Bool {
        var task = NSTask()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["read","com.apple.finder","AppleShowAllFiles"]
        let _pipe = NSPipe()
        task.standardOutput = _pipe
        task.launch()
        let pipe = _pipe.fileHandleForReading.readDataToEndOfFile()
        let output:String = "\(removeWhiteSpace(NSString(data: pipe,encoding: NSUTF8StringEncoding)))".lowercaseString
        var showKey = "true 1 show yes"
        if (showKey.rangeOfString(output)) { return true } else { return false }
        }
    func toggleState(sender : AnyObject) {
        var Config = config()
        if(state()) {
            Hide()
            if(Config.getBoolKey("statusbar")) {
                let iconShowFile = NSImage(named: "showfileStatus")
                iconShowFile.setTemplate(true)
                fileToggleBTN.image = iconShowFile
                fileToggleBTN.toolTip = "Show Hidden File"
            }
            if(self.MainWindow.visible) {
                ToggleFileTEXT.stringValue = "Show Hidden File"
                let actionIcon = NSImage(named: "showfile")
                ToggleFileBTN.image = actionIcon
            }
        } else {
            Show()
            if(Config.getBoolKey("statusbar")) {
                let iconHideFile = NSImage(named: "hidefileStatus")
                iconHideFile.setTemplate(true)
                fileToggleBTN.image = iconHideFile
                fileToggleBTN.toolTip = "Hide Hidden File"
            }
            if(self.MainWindow.visible) {
                ToggleFileTEXT.stringValue = "Hide Hidden File"
                let actionIcon = NSImage(named: "hidefile")
                ToggleFileBTN.image = actionIcon
            }
        }
    }
    func Hide() {
        var task = NSTask()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["write","com.apple.finder","AppleShowAllFiles","False"]
        let _pipe = NSPipe()
        task.standardOutput = _pipe
        task.launch()
        KillFinder()
    }
    func KillFinder() {
        var task = NSTask()
        task.launchPath = "/usr/bin/killall"
        task.arguments = ["Finder"]
        let _pipe = NSPipe()
        task.standardOutput = _pipe
        task.launch()
    }
    func Show() {
        var task = NSTask()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["write","com.apple.finder","AppleShowAllFiles","True"]
        let _pipe = NSPipe()
        task.standardOutput = _pipe
        task.launch()
        KillFinder()
    }
    func switchState() {
        if(state()) {
            ToggleFileTEXT.stringValue = "Hide Hidden File"
            let actionIcon = NSImage(named: "hidefile")
            ToggleFileBTN.image = actionIcon
        } else {
            ToggleFileTEXT.stringValue = "Show Hidden File"
            let actionIcon = NSImage(named: "showfile")
            ToggleFileBTN.image = actionIcon
        }
    }

    func removeWhiteSpace(string_:String) ->String {
        let text = string_.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!$0.isEmpty})
        return " ".join(text)
    }
    class Version {
        class func Main()->String {
            let version: AnyObject? = NSBundle.mainBundle().infoDictionary["CFBundleShortVersionString"]
            return version as String
        }
        class func Build()->String {
            let build: AnyObject? = NSBundle.mainBundle().infoDictionary["CFBundleVersion"]
            return build as String
        }
    }
    
    class DragView: NSView,NSDraggingDestination {
    
        init(frame: NSRect) {
            super.init(frame:frame)
            let types = [NSFilenamesPboardType]
            registerForDraggedTypes(types)
            println(self.registerForDraggedTypes)
        }
        override func drawRect(dirtyRect: NSRect)  {
            super.drawRect(dirtyRect)
            NSColor.whiteColor().set()
            NSRectFill(dirtyRect)
        }
        override func draggingEntered(sender: NSDraggingInfo!) -> NSDragOperation {
            println("hello")
            return NSDragOperation.Copy
        }
    }
    
    class config {
        var UserFolderPath:NSString { return NSHomeDirectory() + "/Library/Application Support/ShowFileMonter/" }
        var UserFilePath:NSString { return "\(UserFolderPath)config.plist" }
        var OriginFilePath:NSString { return NSBundle.mainBundle().pathForResource("config", ofType: "plist") }
        var FManager = NSFileManager.defaultManager()
        var FilePath:NSString {
        if (ExistsConfigFile()) {
            return self.UserFilePath
        } else {
            return self.OriginFilePath
            }
        }
        
        func ExistsConfigFile() ->Bool {
            if (self.FManager.fileExistsAtPath( self.UserFolderPath ) && self.FManager.fileExistsAtPath( self.UserFilePath )) {
                return true
            } else {
                if (!self.FManager.fileExistsAtPath( self.UserFolderPath )) {
                    self.FManager.createDirectoryAtPath(self.UserFolderPath, attributes: nil)
                }
                
                if (!self.FManager.fileExistsAtPath( self.UserFilePath )) {
                    self.FManager.copyItemAtPath(self.OriginFilePath, toPath: self.UserFilePath, error: nil)
                }
                if (self.FManager.fileExistsAtPath( self.UserFolderPath ) && self.FManager.fileExistsAtPath( self.UserFilePath )) {
                    return true
                } else {
                    return false
                }
            }
        }
        
        func listKey() ->NSMutableDictionary {
            var dict = NSMutableDictionary()
            if(ExistsConfigFile()) {
                var allConfigKey:Dictionary = NSDictionary(contentsOfFile: self.FilePath)
                for (key_,val_ : AnyObject) in allConfigKey {
                    dict.setValue(val_, forKey: "\(key_)")
                }
            }
            return dict
        }
        
        func getKey(ConfigKey:NSString) ->AnyObject{
            var all_ = NSMutableDictionary(contentsOfFile: self.FilePath)
            for (key_ : AnyObject ,val_ : AnyObject) in all_ {
                if ("\(ConfigKey)" == "\(key_)") {
                    return val_
                }
            }
            return 1
        }
        func getIntKey(ConfigKey:NSString) ->Int{
            var all_ = NSMutableDictionary(contentsOfFile: self.FilePath)
            for (key_ : AnyObject ,val_ : AnyObject) in all_ {
                if ("\(ConfigKey)" == "\(key_)") {
                    return AnyToInt(val_)
                }
            }
            return 1
        }
        func getStrKey(ConfigKey:NSString) ->String{
            var all_ = NSMutableDictionary(contentsOfFile: self.FilePath)
            for (key_ : AnyObject ,val_ : AnyObject) in all_ {
                if ("\(ConfigKey)" == "\(key_)") {
                    return AnyToString(val_)
                }
            }
            return "1"
        }
        func getBoolKey(ConfigKey:NSString) ->Bool{
            var all_ = NSMutableDictionary(contentsOfFile: self.FilePath)
            for (key_ : AnyObject ,val_ : AnyObject) in all_ {
                if ("\(ConfigKey)" == "\(key_)") {
                    return AnyToBool(val_)
                }
            }
            return false
        }
        
        func setKey(ConfigKey:String,Setting:Int) {
            if (!ConfigKey.isEmpty && Setting != nil && ExistsConfigFile()) {
                var DicAllConfigKey = listKey()
                DicAllConfigKey.setValue(Setting, forKey: "\(ConfigKey)")
                DicAllConfigKey.writeToFile(FilePath, atomically: true)
            }
        }
        func setIntKey(ConfigKey:String,Setting:Int) {
            if (!ConfigKey.isEmpty && Setting != nil && ExistsConfigFile()) {
                var DicAllConfigKey = listKey()
                DicAllConfigKey.setValue(Setting, forKey: "\(ConfigKey)")
                DicAllConfigKey.writeToFile(FilePath, atomically: true)
            }
        }
        func setStrKey(ConfigKey:String,Setting:String) {
            if (!ConfigKey.isEmpty && Setting != nil && ExistsConfigFile()) {
                var DicAllConfigKey = listKey()
                DicAllConfigKey.setValue("\(Setting)", forKey: "\(ConfigKey)")
                DicAllConfigKey.writeToFile(FilePath, atomically: true)
            }
        }
        func setBoolKey(ConfigKey:String,Setting:Bool) {
            if (!ConfigKey.isEmpty && Setting != nil && ExistsConfigFile()) {
                var DicAllConfigKey = listKey()
                DicAllConfigKey.setValue(Setting, forKey: "\(ConfigKey)")
                DicAllConfigKey.writeToFile(FilePath, atomically: true)
            }
        }
        func AnyToString(Object_:AnyObject)->String {
            var tmpVal : NSObject = Object_ as NSObject
            var tmpObject_:String = "\(tmpVal)"
            return "\(tmpObject_)"
        }
        func AnyToInt(Object_:AnyObject)->Int {
            var tmpVal : NSObject = Object_ as NSObject
            var tmpObject_:String = "\(tmpVal)"
            var tmpObjectInt_:Int = tmpObject_.toInt()!
            return tmpObjectInt_
        }
        func AnyToBool(Object_:AnyObject)->Bool {
            var tmpVal : NSObject = Object_ as NSObject
            var tmpObject_:String = "\(tmpVal)"
            if (tmpObject_ == "true" || tmpObject_ == "1") {
                return true
            }
            return false
        }
    }
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        switchState()
        statusBarAddAllItems()
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }


}

