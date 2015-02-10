//
//  RecordScriptLocalScriptDirModel.m
//  Appium
//
//  Created by xin liu on 15/2/10.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "RecordScriptLocalScriptDirModel.h"

@implementation RecordScriptLocalScriptDirModel

+ (instancetype)dirModelWithPath:(NSString *)path
{
	return [[self alloc]initWithPath:path];
}
- (instancetype)initWithPath:(NSString *)path
{
	if (self = [super init]) {
		self.fileUrl = [NSURL URLWithString:path];
	}
	
	return self;
}
@end
