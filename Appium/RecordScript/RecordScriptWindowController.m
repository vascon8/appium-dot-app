//
//  RecordScriptWindowController.m
//  Appium
//
//  Created by xinliu on 15-1-21.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "RecordScriptWindowController.h"
//#import "AppiumPreferencesFile.h"

//#import "RecordscriptApp.h"
//#import "RecordScriptUploadParam.h"

//#import "NSObject+LXDict.h"
//#import "TestWAHttpExecutor.h"

//#import "RecordScriptUploadResultViewController.h"
//#import "RecordScriptUploadResult.h"
//#import "TestWAPrjOutlineViewDataSource.h"

//#import "TestWAServerUser.h"
//#import "TestWAServerProject.h"

#import "AppiumAppDelegate.h"
#import "TestWAAccountTool.h"
#import "TestWAPreferenceWindowController.h"
#import "RecordScriptUploadViewController.h"

@interface RecordScriptWindowController ()

@property (weak) IBOutlet NSButton *loginButton;

@property (weak) IBOutlet NSView *loginView;
@property (weak) IBOutlet NSTextField *userLabel;
@property (weak) IBOutlet NSButton *logoutButton;
@property (weak) IBOutlet NSBox *loginViewSplitLine;

@property BOOL isLogin;

@property (weak) IBOutlet NSTabView *contentTabView;
@property RecordScriptUploadViewController *uploadController;

@end

@implementation RecordScriptWindowController
- (id)initWithWindowNibName:(NSString *)windowNibName
{
	self = [super initWithWindowNibName:windowNibName];
	if (self) {	}
	return self;
}
- (void)loadWindow
{
	[super loadWindow];
	
	RecordScriptUploadViewController *uploadController = [[RecordScriptUploadViewController alloc]initWithNibName:@"RecordScriptUploadView" bundle:nil];
	uploadController.recordWindow = self;
	self.uploadController = uploadController;
	
	self.selectedIndex = 0;
	NSTabViewItem *uploadItem = [self.contentTabView.tabViewItems objectAtIndex:0];
	[uploadItem setView:uploadController.view];
	[self.contentTabView addTabViewItem:uploadItem];
	
	
}
- (void)windowDidLoad
{
    [super windowDidLoad];
	[self setupViews];
}
- (void)setupViews
{
	[self setupUserInfo];
}
- (void)setupUserInfo
{
	self.isLogin = [TestWAAccountTool isLogin];
	
	[self.loginButton setHidden:self.isLogin];
	[self.loginView setHidden:!self.isLogin];
	
	if (_isLogin) {
		self.userLabel.stringValue = [TestWAAccountTool loginUserName];
		
		[self.userLabel sizeToFit];
		[self.logoutButton sizeToFit];
		CGFloat userLabelW = self.userLabel.frame.size.width;
		
		NSRect splitLineF = self.loginViewSplitLine.frame;
		splitLineF.size.height = self.userLabel.frame.size.height;
		splitLineF.origin.x = userLabelW;
		self.loginViewSplitLine.frame = splitLineF;
		
		NSRect logoutBtnF = self.logoutButton.frame;
		logoutBtnF.origin.x = userLabelW + 2.0;
		self.logoutButton.frame = logoutBtnF;
	}
}

#pragma mark - login
- (IBAction)clickedLogin:(id)sender {
	if (!self.isLogin) {
		[[self appDelegate]displayPreferenceWindow:nil];
	}
}
- (void)logStateDidChanged:(NSNotification *)notification
{
	[self setupUserInfo];
}
- (IBAction)clickedLogout:(id)sender {
	if (self.isLogin) {
		[TestWAAccountTool logout];
		[self setupUserInfo];
	}
}

#pragma mark - private
- (AppiumAppDelegate *)appDelegate
{
	return [NSApplication sharedApplication].delegate;
}
@end
