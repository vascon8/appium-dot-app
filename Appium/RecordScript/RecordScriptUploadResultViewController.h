//
//  RecordScriptUploadResultViewController.h
//  Appium
//
//  Created by xin liu on 15/1/26.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RecordScriptUploadResultViewController : NSViewController

@property (weak) IBOutlet NSTableView *tableView;

@property NSArray *scriptList;
//@property (weak) IBOutlet NSTableView *scriptResultTableView;

@end
