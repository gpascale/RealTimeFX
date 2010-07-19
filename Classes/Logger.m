//
//  Logger.m
//  RealTimeFx
//
//  Created by Greg on 7/13/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "Logger.h"

@implementation Logger

/*
+ (void) initialize
{
    instance = [[Logger alloc] init];
}

+ (Logger*) instance
{
    return instance;
}
*/

+ (NSInteger) logAppLaunch
{
    NSInteger numberOfTimesLaunched = [[NSUserDefaults standardUserDefaults] integerForKey: @"NumberOfTimesLaunched"];
    [[NSUserDefaults standardUserDefaults] setInteger: numberOfTimesLaunched + 1 forKey: @"NumberOfTimesLaunched"];    
    return numberOfTimesLaunched;
}

@end
