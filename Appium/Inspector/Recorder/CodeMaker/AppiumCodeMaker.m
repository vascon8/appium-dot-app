//
//  AppiumCodeMaker.m
//  Appium
//
//  Created by Dan Cuellar on 4/10/13.
//  Copyright (c) 2013 Appium. All rights reserved.
//

#import "AppiumCodeMaker.h"

#import "AppiumPreferencesFile.h"
#import "AppiumCodeMakerPlugins.h"

#import "AppiumAppDelegate.h"

@class AppiumCodeMakerAction;


@class AppiumCodeMakerAction;

@implementation AppiumCodeMaker

- (id)init
{
    self = [super init];
    if (self) {
		_actions = [NSMutableArray new];
        _undoneActions = [NSMutableArray new];
        self.canUndo = NO;
        self.canRedo = NO;
		_plugins = [[NSDictionary alloc] initWithObjectsAndKeys:
					[[AppiumCodeMakerCSharpPlugin alloc] initWithCodeMaker:self], @"C#",
					[[AppiumCodeMakerJavaPlugin alloc] initWithCodeMaker:self], @"Java",
					[[AppiumCodeMakerNodePlugin alloc] initWithCodeMaker:self], @"node.js",
					[[AppiumCodeMakerObjectiveCPlugin alloc] initWithCodeMaker:self], @"Objective-C",
					[[AppiumCodeMakerPythonPlugin alloc] initWithCodeMaker:self], @"Python",
					[[AppiumCodeMakerRubyPlugin alloc] initWithCodeMaker:self], @"Ruby",
					nil];
    }
    return self;
}

- (void) awakeFromNib
{
	_fragaria = [[MGSFragaria alloc] init];
	[_fragaria setObject:self forKey:MGSFODelegate];
	[self setSyntaxDefinition:[[NSUserDefaults standardUserDefaults] stringForKey:APPIUM_PLIST_INSPECTOR_CODEMAKER_LANGUAGE]];
	[_fragaria embedInView:_contentView];
	[_fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOIsSyntaxColoured];
	[_fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOShowLineNumberGutter];
	[self renderAll];
}

#pragma mark - Properties

-(AppiumCodeMakerPlugin*) activePlugin { return _activePlugin; }
-(NSArray*) allPlugins { return [_plugins allKeys]; }
-(NSString*) syntaxDefinition { return _activePlugin.name; }
-(NSNumber*) useBoilerPlate { return [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:APPIUM_PLIST_INSPECTOR_USES_CODEMAKER_BOILERPLATE]]; }
-(NSNumber*) useXPathOnly { return [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:APPIUM_PLIST_INSPECTOR_USES_XPATH_ONLY]]; }


-(void) setActivePlugin:(AppiumCodeMakerPlugin*)plugin
{
	_activePlugin = plugin;
	_renderedActions = @"";
	[self renderAll];
}

-(void)setSyntaxDefinition:(NSString *)syntaxDefinition
{
	[self setActivePlugin:(AppiumCodeMakerPlugin*)[_plugins objectForKey:syntaxDefinition]];
	[[NSUserDefaults standardUserDefaults] setObject:syntaxDefinition forKey:APPIUM_PLIST_INSPECTOR_CODEMAKER_LANGUAGE];
	[_fragaria setObject:(![syntaxDefinition isEqualToString:@"node.js"]) ? syntaxDefinition : @"JavaScript" forKey:MGSFOSyntaxDefinitionName];

	if ([DEFAULTS boolForKey:APPIUM_PLIST_USE_ExportRecordScripts_DIRECTORY] && self.canUndo) self.exportScriptName = [self scriptName];
}

-(void) setUseBoilerPlate:(NSNumber *)useBoilerPlate
{
	[[NSUserDefaults standardUserDefaults] setBool:[useBoilerPlate boolValue] forKey:APPIUM_PLIST_INSPECTOR_USES_CODEMAKER_BOILERPLATE];
	[self renderAll];
}

-(void) setUseXPathOnly:(NSNumber *)useXPathOnly
{
	[[NSUserDefaults standardUserDefaults] setBool:[useXPathOnly boolValue] forKey:APPIUM_PLIST_INSPECTOR_USES_XPATH_ONLY];
	[self renderAll];
}

#pragma mark - export script
- (void)exportRecordScripts
{
	NSString *dir = [DEFAULTS valueForKey:APPIUM_PLIST_ExportRecordScripts_DIRECTORY];
	if (![[dir lastPathComponent] isEqualToString:@"RecordScriptByTestQ"]){
		dir = [dir stringByAppendingPathComponent:@"RecordScriptByTestQ/"];
	}
	
	NSFileManager *mgr = [NSFileManager defaultManager];
	
	[mgr createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
	
	if (![self.string writeToFile:[dir stringByAppendingPathComponent:[self exportScriptName]] atomically:YES encoding:NSUTF8StringEncoding error:nil])
	{
		NSAlert *errorAlert = [NSAlert alertWithMessageText:@"Export Record Script Error"
											  defaultButton:@"OK"
											alternateButton:nil
												otherButton:nil
								  informativeTextWithFormat:@"The file could not be saved. Please check your directory write permissions and ensure that the disk is not full."];
		[errorAlert runModal];
	}
}
- (NSString *)scriptName
{
	AppiumAppDelegate *delegate = (AppiumAppDelegate*)([NSApplication sharedApplication].delegate);
	AppiumModel *model = [delegate model];
	
	NSString *extension = self.activePlugin.fileExtension;
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	formatter.dateFormat = @"MMddHHmm";
	NSString *date = [formatter stringFromDate:[NSDate date]];
	NSString *platformName = ((model.platform==AppiumiOSPlatform) ? @"IOS" : @"Android");
	
	NSString *name = [[((model.platform==AppiumiOSPlatform) ? model.iOS.appPath : model.android.appPath) lastPathComponent] stringByReplacingOccurrencesOfString:((model.platform==AppiumiOSPlatform) ? @".app" : @".apk") withString:[NSString stringWithFormat:@"_%@_%@.%@",platformName,date,extension]];
	
	return name;
}
- (NSString *)exportScriptName
{
	if (!_exportScriptName) {
		_exportScriptName = [self scriptName];
	}
	return _exportScriptName;
}
-(void) render
{
	[self setString:[NSString stringWithFormat:@"%@%@%@", ([self.useBoilerPlate boolValue] ? _activePlugin.preCodeBoilerplate : @""), _renderedActions,([self.useBoilerPlate boolValue] ?_activePlugin.postCodeBoilerplate : @"")]];
	[self setAttributedString:[[NSAttributedString alloc] initWithString:self.string]];
	[_fragaria setString:self.string];
	
	if ([DEFAULTS boolForKey:APPIUM_PLIST_USE_ExportRecordScripts_DIRECTORY] && self.canUndo)	[self exportRecordScripts];
}

-(void) renderAll
{
	_renderedActions = @"";
	for(int i=0; i < _actions.count; i++)
	{
		AppiumCodeMakerAction *action = [_actions objectAtIndex:i];
		_renderedActions = [_renderedActions stringByAppendingString:[_activePlugin renderAction:action]];
	}
	[self render];
}

#pragma mark - Public Methods

-(void) reset
{
	[_actions removeAllObjects];
    [_undoneActions removeAllObjects];
    [self setCanUndo:NO];
    [self setCanRedo:NO];
	[self renderAll];

}

-(void) undoLast
{
    if (_actions.count > 0)
    {
        [self setCanRedo:YES];
        [_undoneActions addObject:[_actions lastObject]];
        [_actions removeLastObject];
        [self renderAll];
        [self setCanUndo:(_actions.count > 0)];
    }
}

-(void) redoLast
{
    if (_undoneActions.count > 0)
    {
        [self setCanUndo:YES];
        [_actions addObject:[_undoneActions lastObject]];
        [_undoneActions removeLastObject];
        [self renderAll];
        [self setCanRedo:(_undoneActions.count > 0)];
    }
}

-(void) addAction:(AppiumCodeMakerAction*)action
{
    [self setCanUndo:YES];
	[_actions addObject:action];
	_renderedActions =[_renderedActions stringByAppendingString:[_activePlugin renderAction:action]];
	[self render];
    [_undoneActions removeAllObjects];
    [self setCanRedo:NO];
}

-(void) replay:(SERemoteWebDriver*)driver
{
  	for(int i=0; i < _actions.count; i++)
	{
        AppiumCodeMakerAction *action = [_actions objectAtIndex:i];
        action.block(driver);
    }
}

#pragma mark - NSCoding Implementation
-(id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [self init])
    {
        _actions = [aDecoder decodeObjectForKey:@"actions"];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_actions forKey:@"actions"];
}

@end
