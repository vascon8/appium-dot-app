//
//  AppiumMonitorWindowController.m
//  Appium
//
//  Created by Dan Cuellar on 3/3/13.
//  Copyright (c) 2013 Appium. All rights reserved.
//

#import "AppiumMonitorWindowController.h"
#import "AppiumAppDelegate.h"
#import "ANSIUtility.h"
#import "Utility.h"

@implementation AppiumMonitorWindowController

-(id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class AppiumMonitorWindowController"
                                 userInfo:nil];
    return nil;
}

- (id)initWithWindow:(NSWindow *)window
{
	self = [super initWithWindow:window];
	
	if (self)
	{
		self.inspectorIsLaunching = NO;
	}
	
	return self;
}

-(void) windowDidLoad
{
    [super windowDidLoad];
	
	// launch the menu bar icon
	_menuBarManager = [AppiumMenuBarManager new];
	[[self model] addObserver:_menuBarManager forKeyPath:@"isServerRunning" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSApplication sharedApplication] terminate:self];
}

-(AppiumModel*) model { return [(AppiumAppDelegate*)[[NSApplication sharedApplication] delegate] model]; }

- (IBAction) launchButtonClicked:(id)sender
{
    if (!self.model.doctorSocketIsConnected && [self.model startServer])
    {
		[self closeAllPopovers];
        [self performSelectorInBackground:@selector(errorLoop) withObject:nil];
        [self performSelectorInBackground:@selector(readLoop) withObject:nil];
        [self performSelectorInBackground:@selector(exitWait) withObject:nil];
    }
}

-(IBAction)doctorButtonClicked:(id)sender
{
	// Prevent startDoctor from being run for now due to issue #374
	[self.model startExternalDoctor];
	return;
	
    if ([self.model startDoctor])
    {
		[self closeAllPopovers];
        [self performSelectorInBackground:@selector(errorLoop) withObject:nil];
        [self performSelectorInBackground:@selector(readLoop) withObject:nil];
        [self performSelectorInBackground:@selector(exitWait) withObject:nil];
    }
}

-(void) readLoop
{
    NSFileHandle *serverStdOut = [self.model.serverTask.standardOutput fileHandleForReading];
    NSMutableDictionary *previousAttributes = [NSMutableDictionary new];
    while(self.model.serverTask.isRunning)
    {
        NSData *data = [serverStdOut availableData];

        NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        NSAttributedString *attributedString = [ANSIUtility processIncomingStream:string withPreviousAttributes:&previousAttributes];
        [self performSelectorOnMainThread:@selector(appendToLog:) withObject:attributedString waitUntilDone:YES];
    }
	[serverStdOut closeFile];
}

-(void) errorLoop
{
	NSFileHandle *serverStdErr = [self.model.serverTask.standardError fileHandleForReading];
    NSMutableDictionary *previousAttributes = [NSMutableDictionary new];
	while(self.model.serverTask.isRunning)
    {
        NSData *data = [serverStdErr availableData];

        NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        NSAttributedString *attributedString = [ANSIUtility processIncomingStream:string withPreviousAttributes:&previousAttributes];
        [self performSelectorOnMainThread:@selector(appendToLog:) withObject:attributedString waitUntilDone:YES];
    }
	[serverStdErr closeFile];
}

-(void) appendToLog:(NSAttributedString*)string
{
	BOOL scrollToBottom;
	
	if (!self.model.general.forceScrollLog)
	{
		// Check if the scroll position is within 30 pixels of the bottom of the view
		scrollToBottom = (((self.logTextView.visibleRect.origin.y + self.logTextView.superview.frame.size.height) - self.logTextView.bounds.size.height) >= -30.0f);
	}
	else
	{
		scrollToBottom = YES;
	}
	
	NSTextStorage *textStorage = self.logTextView.textStorage;
	
    [textStorage beginEditing];
    [textStorage appendAttributedString:string];
	
	if ([textStorage length] > self.model.maxLogLength)
	{
		// Remove characters from the start of the log to make space
		[textStorage deleteCharactersInRange:NSMakeRange(0, [string length])];
	}
	
    [textStorage endEditing];
	
	if (scrollToBottom)
	{
		NSRange range = NSMakeRange ([[self.logTextView string] length], 0);
	
		[self.logTextView scrollRangeToVisible: range];
	}
}

-(void) exitWait
{
    [self.model.serverTask waitUntilExit];
    [self.model setIsServerRunning:NO];
}

-(IBAction)chooseAndroidApp:(id)sender
{
	NSString *selectedApp = self.model.android.appPath;

    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	[openDlg setShowsHiddenFiles:YES];
	[openDlg setAllowedFileTypes:[NSArray arrayWithObjects:@"apk", @"zip", nil]];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setPrompt:@"Select Android Application"];
	if (selectedApp == nil || [selectedApp isEqualToString:@"/"])
	{
	    [openDlg setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
	}
	else
	{
		[openDlg setDirectoryURL:[NSURL fileURLWithPath:[selectedApp stringByDeletingLastPathComponent]]];
	}

    if ([openDlg runModal] == NSOKButton)
    {
		selectedApp = [[[openDlg URLs] objectAtIndex:0] path];
		[self.model.android setAppPath:selectedApp];
    }
}

-(IBAction)chooseiOSApp:(id)sender
{
	NSString *selectedApp = self.model.iOS.appPath;
	
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	[openDlg setShowsHiddenFiles:YES];
	[openDlg setAllowedFileTypes:[NSArray arrayWithObjects:@"app", @"zip", @"ipa", nil]];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setPrompt:@"Select iOS Application"];
	if (selectedApp == nil || [selectedApp isEqualToString:@"/"])
	{
	    [openDlg setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
	}
	else
	{
		[openDlg setDirectoryURL:[NSURL fileURLWithPath:[selectedApp stringByDeletingLastPathComponent]]];
	}
	
    if ([openDlg runModal] == NSOKButton)
    {
		selectedApp = [[[openDlg URLs] objectAtIndex:0] path];
		[self.model.iOS setAppPath:selectedApp];
    }
}

-(IBAction)chooseiOSTraceTemplate:(id)sender
{
	NSString *selectedTemplate = self.model.iOS.customTraceTemplatePath;
	
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	[openDlg setShowsHiddenFiles:YES];
	[openDlg setAllowedFileTypes:[NSArray arrayWithObjects:@"tracetemplate", nil]];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setPrompt:@"Select Instruments Trace Templates"];
	if (selectedTemplate == nil || [selectedTemplate isEqualToString:@"/"])
	{
	    [openDlg setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
	}
	else
	{
		[openDlg setDirectoryURL:[NSURL fileURLWithPath:[selectedTemplate stringByDeletingLastPathComponent]]];
	}
	
    if ([openDlg runModal] == NSOKButton)
    {
		selectedTemplate = [[[openDlg URLs] objectAtIndex:0] path];
		[self.model.iOS setCustomTraceTemplatePath:selectedTemplate];
    }
}

- (IBAction)chooseiOSTraceDirectory:(id)sender
{
	NSString *selectedPath = self.model.iOS.traceDirectory;
	NSString *firstCharacter = ([selectedPath length] > 0) ? [selectedPath substringWithRange:NSMakeRange(0, 1)] : nil;
	
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	panel.showsHiddenFiles = YES;
	panel.canChooseDirectories = YES;
	panel.canChooseFiles = NO;
	panel.prompt = @"Select Trace Directory";
	
	if (selectedPath == nil || [selectedPath length] < 1 || [selectedPath isEqualToString:@"/"] || !([firstCharacter isEqualToString:@"/"] || [firstCharacter isEqualToString:@"~"]))
	{
		panel.directoryURL = [NSURL fileURLWithPath:NSHomeDirectory()];
	}
	else
	{
		panel.directoryURL = [NSURL fileURLWithPath:[selectedPath stringByExpandingTildeInPath]];
	}
	
	if ([panel runModal] == NSOKButton)
	{
		self.model.iOS.traceDirectory = [[[panel URLs] objectAtIndex:0] path];
	}
}

-(IBAction)clearLog:(id)sender
{
    [[self logTextView] setString:@""];
}

-(IBAction)displayInspector:(id)sender
{
	[(AppiumAppDelegate*)[[NSApplication sharedApplication] delegate] displayInspector:nil];
}

-(IBAction)chooseXcodePath:(id)sender
{
	NSString *selectedApp = self.model.iOS.xcodePath;
	
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	[openDlg setShowsHiddenFiles:YES];
	[openDlg setAllowedFileTypes:[NSArray arrayWithObjects:@"app", nil]];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setPrompt:@"Select Xcode Application"];
	if (selectedApp == nil || [selectedApp isEqualToString:@"/"])
	{
	    [openDlg setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
	}
	else
	{
		[openDlg setDirectoryURL:[NSURL fileURLWithPath:[selectedApp stringByDeletingLastPathComponent]]];
	}
	
    if ([openDlg runModal] == NSOKButton)
    {
		selectedApp = [[[openDlg URLs] objectAtIndex:0] path];
		[self.model.iOS setXcodePath:selectedApp];
    }
}

-(void) closeAllPopovers
{
	for(NSView* button in [buttonBarView subviews]) {
		if ([button isKindOfClass:[AppiumMonitorWindowPopOverButton class]]) {
			[((AppiumMonitorWindowPopOverButton*)button).popoverController close];
		}
	}
}

@end
