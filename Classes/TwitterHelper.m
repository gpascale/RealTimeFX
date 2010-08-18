//
//  TwitterHelper.m
//  RealTimeFx
//
//  Created by Greg on 8/15/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "TwitterHelper.h"
#import <OAuth/OAuth.h>
#import <OAuth/ASIFormDataRequest.h>
#import <OAuth/OAuth+UserDefaults.h>
#import <JSON/NSString+SBJSON.h>
#import "FlurryAPI.h"

@interface TwitterHelper (Private)

// Adds the twitpic url to the tweet body, truncating the tweet if necessary
// to keep the full tweet to 140 characters or less
- (NSString*) _tweetWithTwitpicUrl;

// Takes care of necessary cleanup/state management when finishing a post
- (void) _finishTweet:(BOOL)success;

@end

@implementation TwitterHelper

@synthesize oAuth;

static TwitterHelper* instance;

+ (void) initialize
{
    instance = [[TwitterHelper alloc] init];
}

+ (TwitterHelper*) sharedInstance
{
    return instance;
}

#define OAUTH_CONSUMER_KEY @"JIKslP4pBl1KL6BgVtLyA"
#define OAUTH_CONSUMER_SECRET @"YCuVKlODpYYMcgFf4EJoV9JhBVSO3k8w9sgppXCqE"

- (id) init
{
    if (self = [super init])
    {
        oAuth = [[OAuth alloc] initWithConsumerKey:OAUTH_CONSUMER_KEY andConsumerSecret:OAUTH_CONSUMER_SECRET];
        [oAuth loadOAuthTwitterContextFromUserDefaults];                
    }
    
    return self;
}

- (BOOL) isLoggedIn
{
    return oAuth && oAuth.oauth_token_authorized;
}

- (NSString*) username
{
    if(![self isLoggedIn])
    {
        return nil;
    }
    
    return oAuth.screen_name;
}

- (void) logout
{
    [oAuth forget];
    [oAuth saveOAuthTwitterContextToUserDefaults];
}

- (void) postPhoto:(UIImage*)photo
         withTweet:(NSString*)tweet
{
    if(hasActiveRequest)
        return;
    
    hasActiveRequest = YES;
    
    currentTweet = [tweet retain];
    
    twitpicRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitpic.com/2/upload.json"]];
    
    NSLog(@"Header: %@", [oAuth oAuthHeaderForMethod:@"GET"
          andUrl:@"https://api.twitter.com/1/account/verify_credentials.json"
          andParams:nil]);
    
    [twitpicRequest addRequestHeader:@"X-Auth-Service-Provider" value:@"https://api.twitter.com/1/account/verify_credentials.json"];
    [twitpicRequest addRequestHeader:@"X-Verify-Credentials-Authorization"
                    value:[oAuth oAuthHeaderForMethod:@"GET"
                                               andUrl:@"https://api.twitter.com/1/account/verify_credentials.json"
                                            andParams:nil]];    
    
    [twitpicRequest setData:UIImageJPEGRepresentation(photo, 0.8) forKey:@"media"];
    
    // Define this somewhere or replace with your own key inline right here.
    [twitpicRequest setPostValue:@"4fca9546ac7700015ed60f873641a474" forKey:@"key"];
    
    // TwitPic API doc says that message is mandatory, but looks like
    // it's actually optional in practice as of July 2010. You may or may not send it, both work.
    [twitpicRequest setPostValue:@"" forKey:@"message"];
    [twitpicRequest setDelegate: self];
    [twitpicRequest startAsynchronous];        
}

- (void) requestFinished:(ASIHTTPRequest*)request
{
    if(request == twitpicRequest)
    {
        // Grab the twitpic URL
        NSLog(@"Got HTTP status code from TwitPic: %d", [twitpicRequest responseStatusCode]);
        NSDictionary *twitpicResponse = [[twitpicRequest responseString] JSONValue];
        currentTwitpicUrl = [[twitpicResponse valueForKey:@"url"] retain];
        NSLog(@"Posted image URL: %@", currentTwitpicUrl);
        // Make sure the URL is valid - otherwise the post is a failure
        if(currentTwitpicUrl == nil)
        {
            [self _finishTweet: NO];
            return;
        }
        
        // Post to twitter
        NSString *postUrl = @"https://api.twitter.com/1/statuses/update.json";        
        twitterRequest = [[ASIFormDataRequest alloc]
                                       initWithURL:[NSURL URLWithString:postUrl]];
        NSString* tweetBody = [self _tweetWithTwitpicUrl];
        [twitterRequest setPostValue:tweetBody forKey:@"status"];        
        [twitterRequest addRequestHeader:@"Authorization"
                            value:[oAuth oAuthHeaderForMethod:@"POST"
                                                       andUrl:postUrl
                                                    andParams:[NSDictionary dictionaryWithObject:tweetBody
                                                                                          forKey:@"status"]]];
        [twitterRequest setDelegate: self];
        [twitterRequest startAsynchronous];       
    }
    else if (request == twitterRequest)
    {        
        if(twitterRequest.responseStatusCode == 200)
        {
            NSLog(@"Tweet success!");            
            [self _finishTweet: YES];
        }
        else
        {
            NSLog(@"Tweet failed with HTTP code %d", twitterRequest.responseStatusCode);
            [self _finishTweet: NO];
        }             
    }
}

/*
 how now this is a tweet that is exactly, precisely, not one more, not one less, but exactly a whopping one hundred and forty characters long
*/
- (void)requestFailed:(ASIHTTPRequest *)request
{
    @try
    {
        [FlurryAPI logError:@"TwitterError"
                    message:@""
                      error:request.error];
    }
    @catch (id)
    {
         NSLog(@"Log twitter fail failed");
    }
        
    
    if(request == twitpicRequest)
    {
        NSLog(@"Twitpic request failed: %@ - %@", [twitpicRequest responseStatusMessage],
                                                  [[twitpicRequest.error userInfo] objectForKey:NSUnderlyingErrorKey]);
        [self _finishTweet:NO];
    }
    else if (request == twitterRequest)
    {
        NSLog(@"Twitter request failed: %@", [[twitterRequest.error userInfo] objectForKey:NSUnderlyingErrorKey]);
        [self _finishTweet:NO];
    }
}

- (NSString*) _tweetWithTwitpicUrl
{
    NSString* twitpicUrlWithSpace = [@" " stringByAppendingString: currentTwitpicUrl];
    NSInteger tweetMaxLength = 140 - [twitpicUrlWithSpace length];
    NSString* tweetTruncated = [currentTweet length] > tweetMaxLength ? 
                                   [currentTweet substringToIndex: tweetMaxLength] :
                                   currentTweet;
    NSLog(@"Tweeting \"%@\"", [tweetTruncated stringByAppendingString: twitpicUrlWithSpace]);
    return [tweetTruncated stringByAppendingString: twitpicUrlWithSpace];
}

- (void) _finishTweet:(BOOL)success
{
    [twitpicRequest release];
    twitpicRequest = nil;
    [twitterRequest release];
    twitterRequest = nil;
    [currentTweet release];
    currentTweet = nil;
    
    if(success)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"TWPostSuccess" object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"TWPostFail" object:nil];
    }

    hasActiveRequest = NO;
}

// TwitterLoginPopup delegate methods
- (void)twitterLoginPopupDidCancel:(TwitterLoginPopup *)popup
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"TWLoginFail" object:nil];
}

- (void)twitterLoginPopupDidAuthorize:(TwitterLoginPopup *)popup
{      
    [oAuth saveOAuthTwitterContextToUserDefaults];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"TWLoginSuccess" object:nil];
}

@end
