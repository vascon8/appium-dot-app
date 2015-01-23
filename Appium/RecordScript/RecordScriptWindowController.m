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
- (void)awakeFromNib
{
	
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
		}
	}
	else if (resultData == nil){
		NSLog(@"no data found");
	}
	else{
		NSLog(@"%@",error);
	}
}
- (void)handleJsonResult:(NSDictionary *)resultDict
{
	NSMutableArray *resultArr = [NSMutableArray arrayWithCapacity:resultDict.count];
	NSDictionary *dict = [NSDictionary objectWithKeyedDict:resultDict modelDict:@{@"videos":@"RecordscriptApp"}];
	NSArray *tempA = dict[@"videos"];
	for (RecordscriptApp *app in tempA) {
		
	}
}
- (void)uploadScript
{

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
			
			self.scriptNameTextField.stringValue = [[chooseScriptPanlel URLs][0] lastPathComponent];
//			float H = self.recordscriptUploadView.frame.size.height;
//			for (int i=0; i<chooseScriptPanlel.URLs.count; i++) {
//				RecordScriptStatusView *statusView = [[RecordScriptStatusView alloc]init];
//				NSRect rect = statusView.frame;
//				rect.origin.x = 0.0;
//				rect.origin.y = i*H;
//				statusView.frame = rect;
//				[self.recordscriptUploadView addSubview:statusView];
//				statusView.scriptNameTextField.stringValue = [[chooseScriptPanlel URLs][i] lastPathComponent];
//				NSLog(@"%@ %@",statusView,NSStringFromRect(statusView.frame));
//			}
			
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
