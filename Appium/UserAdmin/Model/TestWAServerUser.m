//
//  TestWAServerUser.m
//  Appium
//
//  Created by xin liu on 15/2/1.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "TestWAServerUser.h"

@implementation TestWAServerUser

#pragma mark - NSCoding
- (id)init
{
	self = [super init];
	if (self) {
		self.expireDate = [[NSDate date]dateByAddingTimeInterval:ExpireDate];
	}
	return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.name forKey:@"name"];
	[aCoder encodeObject:self.id forKey:@"id"];
	[aCoder encodeObject:self.expireDate forKey:@"expireDate"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		self.name = [aDecoder decodeObjectForKey:@"name"];
		self.id = [aDecoder decodeObjectForKey:@"id"];
		self.expireDate = [aDecoder decodeObjectForKey:@"expireDate"];
	}
	return self;
}
@end
