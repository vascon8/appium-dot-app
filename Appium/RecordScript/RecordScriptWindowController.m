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
- (IBAction)chooseScriptButtonClicked:(NSButton *)sender {
	NSOpenPanel* chooseScriptPanlel = [NSOpenPanel openPanel];
	[chooseScriptPanlel setMessage:@"请选择要上传的脚本"];
	[chooseScriptPanlel setPrompt:@"上传"];
	[chooseScriptPanlel setDirectoryURL:[NSURL URLWithString:[DEFAULTS valueForKey:APPIUM_PLIST_ExportRecordScripts_DIRECTORY]]];
    
    // Enable the selection of files in the dialog.
    [chooseScriptPanlel setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [chooseScriptPanlel setCanChooseDirectories:YES];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
	[chooseScriptPanlel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		NSLog(@"url:%@",[chooseScriptPanlel URLs]);
		if (result == NSFileHandlingPanelOKButton) {
//			[self.appNameFieldCell setStringValue:[[chooseScriptPanlel URLs][0] lastPathComponent]];
			
			NSLog(@"url2:%@",[chooseScriptPanlel URLs]);
		}
	}];
}

#pragma mark - tableview datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.appListArr.count;
}
//- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//	RecordscriptApp *rc = [self.appListArr objectAtIndex:row];
//	NSString *identifier = [tableColumn identifier];
//	return [rc valueForKey:identifier];
//}
#pragma mark - tableview delegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView	 *cellView = [tableView makeViewWithIdentifier:@"myView" owner:self.recordscriptAppTableView];
	RecordscriptApp *rc = [self.appListArr objectAtIndex:row];
	NSLog(@"%@ %@",cellView,cellView.textField);
	cellView.textField.stringValue = [rc valueForKey:tableColumn.identifier];
	return cellView;
}
@end
