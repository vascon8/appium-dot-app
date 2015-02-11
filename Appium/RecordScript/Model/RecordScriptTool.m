//
//  RecordScriptTool.m
//  Appium
//
//  Created by xinliu on 15-2-10.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "RecordScriptTool.h"

@implementation RecordScriptTool
+ (RecordScriptModel *)recordScriptWithName:(NSString *)scriptName{
	RecordScriptModel *model = [[RecordScriptModel alloc]init];
	
	NSString *language = nil;
	NSString *commandStr = nil;
	
	NSRange range = [scriptName rangeOfString:@"." options:NSBackwardsSearch];
	if (range.length > 0) {
		NSString *ext = [scriptName substringFromIndex:range.location+1];
		if ([ext isEqualToString:@"py"]) {
			language = @"Python";
			commandStr = @"/usr/bin/python";
		}
		else if ([ext isEqualToString:@"js"]){
			language = @"node.js";
			NSString *nodeRootPath = [[NSBundle mainBundle] resourcePath];
			commandStr = [NSString stringWithFormat:@"%@/node/bin/node",nodeRootPath];
		}
		else if ([ext isEqualToString:@"rb"]){
			language = @"Ruby";
			commandStr = @"/usr/bin/ruby";
		}
		else if ([ext isEqualToString:@"cs"]){
			language = @"C#";
		}
		else if ([ext isEqualToString:@"java"]){
			language = @"Java";
		}
		else if ([ext isEqualToString:@"m"]){
			language = @"Objective-C";
		}
	}
	
	model.language = language;
	model.commadStr = commandStr;
	return model;
}
+ (NSString *)scriptLanguage:(NSString *)scriptName
{
	NSString *language = nil;
	NSString *commandStr = nil;
	
	NSRange range = [scriptName rangeOfString:@"." options:NSBackwardsSearch];
	if (range.length > 0) {
		NSString *ext = [scriptName substringFromIndex:range.location+1];
		if ([ext isEqualToString:@"py"]) {
			language = @"Python";
		}
		else if ([ext isEqualToString:@"js"]){
			language = @"node.js";
		}
		else if ([ext isEqualToString:@"rb"]){
			language = @"Ruby";
		}
		else if ([ext isEqualToString:@"cs"]){
			language = @"C#";
		}
		else if ([ext isEqualToString:@"java"]){
			language = @"Java";
		}
		else if ([ext isEqualToString:@"m"]){
			language = @"Objective-C";
		}
	}
	
	return language;
}
@end
