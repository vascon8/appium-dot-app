//
//  HttpExecutor.m
//  Appium
//
//  Created by xin liu on 15/2/1.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "TestWAHttpExecutor.h"
#import "RecordScriptUploadParam.h"
#import "NSObject+LXDict.h"

@implementation TestWAHttpExecutor

+ (void)loadDataWithUrlStr:(NSString *)urlStr handleResultBlock:(void (^)(id resultData,NSError *error))handleResultBlock{
	
	NSURL *url = [NSURL URLWithString:[self handleUrlStr:urlStr]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if (!error && data != nil) {
		id resultData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		
		if (error) {
			NSLog(@"error found:%@",error);
		}
		else{
			handleResultBlock(resultData,nil);
		}
	}
	else if (data == nil){
		NSLog(@"no data found");
	}
	else{
		NSLog(@"%@",error);
		handleResultBlock(nil,error);
	}
}

+ (void)uploadScriptWithUrlStr:(NSString *)urlStr queue:(NSOperationQueue *)uploadQueue postParams:(RecordScriptUploadParam *)params handleResultBlock:(void (^)(id resultData,NSError *error))handleResultBlock{
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[params keyedDictFromModel] options:NSJSONWritingPrettyPrinted error:&error];
	if (error) {NSLog(@"%@",error); handleResultBlock(nil,error);return;}
	
	NSURL *url = [NSURL URLWithString:[self handleUrlStr:urlStr]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0f];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:jsonData];
	[request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	
	[NSURLConnection sendAsynchronousRequest:request queue:uploadQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		if (connectionError) {
			NSLog(@"%@",connectionError);
		}
		else{
			NSLog(@"%@",response);
		}
		handleResultBlock(response,connectionError);
	}];
}

+ (NSString *)handleUrlStr:(NSString *)urlStr
{
	return [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end
