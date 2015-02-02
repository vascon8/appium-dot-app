//
//  TestWAAccountTool.h
//  Appium
//
//  Created by xinliu on 15-2-2.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TestWAServerUser;

@interface TestWAAccountTool : NSObject

+ (BOOL)logedin;
+ (void)saveAccount:(TestWAServerUser *)user;
+ (TestWAServerUser *)requestAccount;

@end
