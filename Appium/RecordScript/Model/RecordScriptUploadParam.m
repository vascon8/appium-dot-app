//
//  RecordScriptUploadParam.m
//  Appium
//
//  Created by xin liu on 15/1/25.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "RecordScriptUploadParam.h"

@implementation RecordScriptUploadParam
- (NSString *)description
{
	return [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",self.appId,self.name,self.filename,self.language,self.urlStr];
}
@end
