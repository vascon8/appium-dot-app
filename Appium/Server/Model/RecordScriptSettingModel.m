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
- (NSString *)testWAServerAddr
{
	return [DEFAULTS valueForKey:APPIUM_PLIST_TestWA_ServerAddress];
}
- (void)setTestWAServerAddr:(NSString *)testWAServerAddr
{
	[DEFAULTS setValue:testWAServerAddr forKey:APPIUM_PLIST_TestWA_ServerAddress];
}
- (NSNumber *)testWASererPort
{
	return [NSNumber numberWithInt:[[DEFAULTS valueForKeyPath:APPIUM_PLIST_TestWA_ServerPort]intValue]];
}
- (void)setTestWASererPort:(NSNumber *)testWASererPort
{
	[DEFAULTS setValue:testWASererPort forKey:APPIUM_PLIST_TestWA_ServerPort];
}
@end
