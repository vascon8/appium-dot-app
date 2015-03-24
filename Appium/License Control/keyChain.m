//
//  keyChain.m
//
//  Created by hyl on 12-4-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "keyChain.h"
#import <Security/Security.h>


@implementation keyChain

@synthesize valueKeyStr;


//-------------------------------------------------------------------------
- (NSString *)getNationalValue:(NSString *)value {
   
    valueKeyStr = [[NSString alloc] init];
//    NSDictionary *result = [[NSDictionary alloc] init];
	CFTypeRef result = NULL;
    NSArray *keys     = [[NSArray alloc] initWithObjects: (NSString *) kSecClass, kSecAttrAccount, kSecReturnAttributes, nil];
    NSArray *objects  = [[NSArray alloc] initWithObjects: (NSString *) kSecClassGenericPassword, value, kCFBooleanTrue, nil];
    NSDictionary *dic = [[NSDictionary alloc] initWithObjects: objects forKeys: keys];
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(dic),&result);
//    OSStatus status   = SecItemCopyMatching((__bridge CFDictionaryRef) dic, (CFTypeRef *) &result);

    if (status != noErr) {      
        return nil;
    } else {
		NSDictionary *dict = (__bridge NSDictionary *)result;
//        valueKeyStr = (NSString *) [dict objectForKey: (NSString *) kSecAttrGeneric];
		valueKeyStr = [[NSString alloc]initWithData:[dict objectForKey: (NSString *) kSecAttrGeneric] encoding:NSUTF8StringEncoding];
//		NSLog(@"%@,%@,%@",NSStringFromSelector(_cmd),valueKeyStr,dict);
        return valueKeyStr;
    }
}

//-------------------------------------------------------------------------
- (bool)setNationalValue:(NSString *)value forKey:(NSString *)setforkey {
      
    NSString *existingValue = [self getNationalValue:setforkey];    
    OSStatus status;
    if (existingValue) {        
        NSArray *keys     = [[NSArray alloc] initWithObjects: (NSString *) kSecClass, kSecAttrAccount, nil];
        NSArray *objects  = [[NSArray alloc] initWithObjects: (NSString *) kSecClassGenericPassword, setforkey, nil];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjects: objects forKeys: keys];
        status = SecItemUpdate((__bridge CFDictionaryRef) dic, (__bridge CFDictionaryRef) [NSDictionary dictionaryWithObject:value forKey: (NSString *) kSecAttrGeneric]);
    } else {       
        NSArray *keys     = [[NSArray alloc] initWithObjects: (NSString *) kSecClass, kSecAttrAccount, kSecAttrGeneric, nil];
        NSArray *objects  = [[NSArray alloc] initWithObjects: (NSString *) kSecClassGenericPassword, setforkey, value, nil];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjects: objects forKeys: keys] ;
        status = SecItemAdd((__bridge CFDictionaryRef) dic, NULL);
    }    
    
    if (status != noErr) {      
        return false;
    } else {        
        return true;
    }
}



//-----------calculate the day-------------------
- (NSInteger)getAllDate:(NSDate *)beginDate  endDate:(NSDate *)endDate{
  
    NSCalendar *calendarDate   = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
    unsigned int uniteDate     = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents *compDate = [calendarDate components:uniteDate fromDate:beginDate toDate:endDate options:0];  
    return  [compDate day];
}

//-----------calculate the hour-------------------
- (NSInteger)getAllHour:(NSDate *)beginDate  endDate:(NSDate *)endDate{
    NSCalendar *calendarHour = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    NSInteger uniteHour = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents *compHour = [calendarHour components:uniteHour fromDate:beginDate toDate:endDate options:0];
//    NSLog(@"%@,%@",NSStringFromSelector(_cmd),compHour);
    return  [self getCalcuHour:[compHour year] day:[compHour day] hour:[compHour hour]];
}


//---------calculate all the hour------------------
- (NSInteger)getCalcuHour:(NSInteger)year  day:(NSInteger)day hour:(NSInteger)hour{
    return year*365*24 + day*24 + hour;
}

//----------get the current date------------------- 
- (NSString *)getCurrentDate{
    NSDateFormatter *myDate = [[NSDateFormatter alloc] init];
    [myDate setDateFormat:@"yyyy-MM-dd HH:mm:ss +0600"];   
    NSString *DateStr = [myDate stringFromDate:[NSDate date]];    
    return DateStr;
}


//----------get the now date----------------------- 
- (NSDate *)getNowDate{
    NSDateFormatter *myDate = [[NSDateFormatter alloc] init];
    [myDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];  
    NSDate * nowDate = [[NSDate alloc] init];
    return nowDate;   
}


//----------get the start date---------------------
- (NSString *)getStartDate{
    return [self getNationalValue:TestWALicenseKey_EndDate];
}

//----------string change to date------------------
- (NSDate *)stringFromDate:(NSString *)StrDate{
//    NSDateFormatter *FormatterStrToDate = [[NSDateFormatter alloc] init];
    NSDate *toDate = [[NSDate alloc] initWithString:StrDate]; 
    return  toDate;
}

//----------date change to string------------------- 
- (NSString *)dateFromString:(NSDate *)date{
     NSDateFormatter *FormatterDateToStr = [[NSDateFormatter alloc] init];
     return [FormatterDateToStr stringFromDate:date];
}



@end
