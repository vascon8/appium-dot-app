//
//  RecordScriptStatusView.h
//  Appium
//
//  Created by xin liu on 15/1/22.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RecordScriptStatusView : NSView

@property (weak) IBOutlet NSTextField *scriptNameTextField;
@property (weak) IBOutlet NSProgressIndicator *uploadProgressIndicator;
@property (weak) IBOutlet NSImageView *statusImageView;

@end
