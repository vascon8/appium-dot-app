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
		btn.state = op.checked;
	}
	else{
		NSButton *btn = (NSButton *)view;
		[btn setImage:[NSImage imageNamed:@"run"]];
	}
	
	return view;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	
	NSString *path = [self.localScriptController selectedDir];
	
	if (path && self.tableView.selectedRow!=-1 && self.tableView.selectedRow<self.scriptList.count) {
		[self.runScriptBtn setEnabled:YES];
		
		NSInteger selectedRow = [self.tableView selectedRow];
		RecordScriptLocalScriptOperateModel *op = [self.scriptList objectAtIndex:selectedRow];
		self.pathLabel.stringValue = [path stringByAppendingPathComponent:op.name];
	}
	else{
		[self.runScriptBtn setEnabled:NO];
	}
}
#pragma mark - run script
- (IBAction)clickedRunScriptBtn:(id)sender {
	
	if([[NSFileManager defaultManager]fileExistsAtPath:self.pathLabel.stringValue]) [self runScript];
}
- (void)runScript
{
	NSString *scriptName = [self.pathLabel.stringValue lastPathComponent];
	RecordScriptModel *scriptModel = [RecordScriptTool recordScriptWithName:scriptName];
	if ([scriptModel.language isEqualTo:@"Python"] || [scriptModel.language isEqualTo:@"node.js"] || [scriptModel.language isEqualTo:@"Ruby"]) {
		
//		[self.driver quit];
//		[_windowController.window close];
		
		NSString *command = [NSString stringWithFormat:@"'%@' '%@'",scriptModel.commadStr, self.pathLabel.stringValue];
		
		NSAppleScript *script = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"Terminal\" to do script \"%@\"\nactivate application \"Terminal\"", command]];
		[script executeAndReturnError:nil];
	}

}
#pragma mark - remove script
- (IBAction)clickedRemoveBtn:(id)sender {
}

#pragma mark - private
@synthesize dirList;
- (void)setDirList:(NSArray *)newDirList
{
	if (newDirList.count>0 && dirList != newDirList) {
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
