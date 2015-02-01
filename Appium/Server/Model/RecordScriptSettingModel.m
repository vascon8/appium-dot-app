//
//  RecordScriptSettingModel.m
//  Appium
//
//  Created by xinliu on 15-1-27.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "RecordScriptSettingModel.h"
#import "AppiumPreferencesFile.h"
#import "AppiumModel.h"

@implementation RecordScriptSettingModel

- (BOOL)useExportscriptsDirectory { return [DEFAULTS boolForKey:APPIUM_PLIST_USE_ExportRecordScripts_DIRECTORY]; }
- (void)setUseExportscriptsDirectory:(BOOL)useExportscriptsDirectory{ [DEFAULTS setBool:useExportscriptsDirectory forKey:APPIUM_PLIST_USE_ExportRecordScripts_DIRECTORY]; }

- (NSString *) exportscriptsDirectory { return [DEFAULTS stringForKey:APPIUM_PLIST_ExportRecordScripts_DIRECTORY]; }
- (void) setExportscriptsDirectory:(NSString *)exportscriptsDirectory {
	NSString *tempDir = exportscriptsDirectory;
	if (![[tempDir lastPathComponent] isEqualToString:EXPORTRECORDSCRIPTLASTPATHCOMPONENT]) tempDir = [tempDir stringByAppendingPathComponent:EXPORTRECORDSCRIPTLASTPATHCOMPONENT];
	[DEFAULTS setValue:tempDir forKey:APPIUM_PLIST_ExportRecordScripts_DIRECTORY];
}

- (NSString *)uploadExportscriptsServerAddr
{
	return [DEFAULTS valueForKey:APPIUM_PLIST_Upload_ExportRecordScripts_ServerAddress];
}
- (void)setUploadExportscriptsServerAddr:(NSString *)uploadExportscriptsServerAddr
{
	[DEFAULTS setValue:uploadExportscriptsServerAddr forKey:APPIUM_PLIST_Upload_ExportRecordScripts_ServerAddress];
}
//- (NSNumber *)uploadExportscriptsServerPort
//{
//	
//}
//- (void)setUploadExportscriptsServerPort:(NSNumber *)uploadExportscriptsServerPort
//{
//	
//}
//- (NSString *)getServerAppAddr
//{
//	return [DEFAULTS valueForKey:APPIUM_PLIST_GetServerApp_Address];
//}
//- (void)setGetServerAppAddr:(NSString *)getServerAppAddr
//{
//	[DEFAULTS setValue:getServerAppAddr forKey:APPIUM_PLIST_GetServerApp_Address];
//}
//- (void)setGetServerAppPort:(NSNumber *)getServerAppPort
//{
//	[DEFAULTS setValue:getServerAppPort forKey:APPIUM_PLIST_GetServerApp_Port];
//}
//- (NSNumber *)getServerAppPort
//{
//	return [DEFAULTS valueForKey:APPIUM_PLIST_GetServerApp_Port];
//}
@end
