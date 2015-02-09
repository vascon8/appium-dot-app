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
#import "TestWAPrjOutlineViewDataSource.h"

#import "TestWAServerUser.h"
#import "TestWAServerProject.h"

#import "AppiumAppDelegate.h"
#import "TestWAAccountTool.h"
#import "TestWAPreferenceWindowController.h"

#define RecordscriptUploadServerAddress [NSString stringWithFormat:@"%@/attp/upload",TestWAServerPrefix]
#define RecordscriptGetServerProjectAddress [NSString stringWithFormat:@"%@/attp/projects",TestWAServerPrefix]

@interface RecordScriptWindowController ()<NSSplitViewDelegate,NSOutlineViewDelegate,RecordScriptUploadResultViewDelegate>

@property (weak) IBOutlet NSOutlineView *prjOutlineView;
@property (strong) IBOutlet TestWAPrjOutlineViewDataSource *prjOutlineViewDataSource;

@property (weak) IBOutlet NSButton *appInfoRefreshButton;
@property (weak) IBOutlet NSProgressIndicator *appLoadProgressIndicator;

@property (weak) IBOutlet NSButton *scriptAddButton;
@property (weak) IBOutlet NSButton *scriptFistAddButton;
@property (weak) IBOutlet NSButton *scriptRemoveButton;

@property (weak) IBOutlet NSButton *loginButton;

@property (weak) IBOutlet NSView *loginView;
@property (weak) IBOutlet NSTextField *userLabel;
@property (weak) IBOutlet NSButton *logoutButton;
@property (weak) IBOutlet NSBox *loginViewSplitLine;

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
	
	[self.loginButton setHidden:self.isLogin];
	[self.loginView setHidden:!self.isLogin];
	[self.appInfoRefreshButton setHidden:!self.isLogin];
	
	if (_isLogin) {
		self.userLabel.stringValue = [TestWAAccountTool loginUserName];
		
		[self.userLabel sizeToFit];
		[self.logoutButton sizeToFit];
		CGFloat userLabelW = self.userLabel.frame.size.width;
		
		NSRect splitLineF = self.loginViewSplitLine.frame;
		splitLineF.size.height = self.userLabel.frame.size.height;
		splitLineF.origin.x = userLabelW;
		self.loginViewSplitLine.frame = splitLineF;
		
		NSRect logoutBtnF = self.logoutButton.frame;
		logoutBtnF.origin.x = userLabelW + 2.0;
		self.logoutButton.frame = logoutBtnF;
		
		[self loadProjectData];
	}
	else{
		self.prjListArr = nil;
		self.prjOutlineViewDataSource.prjList = nil;
		
		[self.prjOutlineView reloadData];
	}
}
- (void)setupAppData
{
	self.uploadQueue = [[NSOperationQueue alloc]init];
	[self.uploadQueue setMaxConcurrentOperationCount:MaxConcurrentUploadOperation];
	self.scriptUploadViewController.delegate = self;
}
#pragma mark - load project data
- (void)loadProjectData
{
	self.isLoadingApp = YES;
	[self.appLoadProgressIndicator startAnimation:nil];
	[self.appInfoRefreshButton setEnabled:NO];

	NSString *str = [NSString stringWithFormat:@"%@/%@",RecordscriptGetServerProjectAddress,[TestWAAccountTool loginUserID]];
	[TestWAHttpExecutor loadDataWithUrlStr:str handleResultBlock:^(id resultData,NSError *error) {
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
		
		self.prjOutlineViewDataSource.prjList = self.prjListArr;
		[self.prjOutlineView reloadData];
	}];
	
	[self.appLoadProgressIndicator stopAnimation:nil];
	self.isLoadingApp = NO;
	[self.appInfoRefreshButton setEnabled:YES];

}
- (IBAction)refreshAppList:(id)sender {
	if (self.isLoadingApp || !self.isLogin) return;
	[self loadProjectData];
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
		
			NSInteger selectedRow = [self.prjOutlineView selectedRow];
			if (![[self.prjOutlineView itemAtRow:selectedRow] isKindOfClass:[RecordscriptApp class]]) return ;
			
			RecordscriptApp *app = [self.prjOutlineView itemAtRow:selectedRow];
		
			NSInteger uploadIndex = [self setupAppRecordScriptUploadResult:app withScriptName:[scriptFileUrl lastPathComponent]];
			
			NSBlockOperation *uploadOp = [NSBlockOperation blockOperationWithBlock:^{
				[self uploadScriptWithPostParams:[self setupAppParams:app withScriptFileUrl:scriptFileUrl] app:app uploadIndex:uploadIndex];
			}];
			[self.uploadQueue addOperation:uploadOp];
			[self updateScriptView];
		}
	}];
}
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
	
	[self updateScriptResultTableViewWithApp:app];
	
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
#pragma mark - outlineView delegate
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	if ([outlineView parentForItem:item] == nil) {
		NSTextField *prjTextField = [outlineView makeViewWithIdentifier:@"PrjTextField" owner:self];
		NSString *name = [item valueForKey:@"name"];
		NSInteger apps = [[item valueForKey:@"apps"] count];
		name = [NSString stringWithFormat:@"%@ (%ld)",name,apps];
		prjTextField.stringValue = name;
		return prjTextField;
	}
	else{
		NSTableCellView *cellView = [outlineView makeViewWithIdentifier:@"AppCellView" owner:self];
		cellView.textField.stringValue = [item valueForKey:@"name"];
		NSString *imgName = @"apple";
		NSString *type = [item valueForKey:@"type"];
		if ([[type lowercaseString] isEqualToString:@"android"]) imgName = @"android";
		[cellView.imageView setImage:[NSImage imageNamed:imgName]];
		return cellView;
	}
}
- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	[self updateScriptView];
}

#pragma mark - scriptUploadViewController
- (void)updateScriptResultTableViewWithApp:(RecordscriptApp *)app
{
	self.scriptUploadViewController.scriptList = [NSArray arrayWithArray:app.scriptList];
	if (self.scriptUploadViewController.scriptList.count>0) [self.scriptUploadViewController.view setHidden:NO];
	[self.scriptUploadViewController.tableView reloadData];
}
#pragma mark - remove upload script record
- (IBAction)removeRecordScript:(id)sender{
	NSInteger selectedRow = [self.prjOutlineView selectedRow];
	if (![[self.prjOutlineView itemAtRow:selectedRow] isKindOfClass:[RecordscriptApp class]]) return ;
	
	RecordscriptApp *app = [self.prjOutlineView itemAtRow:selectedRow];
	
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
#pragma mark - update scriptView
- (void)updateScriptView
{
	NSInteger selectedRow = self.prjOutlineView.selectedRow;
	
	if (selectedRow > self.prjOutlineView.numberOfRows-1) return;
	
	id item = [self.prjOutlineView itemAtRow:selectedRow];
	if ([self.prjOutlineView parentForItem:item]) {
		RecordscriptApp *app = [self.prjOutlineView itemAtRow:selectedRow];
		if (app.scriptList.count>0) {
			[self showScriptView];
			self.scriptUploadViewController.scriptList = app.scriptList;
			[self.scriptUploadViewController.tableView reloadData];
		}
		else{
			[self hideScriptViewEnableFirstAddButton:YES];
		}
	}
	else{
		[self hideScriptViewEnableFirstAddButton:NO];
	}
	
}
- (void)showScriptView
{
	[self.scriptUploadViewController.tableView setHidden:NO];
	[self.scriptFistAddButton setHidden:YES];
	[self.scriptAddButton setHidden:NO];
	[self.scriptRemoveButton setHidden:NO];
	
	[self updateRemoveButton];
}
- (void)hideScriptViewEnableFirstAddButton:(BOOL)enable
{
	[self.scriptUploadViewController.tableView setHidden:YES];
	[self.scriptFistAddButton setHidden:NO];
	[self.scriptAddButton setHidden:YES];
	[self.scriptRemoveButton setHidden:YES];
	
	[self.scriptFistAddButton setEnabled:enable];
}
- (void)updateRemoveButton
{
	NSInteger selectedRow = [self.prjOutlineView selectedRow];
	if (![[self.prjOutlineView itemAtRow:selectedRow] isKindOfClass:[RecordscriptApp class]]) return ;
	
	RecordscriptApp *app = [self.prjOutlineView itemAtRow:selectedRow];
	
	for (RecordScriptUploadResult *result in app.scriptList) {
		if (result.checked) {
			[self.scriptRemoveButton setEnabled:YES];
			return;
		}
	}
	[self.scriptRemoveButton setEnabled:NO];
}
#pragma mark - login
- (IBAction)clickedLogin:(id)sender {
	if (!self.isLogin) {
		[[self appDelegate]displayPreferenceWindow:nil];
	}
}
- (void)logStateDidChanged:(NSNotification *)notification
{
	[self setupUserInfo];
}
- (IBAction)clickedLogout:(id)sender {
	if (self.isLogin) {
		[TestWAAccountTool logout];
		[self setupUserInfo];
	}
}

#pragma mark - recordscript upload result view delegate
- (void)recordscriptUploadResultView:(RecordScriptUploadResultViewController *)recordscriptUploadResultView checkedScriptRow:(BOOL)checkedScriptRow
{
	[self updateRemoveButton];
}
#pragma mark - splitview delegate
- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (proposedMinimumPosition < 160) {
        proposedMinimumPosition = 160;
    }
    return proposedMinimumPosition;
}
#pragma mark - private
- (AppiumAppDelegate *)appDelegate
{
	return [NSApplication sharedApplication].delegate;
}
@end
