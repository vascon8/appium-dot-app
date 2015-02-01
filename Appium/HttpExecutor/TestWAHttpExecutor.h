//
//  HttpExecutor.h
//  Appium
//
//  Created by xin liu on 15/2/1.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RecordScriptUploadParam;

@interface TestWAHttpExecutor : NSObject

//load app data
//load user data
+ (void)loadDataWithUrlStr:(NSString *)urlStr handleResultBlock:(void (^)(NSDictionary *resultDict))handleResultBlock;
//upload script
+ (void)uploadScriptWithUrlStr:(NSString *)urlStr queue:(NSOperationQueue *)uploadQueue postParams:(RecordScriptUploadParam *)params;

@end
