//
//  TestWAServerUser.h
//  Appium
//
//  Created by xin liu on 15/2/1.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestWABaseModel.h"

#define ExpireDate 259200

@interface TestWAServerUser : TestWABaseModel <NSCoding>

//@property long expire_in;
@property NSDate *expireDate;

@end
