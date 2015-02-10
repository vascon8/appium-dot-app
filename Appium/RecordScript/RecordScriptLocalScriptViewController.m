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

@interface RecordScriptLocalScriptViewController ()<NSTableViewDataSource>

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
	RecordScriptLocalScriptDirModel *defaultDir = [RecordScriptLocalScriptDirModel dirModelWithPath:[DEFAULTS valueForKey:APPIUM_PLIST_ExportRecordScripts_DIRECTORY]];
	self.dirList = @[defaultDir];
	
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

@end
