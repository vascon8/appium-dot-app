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

#import "RecordScriptLocalScriptViewController.h"

#import "RecordScriptTool.h"

@interface RecordScriptLocalScriptOperateViewController ()<NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *tableView;
@property NSArray *scriptList;

@property (weak) IBOutlet NSTextField *pathLabel;
@property (weak) IBOutlet NSButton *runScriptBtn;

@property (weak) IBOutlet NSButton *removeButton;

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
		[btn setAction:@selector(clickedCheckBox:)];
		[btn setTarget:self];
		btn.state = op.checked;
	}
	
	return view;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	
	NSString *path = [self.currentDir.fileUrl path];
	
	if (path && self.tableView.selectedRow!=-1 && self.tableView.selectedRow<self.scriptList.count) {
		[self.runScriptBtn setHidden:NO];
		
		NSInteger selectedRow = [self.tableView selectedRow];
		RecordScriptLocalScriptOperateModel *op = [self.scriptList objectAtIndex:selectedRow];
		self.pathLabel.stringValue = [path stringByAppendingPathComponent:op.name];
	}
	else{
		[self.runScriptBtn setHidden:YES];
	}
}
- (void)clickedCheckBox:(NSButton *)sender
{
	NSInteger selectedRow = [self.tableView rowForView:sender];
	RecordScriptLocalScriptOperateModel *op = [self.scriptList objectAtIndex:selectedRow];
	op.checked = sender.state;
	
	for (RecordScriptLocalScriptOperateModel *op in self.scriptList) {
		if (op.checked) {
			[self.removeButton setEnabled:YES];
			return;
		}
	}
	
	[self.removeButton setEnabled:NO];
}

#pragma mark - run script
- (IBAction)clickedRunScriptBtn:(id)sender {
	
	if([[NSFileManager defaultManager]fileExistsAtPath:self.pathLabel.stringValue]) [RecordScriptTool runScript:self.pathLabel.stringValue];
}

#pragma mark - remove script
- (IBAction)clickedRemoveBtn:(id)sender {
	NSMutableArray *arrM = [NSMutableArray arrayWithArray:self.scriptList];
	NSMutableArray *filePath = [NSMutableArray array];
	
	for (RecordScriptLocalScriptOperateModel *model in self.scriptList) {
		if (model.checked) {
			[arrM removeObject:model];
			[filePath addObject:[self.currentDir.fileUrl.path stringByAppendingPathComponent:model.name]];
		}
	}
	
	self.scriptList = arrM;
	[self.tableView reloadData];
	
	arrM = nil;
	[self removeFiles:filePath];
}
- (void)removeFiles:(NSArray *)filePath
{
	for (NSString *path in filePath) {
		NSError *error = nil;
		[[NSFileManager defaultManager]removeItemAtPath:path error:&error];
		if (error) {
			NSLog(@"remove file error:%@",error);
		}
	}
}
#pragma mark - private
@synthesize currentDir;
- (void)setCurrentDir:(RecordScriptLocalScriptDirModel *)newDir
{
	if (newDir && newDir != currentDir) {
		currentDir = newDir;
		
		NSMutableArray *arrM = [NSMutableArray array];
			NSError *error;
			NSArray *arr = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[currentDir.fileUrl path] error:&error];
			if (!error && arr.count > 0){
				for (NSString *fileName in arr) {
					RecordScriptModel *model = [RecordScriptTool recordScriptWithName:fileName];
					if (!model.language) continue;
					
					RecordScriptLocalScriptOperateModel *op = [[RecordScriptLocalScriptOperateModel alloc]init];
					op.name = fileName;
					op.checked = NO;
					[arrM addObject:op];
				}
		}
		self.scriptList = arrM;
		
		self.pathLabel.stringValue = @"";
		[self.tableView reloadData];
		[self.removeButton setEnabled:NO];
		[self.runScriptBtn setHidden:YES];
	}
}
- (RecordScriptLocalScriptDirModel *)currentDir
{
	return currentDir;
}
@end
