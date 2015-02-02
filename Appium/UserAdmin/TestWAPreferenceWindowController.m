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

@interface TestWAPreferenceWindowController ()<NSTextFieldDelegate>

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
}
- (BOOL)loginHandle
{
	return NO;
}
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	NSLog(@"%@",fieldEditor);
	NSLog(@"%@",control);
	if (fieldEditor == self.userNameField) {
		
		[self.pwdFiled becomeFirstResponder];
	}
	return YES;
}
- (IBAction)clickedOnLogin:(id)sender {
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

@end
