//
//  AppiumUpgrader.m
//  Appium
//
//  Created by Dan Cuellar on 3/7/13.
//  Copyright (c) 2013 Appium. All rights reserved.
//

#import "AppiumUpdater.h"

#import "AppiumInstallationWindowController.h"
#import "Utility.h"

#pragma mark - Constants

#define UPDATE_INFO_URL @"https://raw.github.com/appium/appium.io/master/autoupdate/update.json"
#define APPIUM_PACKAGE_VERSION_URL @"https://raw.github.com/appium/appium/master/package.json"

#pragma mark - Appium Updater

AppiumMainWindowController *mainWindowController;
NSString* upgradeUrl;

@implementation AppiumUpdater

- (id)initWithAppiumMainWindowController:(AppiumMainWindowController*)windowController
{
    self = [super init];
    if (self) {
        mainWindowController = windowController;
		upgradeUrl = @"https://bitbucket.org/appium/appium.app/downloads/appium.dmg";
    }
    return self;
}

-(void) checkForUpdates:(id)sender
{
	BOOL alertOnNoUpdates = sender != nil;
	BOOL updatesAvailable = NO;
//    updatesAvailable |= [self checkForAppUpdate];
    updatesAvailable |= [self checkForPackageUpdate];
	if (alertOnNoUpdates && !updatesAvailable)
	{
		NSAlert *alert = [NSAlert new];
		[alert setMessageText:@"没有可用的更新"];
		[alert setInformativeText:@"已经是最新版本"];
		[alert performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:YES];
	}
}

#pragma mark - Appium.app Update

-(BOOL) checkForAppUpdate
{
    // check github for the latest version
    NSString *stringURL = UPDATE_INFO_URL;
    NSURL  *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if (!urlData)
    {
        return NO;
    }
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:urlData options:kNilOptions error:&jsonError];
    NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
    NSString *myVersion = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *latestVersion = [jsonDictionary objectForKey:@"latest"];
    upgradeUrl = [jsonDictionary objectForKey:@"url"];
	NSArray *notUpgradableVersions = [jsonDictionary objectForKey:@"do-not-upgrade"];

	// check if this version is currently the latest
    if (![myVersion isEqualToString:latestVersion])
    {
		// check for non-upgradable versions
		for(int i=0; i < notUpgradableVersions.count; i++)
		{
			if ([myVersion isEqualToString:(NSString*)[notUpgradableVersions objectAtIndex:i]])
			{
				NSAlert *cannotUpgradeAlert = [NSAlert new];
				[cannotUpgradeAlert setMessageText:@"无法更新"];
				[cannotUpgradeAlert setInformativeText:@"有新版本的Appium.app，但是不能下载.\n\n请登录下载：http://appium.io"];
				[cannotUpgradeAlert runModal];
				return NO;
			}
		}
        [self performSelectorOnMainThread:@selector(doAppUpgradeAlert:) withObject:[NSArray arrayWithObjects:myVersion, latestVersion, nil] waitUntilDone:NO];
		return YES;
    }
	return NO;
}

-(void)doAppUpgradeAlert:(NSArray*)versions
{
    NSAlert *upgradeAlert = [NSAlert new];
    [upgradeAlert setInformativeText:[NSString stringWithFormat:@"确定要下载最新的Appium.app并且重新启动?\n\n当前版本:\t%@\n最新版本:\t%@", [versions objectAtIndex:0], [versions objectAtIndex:1]]];
    [upgradeAlert addButtonWithTitle:@"取消"];
    [upgradeAlert addButtonWithTitle:@"确定"];
    if([upgradeAlert runModal] == NSAlertSecondButtonReturn)
    {
        [self performSelectorInBackground:@selector(doAppUpgradeInstall) withObject:nil];
    }
}

-(void)doAppUpgradeInstall
{
    [mainWindowController.model killServer];

    AppiumInstallationWindowController *installationWindow = [[AppiumInstallationWindowController alloc] initWithWindowNibName:@"AppiumInstallationWindow"];
    [[mainWindowController window] orderOut:nil];
    [installationWindow performSelectorOnMainThread:@selector(showWindow:) withObject:self waitUntilDone:YES];
    [[installationWindow window] makeKeyAndOrderFront:self];
    [[installationWindow messageLabel] performSelectorOnMainThread:@selector(setStringValue:) withObject:@"正在下载Appium.app..." waitUntilDone:YES];

    // download latest appium.app
    NSURL  *url = [NSURL URLWithString:upgradeUrl];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if (!urlData)
    {
        return;
    }

	NSString *dmgPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath],@"appium.dmg"];
	NSString *destinationPath = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
    [urlData writeToFile:dmgPath atomically:YES];

	NSString *upgradeScriptPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Upgrade.applescript"];
    NSTask *restartTask = [NSTask new];
    [restartTask setLaunchPath:@"/bin/sh"];
    [restartTask setArguments:[NSArray arrayWithObjects: @"-c",[NSString stringWithFormat:@"sleep 2; rm -f /tmp/appium-updater /tmp/appium-upgrade.applescript /tmp/appium.dmg; cp \"%@\" /tmp/appium-upgrade.applescript; cp \"%@\" /tmp/appium.dmg; cp /usr/bin/osascript /tmp/appium-updater; /tmp/appium-updater /tmp/appium-upgrade.applescript \"/tmp/appium.dmg\" \"/Volumes/Appium\" \"/Volumes/Appium/Appium.app\" \"%@\" \"%@\" ; open \"%@\"", upgradeScriptPath, dmgPath, [[NSBundle mainBundle] bundlePath], destinationPath, [[NSBundle mainBundle] bundlePath] ], nil]];
    [restartTask launch];
    [[NSApplication sharedApplication] terminate:nil];

}

#pragma mark - Appium Package Update

-(BOOL) checkForPackageUpdate
{
    // check github for the latest version
    NSString *stringURL = APPIUM_PACKAGE_VERSION_URL;
    NSURL  *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if (!urlData)
    {
        return NO;
    }
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:urlData options:kNilOptions error:&jsonError];
    NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
    NSString *latestVersion = [jsonDictionary objectForKey:@"version"];
    NSString *myVersion;

    // check the local copy of appium
    NSString *packagePath = [NSString stringWithFormat:@"%@/%@", [[mainWindowController node] pathtoPackage:@"appium"], @"package.json"];
    if ([[NSFileManager defaultManager] fileExistsAtPath: packagePath])
    {
        NSData *data = [NSData dataWithContentsOfFile:packagePath];
        jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        jsonDictionary = (NSDictionary *)jsonObject;
        myVersion = [jsonDictionary objectForKey:@"version"];
    }
	
    if (![myVersion isEqualToString:latestVersion])
    {
        [self performSelectorOnMainThread:@selector(doPackageUpgradeAlert:) withObject:[NSArray arrayWithObjects:myVersion, latestVersion, nil] waitUntilDone:NO];
		return YES;
    }
	return NO;
}

-(void)doPackageUpgradeAlert:(NSArray*)versions
{
    NSAlert *upgradeAlert = [NSAlert new];
    [upgradeAlert setMessageText:@"有新版本的Appium可下载"];
    [upgradeAlert setInformativeText:[NSString stringWithFormat:@"确定停止服务并且下载最新版本的Appium?\n\n当前版本:\t%@\n最新版本:\t%@", [versions objectAtIndex:0], [versions objectAtIndex:1]]];
    [upgradeAlert addButtonWithTitle:@"取消"];
    [upgradeAlert addButtonWithTitle:@"确定"];
    if([upgradeAlert runModal] == NSAlertSecondButtonReturn)
    {
        [mainWindowController.model killServer];
//        [self performSelectorInBackground:@selector(updateAppiumPackage:) withObject:versions];
		[self performSelectorOnMainThread:@selector(updateAppiumPackage:) withObject:versions waitUntilDone:YES];
    }
}

-(void) updateAppiumPackage:(NSArray *)versions
{
    AppiumInstallationWindowController *installationWindow = [[AppiumInstallationWindowController alloc] initWithWindowNibName:@"AppiumInstallationWindow"];
    [installationWindow performSelectorOnMainThread:@selector(showWindow:) withObject:self waitUntilDone:YES];
    [[installationWindow window] makeKeyAndOrderFront:self];
    [[mainWindowController window] orderOut:self];
    [[installationWindow messageLabel] performSelectorOnMainThread:@selector(setStringValue:) withObject:@"正在升级Appium..." waitUntilDone:YES];

//    [[mainWindowController node] installPackage:@"appium" atVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forceInstall:YES];
	
	[[mainWindowController node] installPackage:@"appium" atVersion:versions[1] forceInstall:YES];

    [[mainWindowController window] makeKeyAndOrderFront:self];
    [installationWindow close];
    NSAlert *upgradeCompleteAlert = [NSAlert new];
    [upgradeCompleteAlert setMessageText:@"升级完成"];
    [upgradeCompleteAlert setInformativeText:@"安装成功"];
	
	[[NSUserDefaults standardUserDefaults]setValue:versions[1] forKey:@"CFBundleShortVersionString"];
	
    [upgradeCompleteAlert performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:YES];
}

@end
