//
//  RecordScriptWindowController.m
//  Appium
//
//  Created by xinliu on 15-1-21.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "RecordScriptWindowController.h"
#import "AppiumAppDelegate.h"
#import "TestWAAccountTool.h"
#import "TestWAPreferenceWindowController.h"

#import "RecordScriptUploadViewController.h"
#import "RecordScriptLocalScriptViewController.h"

@interface RecordScriptWindowController ()

@property (weak) IBOutlet NSButton *loginButton;

@property (weak) IBOutlet NSView *loginView;
@property (weak) IBOutlet NSTextField *userLabel;
@property (weak) IBOutlet NSButton *logoutButton;
@property (weak) IBOutlet NSBox *loginViewSplitLine;

@property BOOL isLogin;

@property (weak) IBOutlet NSTabView *contentTabView;
@property RecordScriptUploadViewController *uploadController;
@property RecordScriptLocalScriptViewController *localScriptController;
@property (weak) IBOutlet NSSegmentedControl *headerSegmentButton;

@end

@implementation RecordScriptWindowController
- (void)loadWindow
{
	[super loadWindow];
	
	[self setupHeaderView];
	[self setupViews];
	[self setupTabItems];
}
- (void)setupTabItems
{
	RecordScriptUploadViewController *uploadController = [[RecordScriptUploadViewController alloc]initWithNibName:@"RecordScriptUploadView" bundle:nil];
	uploadController.recordWindow = self;
	self.uploadController = uploadController;
	
	NSTabViewItem *uploadItem = [[NSTabViewItem alloc]init];
	[uploadItem setView:uploadController.view];
	[self.contentTabView addTabViewItem:uploadItem];
	
	self.localScriptController = [[RecordScriptLocalScriptViewController alloc]initWithNibName:@"RecordScriptLocalScriptMgrView" bundle:nil];
	NSTabViewItem *localScriptItem = [[NSTabViewItem alloc]init];
	[localScriptItem setView:self.localScriptController.view];
	[self.contentTabView addTabViewItem:localScriptItem];
	
	[self.contentTabView removeTabViewItem:[self.contentTabView tabViewItemAtIndex:0]];
	self.headerSegmentButton.selectedSegment = 0;
	self.selectedIndex = self.headerSegmentButton.selectedSegment;
	
}
- (void)windowDidLoad
{
    [super windowDidLoad];
	[self.uploadController updateUserInfo];
}
- (void)setupHeaderView
{
}
- (void)setupViews
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
		logoutBtnF.origin.x = userLabelW + 4.0;
		self.logoutButton.frame = logoutBtnF;
	}
}
- (void)setupUserInfo
{
	[self setupViews];
	
	[self.uploadController updateUserInfo];
}
#pragma mark - switch tab view
- (IBAction)clickedSwitchTabItem:(NSSegmentedControl *)sender {
	self.selectedIndex = sender.selectedSegment;
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
