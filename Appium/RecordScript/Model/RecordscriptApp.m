//
//  RecordscriptApp.m
//  Appium
//
//  Created by xin liu on 15/1/21.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "RecordscriptApp.h"

@implementation RecordscriptApp

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ %@ %@ %@",self.appName,self.platformName,self.category,self.title];
}
@end
