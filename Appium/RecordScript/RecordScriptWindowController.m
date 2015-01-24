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

#import "NSObject+LXDict.h"

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
//	self.appListArr = [[NSMutableArray alloc]init];
//		for (int i=0; i<5; i++) {
//		RecordscriptApp *rc = [[RecordscriptApp alloc]init];
//		rc.platformName = ((i%2==0) ? @"IOS" : @"Android");
//		rc.appName = [NSString stringWithFormat:@"app%d",i+1];
//		[self.appListArr addObject:rc];
//	}
	
	[self loadAppData];
	
	self.recordscriptAppTableView.delegate = self;
	self.recordscriptAppTableView.dataSource = self;
}
#pragma mark - load data
- (void)loadAppData
{
	[self.loadDataProgressIndicator startAnimation:nil];
	
	 NSString *str =@"https://openapi.youku.com/v2/videos/by_category.json?client_id=ecb276dff376b7e2";
	NSURL *url = [NSURL URLWithString:str];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if (!error && resultData != nil) {
		NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingAllowFragments error:&error];
		if (error) {
			NSLog(@"error found:%@",error);
		}
		else{
			[self handleJsonResult:resultDict];
			[self.recordscriptAppTableView reloadData];
		}
	}
	else if (resultData == nil){
		NSLog(@"no data found");
	}
	else{
		NSLog(@"%@",error);
	}
	
	[self.loadDataProgressIndicator stopAnimation:nil];
}
- (void)handleJsonResult:(NSDictionary *)resultDict
{
	NSArray *resultArr = resultDict[@"videos"];
	NSMutableArray *tempArrM = [NSMutableArray arrayWithCapacity:resultArr.count];
	for (NSDictionary *dict in resultArr) {
		RecordscriptApp *rc = [RecordscriptApp objectWithKeyedDict:dict];
		rc.appName = rc.title;
		rc.platformName = rc.category;
		[tempArrM addObject:rc];
	}
	self.appListArr = tempArrM;
}
#pragma mark - upload record script
- (void)uploadScript
{
	
}
- (IBAction)chooseScriptButtonClicked:(NSButton *)sender {
	NSOpenPanel* chooseScriptPanlel = [NSOpenPanel openPanel];
	[chooseScriptPanlel setMessage:@"请选择要上传的脚本"];
	[chooseScriptPanlel setPrompt:@"确认上传"];
	
	[chooseScriptPanlel setFrameTopLeftPoint:self.window.frame.origin];
	[chooseScriptPanlel setDirectoryURL:[NSURL URLWithString:[DEFAULTS valueForKey:APPIUM_PLIST_ExportRecordScripts_DIRECTORY]]];
    [chooseScriptPanlel setCanChooseFiles:YES];

	[chooseScriptPanlel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton && [[chooseScriptPanlel URLs][0] lastPathComponent]) {
			
			self.scriptNameTextField.stringValue = [[chooseScriptPanlel URLs][0] lastPathComponent];
			[self uploadScript];
			
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
