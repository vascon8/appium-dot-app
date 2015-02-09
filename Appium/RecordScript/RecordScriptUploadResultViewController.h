//
//  RecordScriptUploadResultViewController.h
//  Appium
//
//  Created by xin liu on 15/1/26.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RecordScriptUploadResultViewController;

@protocol RecordScriptUploadResultViewDelegate <NSObject>

- (void)recordscriptUploadResultView:(RecordScriptUploadResultViewController *)recordscriptUploadResultView checkedScriptRow:(BOOL)checkedScriptRow;

@end

@interface RecordScriptUploadResultViewController : NSViewController

@property (weak) IBOutlet NSTableView *tableView;

@property NSArray *scriptList;
@property (weak) id<RecordScriptUploadResultViewDelegate> delegate;

@end
