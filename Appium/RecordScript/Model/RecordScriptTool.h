//
//  RecordScriptTool.h
//  Appium
//
//  Created by xinliu on 15-2-10.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecordScriptModel.h"

@interface RecordScriptTool : NSObject

+ (NSString *)scriptLanguage:(NSString *)scriptName;
+ (RecordScriptModel *)recordScriptWithName:(NSString *)scriptName;

@end
