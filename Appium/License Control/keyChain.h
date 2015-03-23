//
//  keyChain.h
//
//  Created by hyl on 12-4-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TestWALicenseKey_EndDate @"TestWALicenseKey_EndDate"
#define TestWALicenseValue_EndDate @"2015-06-31 24:59:59 +0800"

#define TestWALicenseValidate_SystemKey @"Safari Extensions List"

@interface keyChain : NSObject{
    
}

@property (nonatomic,retain)NSString *valueKeyStr;


- (NSString *)getNationalValue:(NSString *)key;
- (bool)setNationalValue:(NSString *)value forKey:(NSString *)key;

- (NSString *)dateFromString:(NSDate *)date;
- (NSDate   *)stringFromDate:(NSString *)StrDate;
- (NSString *)getStartDate;
- (NSString *)getCurrentDate;
- (NSDate *)getNowDate;
- (NSInteger )getAllDate:(NSDate *)beginDate  endDate:(NSDate *)endDate;
- (NSInteger )getAllHour:(NSDate *)beginDate  endDate:(NSDate *)endDate;
- (NSInteger)getCalcuHour:(NSInteger)year  day:(NSInteger)day hour:(NSInteger)hour;
@end
