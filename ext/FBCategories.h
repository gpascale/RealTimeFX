//
//  FBCategories.h
//  RealTimeFx
//
//  Created by Greg on 8/23/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <Facebook.h>
#import <FBRequest.h>

@interface Facebook (FBCategories)

- (void) cancel;

@end


@interface FBRequest (FBCategories)

- (void) cancel;

@end
