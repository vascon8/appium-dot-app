//
//  LXLicenseTool.m
//  Appium
//
//  Created by xin liu on 15/3/21.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "LXLicenseTool.h"
#import "keyChain.h"


@implementation LXLicenseTool
+ (BOOL)validateLicense
{
	keyChain *keychain = [[keyChain alloc] init];
    
	[keychain setNationalValue:TestWALicenseValue_EndDate forKey:TestWALicenseKey_EndDate];
    
    NSString *national1ValueForKey = [keychain getNationalValue:TestWALicenseKey_EndDate];
    if ([national1ValueForKey length]==0) {
        [keychain setNationalValue:[keychain getCurrentDate] forKey:TestWALicenseKey_EndDate];
    }
    
//	NSLog(@"%@,%@,%@",NSStringFromSelector(_cmd),[keychain getNowDate],[keychain getCurrentDate]);
	
    NSInteger hour = [keychain getAllHour:[keychain stringFromDate:[keychain getNationalValue:TestWALicenseKey_EndDate]] endDate: [keychain getNowDate]];
//    NSInteger systemhour = [keychain getAllHour:[keychain stringFromDate:[keychain getNationalValue:TestWALicenseValidate_SystemKey]]  endDate: [keychain getNowDate]];
    
//	NSLog(@"%@,%ld,%ld",NSStringFromSelector(_cmd),hour,systemhour);
	
	/**
	if (systemhour<-1) {
		// printf("----------The system time is not correct---------------\r\n");
		NSAlert *systemTimeAlert = [[NSAlert alloc]init];
		[systemTimeAlert setMessageText:@"The system time is not correct,Please reset!"];
		[systemTimeAlert setInformativeText:@"Sorry!"];
		[systemTimeAlert runModal];
		
//		UIAlertView *alertSystemTime=[[UIAlertView alloc] initWithTitle:@"Sorry!"
//																message:@"The system time is not correct,please reset you system time!"
//															   delegate:self
//													  cancelButtonTitle:@"OK"
//													  otherButtonTitles:nil];
//		[alertSystemTime show];
	}
	**/
	
	if (hour>0) {
		//printf("----------The probation period has come---------------\r\n");
		NSAlert *validateAlert = [[NSAlert alloc]init];
		[validateAlert setInformativeText:@"http://testWA.cn"];
		[validateAlert setMessageText:@"The probation period has came,you need to download from testWA.com again!"];
		
		[validateAlert runModal];
		return NO;
//		UIAlertView *alertProPer=[[UIAlertView alloc] initWithTitle:@"Sorry!"
//															message:@"The probation period has come,you need download from apple store again!"
//														   delegate:self
//												  cancelButtonTitle:@"OK"
//												  otherButtonTitles:nil];
//		[alertProPer show];
	}
    return YES;
//    [keychain setNationalValue:[keychain getCurrentDate] forKey:@"national2"];
//    NSLog(@"%@,%ld,%ld",NSStringFromSelector(_cmd),hour,systemhour);
}
@end
