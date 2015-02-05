//
//  TestWALoginResult.h
//  Appium
//
//  Created by xin liu on 15/2/5.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TestWAServerUser;

@interface TestWALoginResult : NSObject

@property NSString *flag;
@property NSString *message;
@property TestWAServerUser *user;

@end
