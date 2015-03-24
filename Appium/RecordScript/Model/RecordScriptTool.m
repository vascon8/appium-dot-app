//
//  RecordScriptTool.m
//  Appium
//
//  Created by xinliu on 15-2-10.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "RecordScriptTool.h"

#import "AppiumAppDelegate.h"

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
		else{
			language = nil;
		}
	}
	
	model.language = language;
	model.commadStr = commandStr;
	
	return model;
}
+ (void)runScript:(NSString *)scriptPath
{
	NSString *scriptName = [scriptPath lastPathComponent];
	RecordScriptModel *scriptModel = [self recordScriptWithName:scriptName];
	if ([scriptModel.language isEqualTo:@"Python"] || [scriptModel.language isEqualTo:@"node.js"] || [scriptModel.language isEqualTo:@"Ruby"]) {
		
		AppiumAppDelegate *appDelegate = [self appDelegate];
		AppiumModel *appModel = appDelegate.model;
		
		if (appDelegate.inspectorWindow.driver) [appDelegate.inspectorWindow.driver quit];
		if (appDelegate.inspectorWindow.window) [appDelegate.inspectorWindow.window close];
		
		BOOL isServerRunning = appModel.isServerRunning;
		
		if (!isServerRunning) {
			isServerRunning = [appModel startServer];
			if (!isServerRunning) {
				NSLog(@"can't start server");
				return;
			}
		}
		
		BOOL canRun = NO;
		while (!canRun) {
			sleep(2);
			if (appModel.isServerListening) {
				canRun = YES;
				
				NSString *command = [NSString stringWithFormat:@"'%@' '%@'",scriptModel.commadStr, scriptPath];
				
				NSAppleScript *script = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"Terminal\" to do script \"%@\"\nactivate application \"Terminal\"", command]];
				
				NSDictionary *dict;
				NSAppleEventDescriptor *des = [script executeAndReturnError:&dict];
				
//				NSLog(@"%@ ,%@ ,%@",NSStringFromSelector(_cmd),dict,des);
			}
		}
		
//		if (!isServerRunning) {
//			isServerRunning = [appModel startServer];
//			if (!isServerRunning) {
//				NSLog(@"can't start server");
//				return;
//			}
//			else{
//				BOOL canRun = NO;
//				while (!canRun) {
//					sleep(2);
//					if (appModel.isServerListening) {
//						canRun = YES;
////						if (appDelegate.inspectorWindow.driver) [appDelegate.inspectorWindow.driver quit];
////						if (appDelegate.inspectorWindow.window) [appDelegate.inspectorWindow.window close];
//						
//						NSString *command = [NSString stringWithFormat:@"'%@' '%@'",scriptModel.commadStr, scriptPath];
//						
//						NSAppleScript *script = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"Terminal\" to do script \"%@\"\nactivate application \"Terminal\"", command]];
//						
//						NSDictionary *dict;
//						NSAppleEventDescriptor *des = [script executeAndReturnError:&dict];
//						
//						NSLog(@"%@ ,%@ ,%@",NSStringFromSelector(_cmd),dict,des);
//					}
//				}
//			}
//		}
		
//		if (appDelegate.inspectorWindow.driver) [appDelegate.inspectorWindow.driver quit];
//		if (appDelegate.inspectorWindow.window) [appDelegate.inspectorWindow.window close];
//		
//		NSString *command = [NSString stringWithFormat:@"'%@' '%@'",scriptModel.commadStr, scriptPath];
//		
//		NSAppleScript *script = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"Terminal\" to do script \"%@\"\nactivate application \"Terminal\"", command]];
//		[script executeAndReturnError:nil];
	}
}
+ (AppiumAppDelegate *)appDelegate
{
	return (AppiumAppDelegate *)[NSApplication sharedApplication].delegate;
}
@end
