//
//  RecordScriptWindowController.h
//  Appium
//
//  Created by xinliu on 15-1-21.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppiumPreferencesFile.h"

#define RecordscriptGetServerAppAddress [NSString stringWithFormat:@"%@:%@/attp/ajax/allApps",APPIUM_PLIST_TestWA_ServerAddress,APPIUM_PLIST_TestWA_ServerPort]
#define RecordscriptUploadServerAddress [NSString stringWithFormat:@"%@:%@/attp/upload",APPIUM_PLIST_TestWA_ServerAddress,APPIUM_PLIST_TestWA_ServerPort]
#define RecordscriptGetServerUser [NSString stringWithFormat:@"%@:%@/attp/ajax/allAdmin",APPIUM_PLIST_TestWA_ServerAddress,APPIUM_PLIST_TestWA_ServerPort]
#define RecordscriptGetServerProjectAddress [NSString stringWithFormat:@"%@:%@/attp/projects",APPIUM_PLIST_TestWA_ServerAddress,APPIUM_PLIST_TestWA_ServerPort]

#define MaxConcurrentUploadOperation 5

@interface RecordScriptWindowController : NSWindowController

@property (weak) IBOutlet NSTableView *appInfoTableView;
@property (weak) IBOutlet NSButton *appInfoRefreshButton;
@property (weak) IBOutlet NSProgressIndicator *appLoadProgressIndicator;

@property (weak) IBOutlet NSButton *scriptAddButton;
@property (weak) IBOutlet NSButton *scriptFistAddButton;

@end
