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
#import "RecordScriptUploadParam.h"

#import "NSObject+LXDict.h"
#import "TestWAHttpExecutor.h"

#import "RecordScriptUploadResultViewController.h"
#import "RecordScriptUploadResult.h"

#import "TestWAServerUser.h"
#import "TestWAServerProject.h"

@interface RecordScriptWindowController ()<NSTableViewDataSource,NSTableViewDelegate>

@property NSMutableArray *appListArr;
@property BOOL isLoadingApp;
@property (strong) IBOutlet RecordScriptUploadResultViewController *scriptUploadViewController;
@property NSOperationQueue *uploadQueue;

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
	[self setupViews];
	[self setupAppData];
}
- (void)setupViews
{
	[self.scriptAddButton setHidden:YES];
	[self.scriptFistAddButton setHidden:NO];
	[self.scriptFistAddButton setEnabled:NO];

	[self.scriptUploadViewController.tableView setHidden:YES];
}
- (void)setupAppData
{
	self.appInfoTableView.delegate = self;
	self.appInfoTableView.dataSource = self;
	self.uploadQueue = [[NSOperationQueue alloc]init];
	[self.uploadQueue setMaxConcurrentOperationCount:MaxConcurrentUploadOperation];
	
//	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
//	for (int i=0; i<6; i++) {
//		RecordscriptApp *app = [[RecordscriptApp alloc]init];
//		app.type = i%2 ? @"IOS" : @"Android";
//		app.name = [NSString stringWithFormat:@"App %d",i+1];
//		[arr addObject:app];
//	}
//	self.appListArr = arr;
//	[self.appInfoTableView reloadData];
	
//	[self loadAppData];
	[self loadProjectData];
}
#pragma mark - load project data
- (void)loadProjectData
{
	[TestWAHttpExecutor loadDataWithUrlStr:[RecordscriptGetServerProjectAddress stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] handleResultBlock:^(NSDictionary *resultDict) {
//		NSLog(@"%@",resultDict);
	}];
}
#pragma mark - load app data
- (IBAction)refreshAppList:(id)sender {
	if (self.isLoadingApp) return;
	[self loadAppData];
}
- (void)loadAppData
{
	self.isLoadingApp = YES;
	[self.appLoadProgressIndicator startAnimation:nil];
	[self.appInfoRefreshButton setEnabled:NO];
	
	[TestWAHttpExecutor loadDataWithUrlStr:[RecordscriptGetServerAppAddress stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] handleResultBlock:^(NSDictionary *resultDict) {
		NSMutableArray *tempArrM = [NSMutableArray arrayWithCapacity:resultDict.count];
		for (NSDictionary *dict in resultDict) {
			RecordscriptApp *rc = [RecordscriptApp objectWithKeyedDict:dict];
			[tempArrM addObject:rc];
		}
		self.appListArr = tempArrM;
		tempArrM = nil;
		[self.appInfoTableView reloadData];
		NSLog(@"appist:%@",self.appListArr);
	}];
	
	
	[self.appLoadProgressIndicator stopAnimation:nil];
	self.isLoadingApp = NO;
	[self.appInfoRefreshButton setEnabled:YES];
}
#pragma mark - get User data
- (TestWAServerUser *)getUser
{
	__block TestWAServerUser *user = nil;
	NSString *str = [RecordscriptGetServerUser stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[TestWAHttpExecutor loadDataWithUrlStr:str handleResultBlock:^(NSDictionary *resultDict) {
		user = [TestWAServerUser objectWithKeyedDict:resultDict];
		NSLog(@"user:%@",user);
	}];
	
	return user;
}
#pragma mark - upload script
- (void)uploadScriptWithPostParams:(RecordScriptUploadParam *)params
{
	[self updateScriptResultView];
	[TestWAHttpExecutor uploadScriptWithUrlStr:RecordscriptUploadServerAddress queue:self.uploadQueue postParams:params];
}
- (void)updateScriptResultView
{
	NSInteger selectedRow = self.appInfoTableView.selectedRow;
	RecordscriptApp *app = [self.appListArr objectAtIndex:selectedRow];
	self.scriptUploadViewController.scriptList = [NSArray arrayWithArray:app.scriptList];
	if (self.scriptUploadViewController.scriptList.count>0) [self.scriptUploadViewController.view setHidden:NO];
	[self.scriptUploadViewController.tableView reloadData];
}
- (IBAction)chooseScriptButtonClicked:(NSButton *)sender {
	NSOpenPanel* chooseScriptPanlel = [NSOpenPanel openPanel];
	[chooseScriptPanlel setMessage:@"请选择要上传的脚本"];
	[chooseScriptPanlel setPrompt:@"确认上传"];
	[chooseScriptPanlel setFrameOrigin:self.window.frame.origin];
	
	[chooseScriptPanlel setFrameTopLeftPoint:self.window.frame.origin];
	[chooseScriptPanlel setDirectoryURL:[NSURL URLWithString:[DEFAULTS valueForKey:APPIUM_PLIST_ExportRecordScripts_DIRECTORY]]];
    [chooseScriptPanlel setCanChooseFiles:YES];

	[chooseScriptPanlel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		
		if (result == NSFileHandlingPanelOKButton && [[chooseScriptPanlel URLs][0] lastPathComponent]) {
			NSURL *scriptFileUrl = [chooseScriptPanlel URLs][0];
			
			if (!self.scriptFistAddButton.isHidden) {
				[self.scriptFistAddButton setHidden:YES];
				
				[self.scriptAddButton setHidden:NO];
			}
		
			NSInteger selectedRow = self.appInfoTableView.selectedRow;
			RecordscriptApp *app = (RecordscriptApp *)self.appListArr[selectedRow];
		
			[self setupAppRecordScriptUploadResult:app withScriptName:[scriptFileUrl lastPathComponent]];
			[self uploadScriptWithPostParams:[self setupAppParams:app withScriptFileUrl:scriptFileUrl]];
		}
	}];
}
#pragma mark update record script result
- (void)setupAppRecordScriptUploadResult:(RecordscriptApp *)app withScriptName:(NSString *)scriptName
{
	NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:app.scriptList.count+1];
	if (app.scriptList) [arrM addObjectsFromArray:app.scriptList];
	RecordScriptUploadResult *result = [RecordScriptUploadResult new];
	result.scriptName = scriptName;
	[arrM addObject:result];
	app.scriptList = arrM;
	arrM = nil;
}
- (RecordScriptUploadParam *)setupAppParams:(RecordscriptApp *)app withScriptFileUrl:(NSURL *)scriptFileUrl
{
	RecordScriptUploadParam *param = [[RecordScriptUploadParam alloc]init];
	NSString *path = [scriptFileUrl path];
	param.filePath = path;
	param.filename = [path lastPathComponent];
	param.appId = app.id;
	param.name = app.name;
	param.language = [self scriptLanguage:param.filename];
	TestWAServerUser *user = [self getUser];
	param.userID = user.id;
	NSLog(@"userid:%@",param.userID);
	
	NSData *fileData = [NSData dataWithContentsOfFile:path];
	param.base64EncodingStr = [fileData base64Encoding];
	NSLog(@"param:%@",param);
	
	return param;
}
- (NSString *)scriptLanguage:(NSString *)fileName
{
	NSString *language = nil;
	NSRange range = [fileName rangeOfString:@"." options:NSBackwardsSearch];
	if (range.length > 0) {
		NSString *ext = [fileName substringFromIndex:range.location+1];
		if ([ext isEqualToString:@"py"]) {
			language = @"Python";
		}
		else if ([ext isEqualToString:@"js"]){
			language = @"node.js";
		}
		else if ([ext isEqualToString:@"rb"]){
			language = @"Ruby";
		}
		else if ([ext isEqualToString:@"cs"]){
			language = @"C#";
		}
		else if ([ext isEqualToString:@"java"]){
			language = @"Java";
		}
		else if ([ext isEqualToString:@"m"]){
			language = @"Objective-C";
		}
	}
	
	return language;
}
#pragma mark - tableview datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSInteger rows = self.appListArr.count;
    if (rows <= 0) {
        if (self.scriptFistAddButton.isEnabled) [self.scriptFistAddButton setEnabled:NO];
    }
	else{
        if (!self.scriptAddButton.isEnabled) [self.scriptAddButton setEnabled:YES];
	}
    
	return rows;
}
#pragma mark - tableview delegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView	 *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
	RecordscriptApp *app = [self.appListArr objectAtIndex:row];
	cellView.textField.stringValue = app.name;
	NSString *imageName = @"apple";
	if ([app.type isEqualToString:@"android"]) imageName = @"android";
	[cellView.imageView setImage:[NSImage imageNamed:imageName]];
	return cellView;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if ([self.appInfoTableView numberOfRows] > 0 && !self.scriptFistAddButton.isEnabled) {
		[self.scriptFistAddButton setEnabled:YES];
	}
	
	NSInteger selectedRow = self.appInfoTableView.selectedRow;
	RecordscriptApp *app = [self.appListArr objectAtIndex:selectedRow];
	if (app.scriptList.count>0) {
		if (!self.scriptFistAddButton.isHidden)[self.scriptFistAddButton setHidden:YES];
		if (self.scriptAddButton.isHidden)[self.scriptAddButton setHidden:NO];
		
		if (self.scriptUploadViewController.tableView.isHidden)[self.scriptUploadViewController.tableView setHidden:NO];
		self.scriptUploadViewController.scriptList = app.scriptList;
		[self.scriptUploadViewController.tableView reloadData];
	}
	else{
		[self.scriptUploadViewController.tableView setHidden:YES];
		[self.scriptFistAddButton setHidden:NO];
		[self.scriptAddButton setHidden:YES];
	}
}
@end
