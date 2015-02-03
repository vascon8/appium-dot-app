//
//  TestWAPreferenceWindowController.m
//  Appium
//
//  Created by xinliu on 15-2-1.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "TestWAPreferenceWindowController.h"

#import "TestWALoginParam.h"
#import "TestWAAccountTool.h"

#import "TestWAServerUser.h"

#import "AppiumAppDelegate.h"

@interface TestWAPreferenceWindowController ()<NSTextFieldDelegate>

@property BOOL isLogin;

@end

@implementation TestWAPreferenceWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	[self setupLogView];
}
- (void)setupLogView
{
	self.isLogin = [TestWAAccountTool isLogin];
	[self.loginView setHidden:self.isLogin];
	[self.logoutView setHidden:!self.isLogin];
	
	if (!self.loginView.isHidden) {
		self.pwdFiled.stringValue = @"";
		[self controlTextDidChange:nil];
	}
	if (!self.logoutView.isHidden) {
		self.userNameLabel.stringValue = [TestWAAccountTool loginUserName];
	}
	
	[[NSNotificationCenter defaultCenter]postNotificationName:TestWALogStateDidChangedNotification object:self userInfo:nil];
}
- (IBAction)logout:(id)sender {
	[TestWAAccountTool clearAccountRecord];
	[self setupLogView];
}

- (BOOL)loginHandle
{
	return NO;
}

- (IBAction)clickedOnLogin:(id)sender {
	[self.loginProgressView setHidden:NO];
	NSString *userName = self.userNameField.stringValue;;
	NSString *pwd = self.pwdFiled.stringValue;
	if (!userName || !pwd) {
		
	}

	TestWALoginParam *param = [[TestWALoginParam alloc]init];
	param.userName = userName;
	param.password = pwd;
	
	TestWAServerUser *temp = [[TestWAServerUser alloc]init];
	temp.name = userName;
	temp.id = @"tempID";
	[TestWAAccountTool saveAccount:temp];
	
	[self.loginProgressView setHidden:YES];
	[self setupLogView];
	
//	NSString *urlStr = [TestWALoginServerAddr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//	NSURL *url = [NSURL URLWithString:urlStr];
//	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
//	NSError *error = nil;
//	NSURLResponse *response = nil;
//	NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//	
//	TestWAServerUser *user = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingAllowFragments error:nil][@"user"];
//	if (!error) {
//		[TestWAAccountTool saveAccount:user];
//	}
//	else{
//		
//	}
	
}
#pragma mark - textField delegate
- (void)controlTextDidChange:(NSNotification *)obj
{
	if (self.userNameField.stringValue.length>0 && self.pwdFiled.stringValue.length>0) {
		[self.loginButton setEnabled:YES];
	}
	else{
		[self.loginButton setEnabled:NO];
	}
}
@end
