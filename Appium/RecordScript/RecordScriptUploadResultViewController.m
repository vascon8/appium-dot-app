//
//  RecordScriptUploadResultViewController.m
//  Appium
//
//  Created by xin liu on 15/1/26.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "RecordScriptUploadResultViewController.h"
#import "RecordScriptUploadResult.h"

@interface RecordScriptUploadResultViewController ()<NSTableViewDataSource,NSTableViewDelegate>

@end

@implementation RecordScriptUploadResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
#pragma mark - tableView datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.scriptList.count;
}
#pragma mark - tableView delegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:nil];
	RecordScriptUploadResult *result = [self.scriptList objectAtIndex:row];
	cellView.textField.stringValue = result.scriptName;
	return cellView;
}
@end