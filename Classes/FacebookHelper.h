//
//  FacebookHelper.h
//  RealTimeFx
//
//  Created by Greg on 8/14/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <Facebook.h>

@class Facebook;

@interface FacebookHelper : NSObject <FBRequestDelegate, FBSessionDelegate>
{
    Facebook* mFacebook;
    NSArray* mPermissions;
    BOOL mIsLoggedIn;
}

@property (nonatomic, readonly) BOOL isLoggedIn;
@property (nonatomic, readonly) NSString* username;

+ (FacebookHelper*) sharedInstance;

- (void) login;
- (void) logout;

- (void) uploadPhoto:(UIImage*)photo withCaption:(NSString*)caption;


@end
