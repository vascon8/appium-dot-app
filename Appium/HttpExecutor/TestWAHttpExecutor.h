//
//  HttpExecutor.h
//  Appium
//
//  Created by xin liu on 15/2/1.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RecordScriptUploadParam;
@class TestWALoginParam;

@interface TestWAHttpExecutor : NSObject

//load app data
+ (void)loadDataWithUrlStr:(NSString *)urlStr queue:(NSOperationQueue *)loadQueue  handleResultBlock:(void (^)(id resultData,NSError *error))handleResultBlock;
//upload script
+ (void)uploadScriptWithUrlStr:(NSString *)urlStr queue:(NSOperationQueue *)uploadQueue postParams:(RecordScriptUploadParam *)params handleResultBlock:(void (^)(id resultData,NSError *error))handleResultBlock;
//login
+ (void)postWithUrlStr:(NSString *)urlStr params:(TestWALoginParam *)params handleResultBlock:(void (^)(id resultData,NSError *error))handleResultBlock;
@end
