//
//  TestWAPrjOutlineViewDataSource.m
//  Appium
//
//  Created by xin liu on 15/2/8.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import "TestWAPrjOutlineViewDataSource.h"
#import "TestWAServerProject.h"

@implementation TestWAPrjOutlineViewDataSource
#pragma mark - data source
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	NSInteger children = ((item == nil) ? self.prjList.count : [[item valueForKey:@"apps"] count]);
	return children;
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
//	BOOL result = ([item isKindOfClass:[TestWAServerProject class]] ? YES : NO);
	BOOL result = (([outlineView parentForItem:item] == nil) ? YES : NO);
	return result;
}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	id child = (item == nil ? self.prjList[index] : [item valueForKey:@"apps"][index]);
	return child;
}

@end
