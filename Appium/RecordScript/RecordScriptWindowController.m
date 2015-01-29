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
#import "AFNetworking.h"

#import "RecordScriptUploadResultViewController.h"
#import "RecordScriptUploadResult.h"

@interface RecordScriptWindowController ()<NSTableViewDataSource,NSTableViewDelegate>

@property NSMutableArray *appListArr;
@property BOOL isLoadingApp;
@property NSView *scriptUploadResultView;
@property RecordScriptUploadResultViewController *scriptUploadViewController;

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
	[self setupData];
}
- (void)setupViews
{
	[self.chooseScriptButton setHidden:YES];
	[self.firstChooseScriptButton setHidden:NO];
	RecordScriptUploadResultViewController *controller = [[RecordScriptUploadResultViewController alloc]initWithNibName:@"RecordScriptUploadResultView" bundle:nil];
	self.scriptUploadResultView = controller.view;
	CGRect frame = self.scriptInfoView.bounds;
//	frame.origin.y = frame.size.height-self.scriptUploadResultView.bounds.size.height;
	self.scriptUploadResultView.frame = frame;
	self.scriptUploadViewController = controller;
	[self.scriptInfoView addSubview:controller.view];
	[self.scriptUploadResultView setHidden:YES];
}
- (void)setupData
{
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
	for (int i=0; i<6; i++) {
		RecordscriptApp *app = [[RecordscriptApp alloc]init];
		app.type = i%2 ? @"IOS" : @"Android";
		app.name = [NSString stringWithFormat:@"App %d",i+1];
		[arr addObject:app];
	}
	self.appListArr = arr;
	[self.appInfoTableView reloadData];
	
	//	[self loadAppData];
	
	self.appInfoTableView.delegate = self;
	self.appInfoTableView.dataSource = self;
}
#pragma mark - load data
- (IBAction)refreshAppList:(id)sender {
	[self loadAppData];
}

- (void)loadAppData
{
	[self.loadAppProgressIndicator startAnimation:nil];
	self.isLoadingApp = YES;
	[self.appInfoRefreshButton setEnabled:NO];
	
//	NSString *str =@"https://openapi.youku.com/v2/videos/by_category.json?client_id=ecb276dff376b7e2";
	NSString *str = [RecordscriptGetServerAppAddress stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
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
			[self.appInfoTableView reloadData];
		}
	}
	else if (resultData == nil){
		NSLog(@"no data found");
	}
	else{
		NSLog(@"%@",error);
	}
	
	[self.loadAppProgressIndicator stopAnimation:nil];
	self.isLoadingApp = NO;
	[self.appInfoRefreshButton setEnabled:YES];
}
- (void)handleJsonResult:(NSDictionary *)resultDict
{
//	NSArray *resultArr = resultDict[@"videos"];
	NSMutableArray *tempArrM = [NSMutableArray arrayWithCapacity:resultDict.count];
	for (NSDictionary *dict in resultDict) {
		RecordscriptApp *rc = [RecordscriptApp objectWithKeyedDict:dict];
//		rc.name = rc.title;
//		rc.type = rc.category;
		[tempArrM addObject:rc];
	}
	self.appListArr = tempArrM;
}
#pragma mark - upload record script
- (void)uploadScriptWithParams2:(RecordScriptUploadParam *)postParams
{
	AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
	mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
	NSError *error = nil;
	
	[mgr POST:[RecordscriptUploadServerAddress stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:postParams constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
		
		[formData appendPartWithFileURL:[NSURL URLWithString:postParams.urlStr] name:postParams.name fileName:postParams.filename mimeType:@"text/html" error:NULL];
		
	} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		NSLog(@"success:%@",responseObject);
		NSLog(@"operation:%@",operation);
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
		NSLog(@"error:%@",error);
		NSLog(@"operation:%@",operation);
		
	}];
}
- (void)uploadScriptWithParams:(RecordScriptUploadParam *)postParams
{
	NSInteger selectedRow = self.appInfoTableView.selectedRow;
	RecordscriptApp *app = [self.appListArr objectAtIndex:selectedRow];
	self.scriptUploadViewController.scriptList = app.scriptList;
	if (self.scriptUploadViewController.scriptList.count>0) [self.scriptUploadViewController.view setHidden:NO];
	[self.scriptUploadViewController.tableView reloadData];
	
	NSString *path = [postParams.urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:path];
	NSError *error = nil;
	NSNumber *contentLen = [[[NSFileManager defaultManager]attributesOfItemAtPath:postParams.urlStr error:&error] objectForKey:NSFileSize];
	if (error) {
		NSLog(@"contlen error:%@",error);
	}
	NSLog(@"inputstream:%@\ncontentLen:%@",inputStream,contentLen);
		
	NSMutableURLRequest	*requestM = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[RecordscriptUploadServerAddress stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:[postParams keyedDictFromModel] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//		[formData appendPartWithInputStream:inputStream name:postParams.name fileName:postParams.filename length:[contentLen integerValue] mimeType:@"text/html"];
		
		[formData appendPartWithFileURL:[NSURL URLWithString:path] name:postParams.name fileName:postParams.filename mimeType:@"text/html" error:NULL];
	} error:&error];
	
	if (error) {
		NSLog(@"request error:%@",error);
	}
	
	AFURLSessionManager *mgr = [[AFURLSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
	NSProgress *progress = nil;
	
	NSURLSessionUploadTask *uploadTask = [mgr uploadTaskWithStreamedRequest:requestM progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
		NSLog(@"response:%@",response);
		NSLog(@"resObj:%@",responseObject);
//		if (error) {
//			NSLog(@"failed:%@",error);
//		}
//		else{
//			NSLog(@"success:%@",responseObject);
//		}
	}];
	
	[uploadTask resume];
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
			NSString *scriptName = [[chooseScriptPanlel URLs][0] lastPathComponent];
			
			if (!self.firstChooseScriptButton.isHidden) {
				[self.firstChooseScriptButton setHidden:YES];
				
				[self.chooseScriptButton setHidden:NO];
				[self.chooseScriptButton setEnabled:YES];
			}
		
			NSInteger selectedRow = self.appInfoTableView.selectedRow;
			RecordscriptApp *rc = (RecordscriptApp *)self.appListArr[selectedRow];
			
			NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:rc.scriptList.count+1];
			if (rc.scriptList) [arrM addObjectsFromArray:rc.scriptList];
			RecordScriptUploadResult *result = [RecordScriptUploadResult new];
			result.scriptName = scriptName;
			[arrM addObject:result];
			rc.scriptList = arrM;
			
//			self.scriptNameTextField.stringValue = filename;
//			NSData *bodyData = [NSData dataWithContentsOfURL:[chooseScriptPanlel URLs][0]];
			
			RecordScriptUploadParam *param = [[RecordScriptUploadParam alloc]init];
//			param.urlStr = [chooseScriptPanlel URLs][0];
			NSURL *fileUrl = [chooseScriptPanlel URLs][0];
			NSString *path = [fileUrl path];
			param.urlStr = path;
			
			param.filename = scriptName;
			param.appId = rc.id;
			param.name = rc.name;
			param.language = [self scriptLanguage:scriptName];
			
			NSLog(@"%@",param);
			
			[self uploadScriptWithParams:param];
		}
	}];
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
        if (self.chooseScriptButton.isEnabled) [self.chooseScriptButton setEnabled:NO];
        if (self.firstChooseScriptButton.isEnabled) [self.firstChooseScriptButton setEnabled:NO];
    }
    
	return rows;
}
#pragma mark - tableview delegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView	 *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
	RecordscriptApp *rc = [self.appListArr objectAtIndex:row];
	cellView.textField.stringValue = rc.name;
	NSString *imageName = @"apple";
	if ([rc.type isEqualToString:@"Android"]) imageName = @"android";
	[cellView.imageView setImage:[NSImage imageNamed:imageName]];
	return cellView;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if ([self.appInfoTableView numberOfRows] > 0 && !self.firstChooseScriptButton.isEnabled) {
		[self.firstChooseScriptButton setEnabled:YES];
	}
	
	NSInteger selectedRow = self.appInfoTableView.selectedRow;
	RecordscriptApp *app = [self.appListArr objectAtIndex:selectedRow];
	if (app.scriptList.count>0) {
		[self.scriptUploadResultView setHidden:NO];
		[self.firstChooseScriptButton setHidden:YES];
		[self.chooseScriptButton setHidden:NO];
		
		self.scriptUploadViewController.scriptList = app.scriptList;
		[self.scriptUploadViewController.tableView reloadData];
	}
	else{
		[self.scriptUploadResultView setHidden:YES];
		[self.firstChooseScriptButton setHidden:NO];
		[self.chooseScriptButton setHidden:YES];
	}
}
@end
