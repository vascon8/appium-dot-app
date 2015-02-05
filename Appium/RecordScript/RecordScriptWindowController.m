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

#import "AppiumAppDelegate.h"
#import "TestWAAccountTool.h"

#define RecordscriptGetServerAppAddress [NSString stringWithFormat:@"%@/attp/ajax/allApps",TestWAServerPrefix]
#define RecordscriptUploadServerAddress [NSString stringWithFormat:@"%@/attp/upload",TestWAServerPrefix]
#define RecordscriptGetServerUser [NSString stringWithFormat:@"%@/attp/ajax/allAdmin",TestWAServerPrefix]
#define RecordscriptGetServerProjectAddress [NSString stringWithFormat:@"%@/attp/projects/13",TestWAServerPrefix]

@interface RecordScriptWindowController ()<NSTableViewDataSource,NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *appInfoTableView;
@property (weak) IBOutlet NSButton *appInfoRefreshButton;
@property (weak) IBOutlet NSProgressIndicator *appLoadProgressIndicator;

@property (weak) IBOutlet NSButton *scriptAddButton;
@property (weak) IBOutlet NSButton *scriptFistAddButton;
@property (weak) IBOutlet NSButton *scriptRemoveButton;

@property (weak) IBOutlet NSButton *loginButton;
@property (weak) IBOutlet NSTextField *userLabel;

@property NSArray *appListArr;
@property BOOL isLoadingApp;
@property (strong) IBOutlet RecordScriptUploadResultViewController *scriptUploadViewController;
@property NSOperationQueue *uploadQueue;

@property NSArray *prjListArr;
@property BOOL isLogin;

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
	if(_isLogin) [self loadProjectData];
}
- (void)setupViews
{
	[self.scriptAddButton setHidden:YES];
	[self.scriptRemoveButton setHidden:YES];
	[self.scriptFistAddButton setHidden:NO];
	[self.scriptFistAddButton	setEnabled:NO];

	[self.scriptUploadViewController.tableView setHidden:YES];
	
	[self setupUserInfo];
}
- (void)setupUserInfo
{
	self.isLogin = [TestWAAccountTool isLogin];
	if (_isLogin) {
		self.userLabel.stringValue = [TestWAAccountTool loginUserName];
		[self loadProjectData];
	}
	
	[self.userLabel setHidden:!self.isLogin];
	[self.loginButton setHidden:self.isLogin];
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
	self.isLoadingApp = YES;
	[self.appLoadProgressIndicator startAnimation:nil];
	[self.appInfoRefreshButton setEnabled:NO];

	[TestWAHttpExecutor loadDataWithUrlStr:[RecordscriptGetServerProjectAddress stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] handleResultBlock:^(id resultData,NSError *error) {
		if (error) {
			NSLog(@"%@",error);
			return ;
		}
		
		NSDictionary *prj = resultData[@"project"];
		
		NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:prj.count];
		for (id obj in prj) {
			TestWAServerProject *prj = [TestWAServerProject objectWithKeyedDict:obj modelDict:@{@"apps": @"RecordscriptApp"}];
			[arrM addObject:prj];
		}
		self.prjListArr = arrM;
		arrM = nil;
		
		NSMutableArray *arr = [NSMutableArray array];
		for (TestWAServerProject *prj in self.prjListArr) {
			for (RecordscriptApp *app in prj.apps) {
				[arr addObject:app];
			}
		}
		self.appListArr = arr;
		arr = nil;
		
		[self.appInfoTableView reloadData];
	}];
	
	[self.appLoadProgressIndicator stopAnimation:nil];
	self.isLoadingApp = NO;
	[self.appInfoRefreshButton setEnabled:YES];

}
#pragma mark - load app data
- (IBAction)refreshAppList:(id)sender {
	if (self.isLoadingApp || !self.isLogin) return;
	[self loadProjectData];
}
//- (void)loadAppData
//{
//	self.isLoadingApp = YES;
//	[self.appLoadProgressIndicator startAnimation:nil];
//	[self.appInfoRefreshButton setEnabled:NO];
//
//	[TestWAHttpExecutor loadDataWithUrlStr:[RecordscriptGetServerAppAddress stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] handleResultBlock:^(id resultData) {
//		NSMutableArray *tempArrM = [NSMutableArray arrayWithCapacity:resultData.count];
//		for (NSDictionary *dict in resultData) {
//			RecordscriptApp *rc = [RecordscriptApp objectWithKeyedDict:dict];
//			[tempArrM addObject:rc];
//		}
//		self.appListArr = tempArrM;
//		tempArrM = nil;
//		[self.appInfoTableView reloadData];
//		NSLog(@"appist:%@",self.appListArr);
//	}];
//	
//	
//	[self.appLoadProgressIndicator stopAnimation:nil];
//	self.isLoadingApp = NO;
//	[self.appInfoRefreshButton setEnabled:YES];
//}
#pragma mark - get User data
- (TestWAServerUser *)getUser
{
	__block TestWAServerUser *user = nil;
	NSString *str = [RecordscriptGetServerUser stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[TestWAHttpExecutor loadDataWithUrlStr:str handleResultBlock:^(id resultData,NSError *error) {
		if (error) {
			NSLog(@"%@",error);
			return ;
		}
		user = [TestWAServerUser objectWithKeyedDict:resultData];
	}];
	
	return user;
}
#pragma mark - upload script
- (void)uploadScriptWithPostParams:(RecordScriptUploadParam *)params app:(RecordscriptApp *)app uploadIndex:(NSInteger)index
{
	[TestWAHttpExecutor uploadScriptWithUrlStr:RecordscriptUploadServerAddress queue:self.uploadQueue postParams:params handleResultBlock:^(id resultData, NSError *error) {
		RecordScriptUploadResult *result = app.scriptList[index];
		if (!error) {
			result.uploadStatus = RecordScriptUploadStatusSuccess;
		}
		else{
			result.uploadStatus = RecordScriptUploadStatusFail;
		}
		[self.scriptUploadViewController.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:1]];
	}];
}
- (void)updateScriptView
{
//	if (!self.scriptFistAddButton.isHidden) {
//		[self.scriptFistAddButton setHidden:YES];
//		
//		[self.scriptAddButton setHidden:NO];
//		[self.scriptRemoveButton setHidden:NO];
//	}
	
	NSInteger selectedRow = self.appInfoTableView.selectedRow;
	if (selectedRow > self.appListArr.count-1) return;
	RecordscriptApp *app = [self.appListArr objectAtIndex:selectedRow];
	if (app.scriptList.count>0) {
		if (!self.scriptFistAddButton.isHidden)[self.scriptFistAddButton setHidden:YES];
		if (self.scriptAddButton.isHidden)[self.scriptAddButton setHidden:NO];
		if (self.scriptRemoveButton.isHidden)[self.scriptRemoveButton setHidden:NO];
		
		if (self.scriptUploadViewController.tableView.isHidden)[self.scriptUploadViewController.tableView setHidden:NO];
		self.scriptUploadViewController.scriptList = app.scriptList;
		[self.scriptUploadViewController.tableView reloadData];
	}
	else{
		[self.scriptUploadViewController.tableView setHidden:YES];
		[self.scriptFistAddButton setHidden:NO];
		[self.scriptAddButton setHidden:YES];
		[self.scriptRemoveButton setHidden:YES];
	}
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
		
			NSInteger selectedRow = self.appInfoTableView.selectedRow;
			RecordscriptApp *app = (RecordscriptApp *)self.appListArr[selectedRow];
		
			NSInteger uploadIndex = [self setupAppRecordScriptUploadResult:app withScriptName:[scriptFileUrl lastPathComponent]];
			
			NSBlockOperation *uploadOp = [NSBlockOperation blockOperationWithBlock:^{
				[self uploadScriptWithPostParams:[self setupAppParams:app withScriptFileUrl:scriptFileUrl] app:app uploadIndex:uploadIndex];
			}];
			[self.uploadQueue addOperation:uploadOp];
			[self updateScriptView];
		}
	}];
}
#pragma mark update record script result
- (NSInteger)setupAppRecordScriptUploadResult:(RecordscriptApp *)app withScriptName:(NSString *)scriptName
{
	NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:app.scriptList.count+1];
	if (app.scriptList) [arrM addObjectsFromArray:app.scriptList];
	RecordScriptUploadResult *result = [RecordScriptUploadResult new];
	result.scriptName = scriptName;
	result.uploadStatus = RecordScriptUploadStatusUploading;
	[arrM addObject:result];
	app.scriptList = arrM;
	arrM = nil;
	
	[self updateScriptResultTableView];
	
	return app.scriptList.count-1;
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
	if (!user) param.userID = @"1";
	else param.userID = user.id;
	
	NSData *fileData = [NSData dataWithContentsOfFile:path];
	param.base64EncodingStr = [fileData base64Encoding];
	
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
	if ([[app.type lowercaseString] isEqualToString:@"android"]) imageName = @"android";
	[cellView.imageView setImage:[NSImage imageNamed:imageName]];
	return cellView;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if ([self.appInfoTableView numberOfRows] > 0 && !self.scriptFistAddButton.isEnabled) {
		[self.scriptFistAddButton setEnabled:YES];
	}
	
//	NSInteger selectedRow = self.appInfoTableView.selectedRow;
//	RecordscriptApp *app = [self.appListArr objectAtIndex:selectedRow];
//	if (app.scriptList.count>0) {
//		if (!self.scriptFistAddButton.isHidden)[self.scriptFistAddButton setHidden:YES];
//		if (self.scriptAddButton.isHidden)[self.scriptAddButton setHidden:NO];
//		if (self.scriptRemoveButton.isHidden)[self.scriptRemoveButton setHidden:NO];
//		
//		if (self.scriptUploadViewController.tableView.isHidden)[self.scriptUploadViewController.tableView setHidden:NO];
//		self.scriptUploadViewController.scriptList = app.scriptList;
//		[self.scriptUploadViewController.tableView reloadData];
//	}
//	else{
//		[self.scriptUploadViewController.tableView setHidden:YES];
//		[self.scriptFistAddButton setHidden:NO];
//		[self.scriptAddButton setHidden:YES];
//		[self.scriptRemoveButton setHidden:YES];
//	}
	[self updateScriptView];
}
#pragma mark - scriptUploadViewController
//- (void)saveRecordScriptResultForApp:(RecordscriptApp *)app
//{
//	app.scriptList = self.scriptUploadViewController.scriptList;
//}
- (void)updateScriptResultTableView
{
	NSInteger selectedRow = self.appInfoTableView.selectedRow;
	RecordscriptApp *app = [self.appListArr objectAtIndex:selectedRow];
	self.scriptUploadViewController.scriptList = [NSArray arrayWithArray:app.scriptList];
	if (self.scriptUploadViewController.scriptList.count>0) [self.scriptUploadViewController.view setHidden:NO];
	[self.scriptUploadViewController.tableView reloadData];
}
#pragma mark - remove upload script record
- (IBAction)removeRecordScript:(id)sender{
	NSInteger selectedRow = self.appInfoTableView.selectedRow;
	RecordscriptApp *app = [self.appListArr objectAtIndex:selectedRow];
//	[self saveRecordScriptResultForApp:app];
	
	NSMutableArray *arrM = [NSMutableArray arrayWithArray:app.scriptList];
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	[app.scriptList enumerateObjectsUsingBlock:^(RecordScriptUploadResult *result, NSUInteger idx, BOOL *stop) {
		if (result.checked) {
			[indexSet addIndex:idx];
			[arrM removeObject:result];
		}
	}];
	app.scriptList = arrM;
	arrM = nil;
	self.scriptUploadViewController.scriptList = app.scriptList;
	[self.scriptUploadViewController.tableView removeRowsAtIndexes:indexSet	withAnimation:NSTableViewAnimationEffectFade];
	[self updateScriptView];
}
#pragma mark - login
- (IBAction)clickedLogin:(id)sender {
	if (!self.isLogin) {
		AppiumAppDelegate *appDelegate = [NSApplication sharedApplication].delegate;
		[appDelegate displayPreferenceWindow:nil];
	}
}
#pragma mark - change log state and update app info
- (void)logStateDidChanged:(NSNotification *)notification
{
	[self setupUserInfo];
}
@end
