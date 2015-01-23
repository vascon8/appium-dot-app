//
//  RecordScriptWindowController.h
//  Appium
//
//  Created by xinliu on 15-1-21.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RecordScriptWindowController : NSWindowController

@property (weak) IBOutlet NSTableView *recordscriptAppTableView;
@property (weak) IBOutlet NSView *recordscriptUploadView;

@property (weak) IBOutlet NSTextField *scriptNameTextField;
@property (weak) IBOutlet NSProgressIndicator *uploadProgressIndicator;
@property (weak) IBOutlet NSImageView *statusImageView;
@end
