//
//  TestWAAccountTool.h
//  Appium
//
//  Created by xinliu on 15-2-2.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestWAServerUser.h"

@interface TestWAAccountTool : NSObject

+ (BOOL)isLogin;
+ (void)saveAccount:(TestWAServerUser *)user;
+ (TestWAServerUser *)requestAccount;
+ (NSString *)loginUserName;

+ (void)clearAccountRecord;

@end
