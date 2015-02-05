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
#import "AFNetworking.h"

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
	
//	TestWAServerUser *temp = [[TestWAServerUser alloc]init];
//	temp.name = userName;
//	temp.id = @"tempID";
//	[TestWAAccountTool saveAccount:temp];
	
	NSString *urlStr = [TestWALoginServerAddr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	urlStr = @"http://1fd0d95b.ngrok.com/attp/client/login?username=%@&password=%@";
	
	NSURL *url = [NSURL URLWithString:urlStr];
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

	[manager POST:@"http://1fd0d95b.ngrok.com/attp/client/login" parameters:[param keyedDictFromModel] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSLog(@"JSON: %@", responseObject);
		TestWALoginResult *result = [TestWALoginResult objectWithKeyedDict:responseObject];
		if ([result.flag isEqualToString:@"success"]) {
			[TestWAAccountTool saveAccount:result.user];
		}
		else{
			self.loginMsgLabel.stringValue = @"用户名或密码错误";
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		self.loginMsgLabel.stringValue = @"连接错误";
	}];
	
//	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
//	[request setHTTPMethod:@"POST"];
//	NSError *error = nil;
//	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[param keyedDictFromModel] options:NSJSONWritingPrettyPrinted error:&error];
//	[request setHTTPBody:jsonData];
////	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
//	
//	NSURLResponse *response = nil;
////	NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//	if (error) {
//		NSLog(@"%@ %@",error,response);
//	}
//	NSLog(@"%@ \n%@",resultData,response);
//	
//	id json = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingAllowFragments error:nil];
//	NSLog(@"%@",json);
//	if (!error) {
//		[TestWAAccountTool saveAccount:json];
//	}
//	else{
//		self.loginMsgLabel.stringValue = @"用户名或密码错误";
//	}
	
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
