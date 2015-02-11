//
//  RecordScriptLocalScriptViewController.m
//  Appium
//
//  Created by xinliu on 15-2-9.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "RecordScriptLocalScriptViewController.h"
#import "RecordScriptLocalScriptDirModel.h"
#import "RecordScriptLocalScriptOperateViewController.h"

#import "AppiumPreferencesFile.h"

@interface RecordScriptLocalScriptViewController ()<NSTableViewDataSource,NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *dirTableView;
@property NSArray *dirList;

@property (strong) IBOutlet RecordScriptLocalScriptOperateViewController *operateTableView;

@end

@implementation RecordScriptLocalScriptViewController
- (void)loadView
{
	[super loadView];
}
- (void)prepareData
{
	self.operateTableView.localScriptController = self;
	
	RecordScriptLocalScriptDirModel *defaultDir = [RecordScriptLocalScriptDirModel dirModelWithPath:[DEFAULTS valueForKey:APPIUM_PLIST_ExportRecordScripts_DIRECTORY]];
	self.dirList = @[defaultDir];
	
//	self.operateTableView.dirList = self.dirList;
	[self.dirTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:YES];
	self.operateTableView.dirList = self.dirList;
}
#pragma mark - dir tableview datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.dirList.count;
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	RecordScriptLocalScriptDirModel *dirModel = [self.dirList objectAtIndex:row];
	return dirModel.fileUrl.lastPathComponent;
}
#pragma mark - dir tableview delegate
//- (void)tableViewSelectionDidChange:(NSNotification *)notification
//{
//	if (!self.operateTableView.dirList && self.dirTableView.selectedRow != -1 && self.dirTableView.selectedRow < self.dirList.count)
//	self.operateTableView.dirList = self.dirList;
//}
#pragma mark - add dir
- (IBAction)clickedAddDirBtn:(id)sender {
	NSOpenPanel *addDirPanel = [NSOpenPanel openPanel];
	addDirPanel.canChooseFiles = NO;
	addDirPanel.canChooseDirectories = YES;
	[addDirPanel setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
	[addDirPanel setCanCreateDirectories:YES];
	[addDirPanel setPrompt:@"添加该目录"];
	[addDirPanel setMessage:@"添加管理脚本目录"];
	
	[addDirPanel beginSheetModalForWindow:nil completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton && [addDirPanel URLs]) {
			NSLog(@"%@",[addDirPanel URLs]);
		}
		NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:self.dirList.count+1];
		[arrM addObjectsFromArray:self.dirList];
		RecordScriptLocalScriptDirModel *dir = [[RecordScriptLocalScriptDirModel alloc]init];
		dir.fileUrl = [addDirPanel URLs][0];
		[arrM addObject:dir];
		
		self.dirList = arrM;
		[self.dirTableView reloadData];
	}];
}

#pragma mark - selected dir
- (NSString *)selectedDir
{
	if (self.dirTableView.selectedRow != -1 && self.dirTableView.selectedRow < self.dirList.count) {
		NSInteger selectedRow = [self.dirTableView selectedRow];
		RecordScriptLocalScriptDirModel *dir = [self.dirList objectAtIndex:selectedRow];
		return [dir.fileUrl path];
	}
	else{
		return nil;
	}
}
@end
