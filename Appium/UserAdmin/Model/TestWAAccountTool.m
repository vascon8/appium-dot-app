//
//  TestWAAccountTool.m
//  Appium
//
//  Created by xinliu on 15-2-2.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "TestWAAccountTool.h"

@implementation TestWAAccountTool
#pragma mark - public
+ (void)saveAccount:(TestWAServerUser *)user
{
	if (!user.name || !user.id) {
		return;
	}
	[NSKeyedArchiver archiveRootObject:user toFile:[self userinfoFile]];
	NSLog(@"%@",[self userinfoFile]);
}
+ (TestWAServerUser *)requestAccount
{
	TestWAServerUser *user = [NSKeyedUnarchiver unarchiveObjectWithFile:[self userinfoFile]];
	if (!user || [user.expireDate compare:[NSDate date]] == NSOrderedAscending) {
		return nil;
	}
	return user;
}
+ (NSString *)loginUserName
{
	TestWAServerUser *user = [self requestAccount];
	if (user) return user.name;
	else return nil;
}
+ (BOOL)isLogin
{
	if([self requestAccount]) return YES;
	else return NO;
}
+ (void)clearAccountRecord
{
	NSError *error = nil;
	[[NSFileManager defaultManager]removeItemAtPath:[self userinfoFile] error:&error];
	if (error) {
		NSLog(@"remove user error:%@",error);
	}
}
#pragma mark - userinfo file
+ (NSString *)userinfoFile
{
	NSString *docDir = [[NSBundle mainBundle] resourcePath];
	NSString *file = [docDir stringByAppendingPathComponent:@"user.info"];
	
	return file;
}
@end
