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
#import "TestWALoginResult.h"

#import "AppiumAppDelegate.h"
#import "AppiumPreferencesFile.h"

#import "NSObject+LXDict.h"
//#import "AFNetworking.h"
#import "TestWAHttpExecutor.h"

#define TestWALoginServerAddr [NSString stringWithFormat:@"%@/attp/login",TestWAServerPrefix]

@interface TestWAPreferenceWindowController ()<NSTextFieldDelegate>

@property (weak) IBOutlet NSView *loginView;
@property (weak) IBOutlet NSTextField *userNameField;
@property (weak) IBOutlet NSSecureTextField *pwdFiled;
@property (weak) IBOutlet NSButton *loginButton;
@property (weak) IBOutlet NSView *loginProgressView;
@property (weak) IBOutlet NSTextField *loginMsgLabel;

@property (strong) IBOutlet NSView *logoutView;
@property (weak) IBOutlet NSTextField *userNameLabel;
@property (weak) IBOutlet NSImageView *userIcon;

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
	if (!self.loginView.isHidden && self.loginMsgLabel.stringValue.length > 0) self.loginMsgLabel.stringValue = @"";
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

- (IBAction)clickedOnLogin:(id)sender {
	[self.loginProgressView setHidden:NO];
	NSString *userName = self.userNameField.stringValue;;
	NSString *pwd = self.pwdFiled.stringValue;

	TestWALoginParam *param = [[TestWALoginParam alloc]init];
	param.username = userName;
	param.password = pwd;
	
	[TestWAHttpExecutor postWithUrlStr:TestWALoginServerAddr params:param handleResultBlock:^(id resultData, NSError *error) {
		if (!error) {
			TestWALoginResult *result = [TestWALoginResult objectWithKeyedDict:resultData];
			if ([result.flag isEqualToString:@"success"]) {
				[TestWAAccountTool saveAccount:result.user];
			}
			else{
				self.loginMsgLabel.stringValue = @"用户名或密码错误";
			}
		}
		else{
			self.loginMsgLabel.stringValue = @"连接错误,请检查网络和服务器参数设置";
		}
	}];
	
	[self.loginProgressView setHidden:YES];
	[self setupLogView];
}
#pragma mark - textField delegate
- (void)controlTextDidChange:(NSNotification *)obj
{
	if (self.userNameField.stringValue.length>0 && self.pwdFiled.stringValue.length>0) {
		[self.loginButton setEnabled:YES];
		if (self.loginMsgLabel.stringValue.length > 0) self.loginMsgLabel.stringValue = @"";
	}
	else{
		[self.loginButton setEnabled:NO];
	}
}
- (IBAction)clickedRegister:(id)sender {
	[[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:@"http://123.57.32.84:8008/attp"]];
}
@end
