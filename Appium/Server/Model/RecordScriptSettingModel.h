//
//  RecordScriptSettingModel.h
//  Appium
//
//  Created by xinliu on 15-1-27.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordScriptSettingModel : NSObject

@property NSString *exportscriptsDirectory;
@property BOOL useExportscriptsDirectory;

@property NSString *testWAServerAddr;
@property NSNumber *testWASererPort;

@end
