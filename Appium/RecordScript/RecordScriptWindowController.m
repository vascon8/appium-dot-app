//
//  RecordScriptWindowController.m
//  Appium
//
//  Created by xinliu on 15-1-21.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "RecordScriptWindowController.h"
#import "AppiumPreferencesFile.h"

@interface RecordScriptWindowController ()

@end

@implementation RecordScriptWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
		
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}
- (IBAction)saveButtonClicked:(NSButton *)sender {
	NSOpenPanel* chooseScriptPanlel = [NSOpenPanel openPanel];
	[chooseScriptPanlel setMessage:@"请选择要上传的脚本"];
	[chooseScriptPanlel setPrompt:@"确定"];
	[chooseScriptPanlel setDirectoryURL:[NSURL URLWithString:[DEFAULTS valueForKey:APPIUM_PLIST_ExportRecordScripts_DIRECTORY]]];
    
    // Enable the selection of files in the dialog.
    [chooseScriptPanlel setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [chooseScriptPanlel setCanChooseDirectories:YES];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
	[chooseScriptPanlel beginSheet:self.window completionHandler:^(NSModalResponse returnCode) {
		NSLog(@"url:%@",[chooseScriptPanlel URLs]);
		if (returnCode == NSModalResponseContinue) {
			[self.appNameField setStringValue:[chooseScriptPanlel URLs][0]];
			NSLog(@"url2:%@",[chooseScriptPanlel URLs]);
		}
	}];
	[chooseScriptPanlel runModal];
}

@end
