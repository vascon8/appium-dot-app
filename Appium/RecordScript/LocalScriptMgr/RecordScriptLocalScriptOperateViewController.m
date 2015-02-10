//
//  RecordScriptLocalScriptOperateViewController.m
//  Appium
//
//  Created by xin liu on 15/2/10.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "RecordScriptLocalScriptOperateViewController.h"
#import "RecordScriptLocalScriptOperateModel.h"
#import "RecordScriptLocalScriptDirModel.h"

@interface RecordScriptLocalScriptOperateViewController ()<NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *tableView;
@property NSArray *scriptList;

@end

@implementation RecordScriptLocalScriptOperateViewController

#pragma mark - data source
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.scriptList.count;
}
#pragma mark - delegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
	RecordScriptLocalScriptOperateModel *op = [self.scriptList objectAtIndex:row];
	
	if ([tableColumn.identifier isEqualToString:@"nameColumn"]) {
		view.textField.stringValue = op.name;
	}
	else if([tableColumn.identifier isEqualToString:@"checkColumn"]){
		NSButton *btn = (NSButton *)view;
		btn.state = op.checked;
	}
	else{
		NSButton *btn = (NSButton *)view;
		[btn setImage:[NSImage imageNamed:@"run"]];
	}
	
	return view;
}
#pragma mark - private
@synthesize dirList;
- (void)setDirList:(NSArray *)newDirList
{
	if (dirList != newDirList) {
		dirList = newDirList;
		
		NSMutableArray *arrM = [NSMutableArray array];
		for (RecordScriptLocalScriptDirModel *dir in self.dirList) {
			NSError *error;
			NSArray *arr = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[dir.fileUrl path] error:&error];
			if (!error && arr.count > 0){
				for (NSString *fileName in arr) {
					RecordScriptLocalScriptOperateModel *op = [[RecordScriptLocalScriptOperateModel alloc]init];
					op.name = fileName;
					op.checked = NO;
					[arrM addObject:op];
				}
			}
			
		}
		self.scriptList = arrM;
		[self.tableView reloadData];
	}
}
- (NSArray *)dirList
{
	return dirList;
}
@end
