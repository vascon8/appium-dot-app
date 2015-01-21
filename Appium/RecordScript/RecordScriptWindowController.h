//
//  RecordScriptWindowController.h
//  Appium
//
//  Created by xinliu on 15-1-21.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RecordScriptWindowController : NSWindowController
@property (weak) IBOutlet NSButton *checkBox;
@property (weak) IBOutlet NSTextField *appNameField;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@end
