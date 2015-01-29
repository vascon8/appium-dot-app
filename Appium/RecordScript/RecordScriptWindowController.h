//
//  RecordScriptWindowController.h
//  Appium
//
//  Created by xinliu on 15-1-21.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RecordScriptWindowController : NSWindowController

@property (weak) IBOutlet NSTableView *appInfoTableView;
@property (weak) IBOutlet NSButton *appInfoRefreshButton;
@property (weak) IBOutlet NSProgressIndicator *loadAppProgressIndicator;

@property (weak) IBOutlet NSView *scriptInfoView;
@property (weak) IBOutlet NSView *chooseUploadView;

@property (weak) IBOutlet NSButton *firstChooseScriptButton;

@property (weak) IBOutlet NSTableView *uploadResultView;

@property (weak) IBOutlet NSButton *chooseScriptButton;

@end
