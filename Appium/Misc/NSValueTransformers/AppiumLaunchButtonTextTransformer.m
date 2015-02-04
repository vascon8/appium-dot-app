//
//  AppiumLaunchButtonTextTransformer.m
//  Appium
//
//  Created by Dan Cuellar on 3/3/13.
//  Copyright (c) 2013 Appium. All rights reserved.
//

#import "AppiumLaunchButtonTextTransformer.h"

@implementation AppiumLaunchButtonTextTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return ([value boolValue] ? @"停止服务器" : @"启动服务器");
}

@end
