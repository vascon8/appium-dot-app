//
//  TestWAPreferenceWindowController.h
//  Appium
//
//  Created by xinliu on 15-2-1.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define TestWALoginServerAddr @"login"

@interface TestWAPreferenceWindowController : NSWindowController

@property (weak) IBOutlet NSView *loginView;
@property (weak) IBOutlet NSTextField *userNameField;
@property (weak) IBOutlet NSSecureTextField *pwdFiled;

@property (strong) IBOutlet NSView *logoutView;

- (BOOL)loginHandle;

@end
