//
//  RecordScriptLocalScriptOperateViewController.h
//  Appium
//
//  Created by xin liu on 15/2/10.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RecordScriptLocalScriptDirModel;

@class RecordScriptLocalScriptViewController;

@interface RecordScriptLocalScriptOperateViewController : NSViewController

@property RecordScriptLocalScriptDirModel *currentDir;
@property (weak) RecordScriptLocalScriptViewController *localScriptController;

@end
