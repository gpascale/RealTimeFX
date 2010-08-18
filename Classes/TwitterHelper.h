//
//  TwitterHelper.h
//  RealTimeFx
//
//  Created by Greg on 8/15/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <OAuth/ASIHTTPRequestDelegate.h>
#import <OAuth/TwitterLoginPopupDelegate.h>

@class ASIFormDataRequest;
@class OAuth;

@interface TwitterHelper : NSObject <ASIHTTPRequestDelegate,
                                     TwitterLoginPopupDelegate>
{
    ASIFormDataRequest* twitpicRequest;
    ASIFormDataRequest* twitterRequest;
    OAuth* oAuth;
    
    UIImage* currentPhoto;
    NSString* currentTwitpicUrl;
    NSString* currentTweet;
    
    BOOL hasActiveRequest;
}

@property (nonatomic, readonly) OAuth* oAuth;
@property (nonatomic, readonly) NSString* username;

+ (TwitterHelper*) sharedInstance;

- (BOOL) isLoggedIn;

- (void) logout;

- (void) postPhoto:(UIImage*)image
         withTweet:(NSString*)tweet;

@end
