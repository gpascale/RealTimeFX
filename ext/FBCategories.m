//
//  FBCategories.m
//  RealTimeFx
//
//  Created by Greg on 8/23/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "FBCategories.h"

@implementation Facebook (FBCategories)

- (void) cancel
{
    [_request cancel];
    [_request release];
    _request = nil;
}

@end


@implementation FBRequest (FBCategories)

- (void) cancel
{
    [_connection cancel];
    [_connection release];
    _connection = nil;
}

@end
