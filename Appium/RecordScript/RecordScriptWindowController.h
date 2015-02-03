//
//  RecordScriptWindowController.h
//  Appium
//
//  Created by xinliu on 15-1-21.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppiumPreferencesFile.h"

//#define RecordscriptGetServerAppAddress @"http://192.168.1.100:8008/attp/ajax/allApps"
//#define RecordscriptUploadServerAddress @"http://192.168.1.100:8008/attp/upload"
//#define RecordscriptGetServerUser @"http://192.168.1.100:8008/attp/ajax/allAdmin"
//#define RecordscriptGetServerProjectAddress @"http://192.168.1.100:8008/attp/projects/13"

#define MaxConcurrentUploadOperation 5

@interface RecordScriptWindowController : NSWindowController

@property (weak) IBOutlet NSTableView *appInfoTableView;
@property (weak) IBOutlet NSButton *appInfoRefreshButton;
@property (weak) IBOutlet NSProgressIndicator *appLoadProgressIndicator;

@property (weak) IBOutlet NSButton *scriptAddButton;
@property (weak) IBOutlet NSButton *scriptFistAddButton;

@property (weak) IBOutlet NSButton *loginButton;
@property (weak) IBOutlet NSTextField *userLabel;

- (void)logStateDidChanged:(NSNotification *)notification;

@end
