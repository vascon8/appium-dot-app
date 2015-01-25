//
//  RecordScriptWindowController.h
//  Appium
//
//  Created by xinliu on 15-1-21.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define RecordscriptGetServerAppAddress @"http://192.168.1.100:8008/attp/ajax/allApps"
#define RecordscriptUploadServerAddress @"http://192.168.1.100:8008/attp/upload"

@interface RecordScriptWindowController : NSWindowController

@property (weak) IBOutlet NSTableView *recordscriptAppTableView;
@property (weak) IBOutlet NSView *recordscriptUploadView;

@property (weak) IBOutlet NSTextField *scriptNameTextField;
@property (weak) IBOutlet NSProgressIndicator *uploadProgressIndicator;
@property (weak) IBOutlet NSImageView *statusImageView;

@property (weak) IBOutlet NSButton *chooseScriptButton;
@property (weak) IBOutlet NSButton *customviewChooseScriptButton;

@property (weak) IBOutlet NSProgressIndicator *loadDataProgressIndicator;
@property (weak) IBOutlet NSButton *refreshAppListButton;

@end
