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
	
	if ([tableColumn.identifier isEqualToString:@"Script"]) {
		cellView.textField.stringValue = result.scriptName;
		switch (result.uploadStatus) {
			case RecordScriptUploadStatusUploading:
				[cellView.imageView setImage:[NSImage imageNamed:@"upload"]];
				break;
			case RecordScriptUploadStatusFail:
				[cellView.imageView setImage:[NSImage imageNamed:@"uplod-fail"]];
				break;
			case RecordScriptUploadStatusSuccess:
			default:
				[cellView.imageView setImage:[NSImage imageNamed:@"upload-success"]];
				break;
		}
	}
	else{
		NSButton *btn = (NSButton *)cellView;
		[btn setState:result.checked];
		[btn setAction:@selector(clickedCheckButton:)];
		[btn setTarget:self];
	}

	return cellView;
}
#pragma mark - click check button
- (void)clickedCheckButton:(NSButton *)sender
{
	RecordScriptUploadResult *result = [self.scriptList objectAtIndex:[self.tableView rowForView:sender]];
	result.checked = sender.state;
	if ([self.delegate respondsToSelector:@selector(recordscriptUploadResultView:checkedScriptRow:)]) {
		[self.delegate recordscriptUploadResultView:self checkedScriptRow:sender.state];
	}
}
@end
