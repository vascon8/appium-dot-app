//
//  RecordscriptApp.h
//  Appium
//
//  Created by xin liu on 15/1/21.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestWABaseModel.h"

@class TestWAServerUser;

@interface RecordscriptApp : TestWABaseModel

/**
 the same with tableview column identifier
 */
@property NSString *type;
@property TestWAServerUser *user;

@property NSString *category;
@property NSString *title;

@property NSArray *scriptList;

@end
