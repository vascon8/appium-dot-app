//
//  RecordScriptWindowController.m
//  Appium
//
//  Created by xinliu on 15-1-21.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "RecordScriptWindowController.h"
#import "AppiumPreferencesFile.h"

#import "RecordscriptApp.h"
#import "RecordScriptStatusView.h"

@interface RecordScriptWindowController ()<NSTableViewDataSource,NSTableViewDelegate>
@property NSMutableArray *appListArr;
@end

@implementation RecordScriptWindowController
- (id)initWithWindowNibName:(NSString *)windowNibName
{
	self = [super initWithWindowNibName:windowNibName];
	if (self) {	}
	return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	self.appListArr = [[NSMutableArray alloc]init];
		for (int i=0; i<5; i++) {
		RecordscriptApp *rc = [[RecordscriptApp alloc]init];
		rc.platformName = ((i%2==0) ? @"IOS" : @"Android");
		rc.appName = [NSString stringWithFormat:@"app%d",i+1];
		[self.appListArr addObject:rc];
	}
	
	self.recordscriptAppTableView.delegate = self;
	self.recordscriptAppTableView.dataSource = self;
}
#pragma mark - upload record script
- (IBAction)chooseScriptButtonClicked:(NSButton *)sender {
	NSOpenPanel* chooseScriptPanlel = [NSOpenPanel openPanel];
	[chooseScriptPanlel setMessage:@"请选择要上传的脚本"];
	[chooseScriptPanlel setPrompt:@"上传"];
	[chooseScriptPanlel setDirectoryURL:[NSURL URLWithString:[DEFAULTS valueForKey:APPIUM_PLIST_ExportRecordScripts_DIRECTORY]]];
    
    [chooseScriptPanlel setCanChooseFiles:YES];
//    [chooseScriptPanlel setCanChooseDirectories:YES];

	[chooseScriptPanlel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) {
			
			float H = self.recordscriptUploadView.frame.size.height;
			for (int i=0; i<chooseScriptPanlel.URLs.count; i++) {
				RecordScriptStatusView *statusView = [[RecordScriptStatusView alloc]init];
				NSRect rect = statusView.frame;
				rect.origin.x = 0.0;
				rect.origin.y = i*H;
				statusView.frame = rect;
				[self.recordscriptUploadView addSubview:statusView];
				statusView.scriptNameTextField.stringValue = [[chooseScriptPanlel URLs][i] lastPathComponent];
				NSLog(@"%@ %@",statusView,NSStringFromRect(statusView.frame));
			}
			
		}
	}];
}
#pragma mark - tableview datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.appListArr.count;
}
#pragma mark - tableview delegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView	 *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
	RecordscriptApp *rc = [self.appListArr objectAtIndex:row];
	cellView.textField.stringValue = [rc valueForKey:tableColumn.identifier];
	return cellView;
}
@end
