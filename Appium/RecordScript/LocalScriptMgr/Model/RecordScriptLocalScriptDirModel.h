//
//  RecordScriptLocalScriptDirModel.h
//  Appium
//
//  Created by xin liu on 15/2/10.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordScriptLocalScriptDirModel : NSObject

@property NSURL *fileUrl;
+ (instancetype)dirModelWithPath:(NSString *)path;
- (instancetype)initWithPath:(NSString *)path;

@end
