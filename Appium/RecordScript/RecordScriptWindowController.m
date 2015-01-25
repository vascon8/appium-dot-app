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

@interface RecordScriptWindowController ()<NSTableViewDataSource,NSTableViewDelegate>
@property NSMutableArray *appListArr;
@property BOOL isLoadingApp;
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
	
	[self.chooseScriptButton setHidden:YES];
	
	[self.customviewChooseScriptButton setHidden:NO];
	[self.scriptNameTextField setHidden:YES];
	[self.uploadProgressIndicator setHidden:YES];
	[self.statusImageView setHidden:YES];
	
	[self loadAppData];
	
	self.recordscriptAppTableView.delegate = self;
	self.recordscriptAppTableView.dataSource = self;
}
#pragma mark - load data
- (IBAction)refreshAppList:(id)sender {
	[self loadAppData];
}

- (void)loadAppData
{
	[self.loadDataProgressIndicator startAnimation:nil];
	self.isLoadingApp = YES;
	[self.refreshAppListButton setEnabled:NO];
	
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
	self.isLoadingApp = NO;
	[self.refreshAppListButton setEnabled:YES];
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
	NSString *path = [postParams.urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:path];
	NSError *error = nil;
	NSNumber *contentLen = [[[NSFileManager defaultManager]attributesOfItemAtPath:postParams.urlStr error:&error] objectForKey:NSFileSize];
	if (error) {
		NSLog(@"contlen error:%@",error);
	}
	NSLog(@"inputstream:%@\ncontentLen:%@",inputStream,contentLen);
		
	NSMutableURLRequest	*requestM = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[RecordscriptUploadServerAddress stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:[postParams keyedDictFromModel] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
		[formData appendPartWithInputStream:inputStream name:postParams.name fileName:postParams.filename length:[contentLen integerValue] mimeType:@"text/html"];
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
	
//	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0f];
//	[request setHTTPMethod:@"POST"];
//	
////	NSString *post =[self jsonStringFromDictionary:postParams];
//    [request setValue:@"application/json, image/png" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//	
////	[request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
//	[request setHTTPBody:bodyData];
//	
//	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//		NSLog(@"response:%@",response);
//		NSLog(@"error:%@",connectionError);
//	}];
}
- (IBAction)chooseScriptButtonClicked:(NSButton *)sender {
	NSOpenPanel* chooseScriptPanlel = [NSOpenPanel openPanel];
	[chooseScriptPanlel setMessage:@"请选择要上传的脚本"];
	[chooseScriptPanlel setPrompt:@"确认上传"];
	
	[chooseScriptPanlel setFrameTopLeftPoint:self.window.frame.origin];
	[chooseScriptPanlel setDirectoryURL:[NSURL URLWithString:[DEFAULTS valueForKey:APPIUM_PLIST_ExportRecordScripts_DIRECTORY]]];
    [chooseScriptPanlel setCanChooseFiles:YES];

	[chooseScriptPanlel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		NSString *filename = [[chooseScriptPanlel URLs][0] lastPathComponent];
		if (result == NSFileHandlingPanelOKButton && filename) {
			
			[self.customviewChooseScriptButton setHidden:YES];
			
			[self.scriptNameTextField setHidden:NO];
			[self.statusImageView setHidden:NO];
			[self.uploadProgressIndicator setHidden:NO];
			
			[self.chooseScriptButton setHidden:NO];
			[self.chooseScriptButton setEnabled:YES];
			
			self.scriptNameTextField.stringValue = filename;
//			NSData *bodyData = [NSData dataWithContentsOfURL:[chooseScriptPanlel URLs][0]];
			
			RecordScriptUploadParam *param = [[RecordScriptUploadParam alloc]init];
//			param.urlStr = [chooseScriptPanlel URLs][0];
			NSURL *fileUrl = [chooseScriptPanlel URLs][0];
			NSString *path = [fileUrl path];
			param.urlStr = path;
			
			param.filename = filename;
			NSInteger selectedRow = self.recordscriptAppTableView.selectedRow;
			RecordscriptApp *rc = (RecordscriptApp *)self.appListArr[selectedRow];
			param.appId = rc.id;
			param.name = rc.name;
			param.language = [self scriptLanguage:filename];
			
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
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if ([self.recordscriptAppTableView numberOfRows] > 0) {
		if (!self.customviewChooseScriptButton.isEnabled) {
			[self.customviewChooseScriptButton setEnabled:YES];
		}
	}
	else{
		[self.customviewChooseScriptButton setEnabled:NO];
		[self.chooseScriptButton setEnabled:NO];
	}
}
@end
