//
//  FacebookHelper.m
//  RealTimeFx
//
//  Created by Greg on 8/14/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "FacebookHelper.h"
#import "FlurryAPI.h"

static NSString* apiKey = @"f504560da96cd7644e8732e279471596";
static FacebookHelper* instance;

@interface FacebookHelper (Private)

- (void) _readFromUserDefaults;
- (void) _writeToUserDefaults;

@end


@implementation FacebookHelper

@synthesize isLoggedIn = mIsLoggedIn;
@synthesize username;

+ (void) initialize
{
    instance = [[FacebookHelper alloc] init];
}

+ (FacebookHelper*) sharedInstance
{
    return instance;
}

- (id) init
{
    if (self = [super init])
    {
        [self _readFromUserDefaults];
    }
    return self;
}

- (void) login
{
    mPermissions =  [[NSArray arrayWithObjects: 
                     @"read_stream", @"photo_upload", nil] retain];
    
    mFacebook = [[Facebook alloc] init];
    [mFacebook authorize:apiKey permissions:mPermissions delegate:self];
}

- (void) logout
{
    [mFacebook logout:self];
    mIsLoggedIn = NO;
    username = nil;
    [self _writeToUserDefaults];
}

- (void) uploadPhoto:(UIImage*)photo withCaption:(NSString*)caption
{
    if(!mIsLoggedIn)
    {
        return;
    }
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   photo, @"picture",
                                   caption, @"caption",
                                   nil];
    
    [mFacebook requestWithMethodName: @"photos.upload" 
                           andParams: params
                       andHttpMethod: @"POST" 
                         andDelegate: self];
}

- (void) dealloc
{
    [mFacebook release];
    [mPermissions release];
    [super dealloc];
}

- (void) _readFromUserDefaults
{
    username = [[NSUserDefaults standardUserDefaults] objectForKey: @"username"];
    NSLog(@"Facebook logged in as %@", username);
}

- (void) _writeToUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:username
                                              forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate overrides

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error
{
    NSLog(@"Request failed with error %@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName: @"FBRequestFail"
                                                        object: self];
    
    @try
    {
        [FlurryAPI logError:@"FacebookError"
                    message:@""
                      error:error];
    }
    @catch (id)
    {
        NSLog(@"Log facebook error failed");
    }
};

/**
 * Called when a request returns and its response has been parsed into an object.
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result
{
    if([result isKindOfClass:[NSDictionary class]])
    {
        if ([result objectForKey:@"owner"]) 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName: @"FBRequestSuccess"
                                                                object: self];
        }
        else
        {
            username = [[result objectForKey:@"name"] retain];
            [self _writeToUserDefaults];
        }
    }
    NSLog(@"Request loaded");
};


///////////////////////////////////////////////////////////////////////////////////////////////////
// FBSessionDelegate overrides
/**
 * Callback for facebook login
 */ 
-(void) fbDidLogin
{
    NSLog(@"Logged into Facebook");
    mIsLoggedIn = YES;

    [[NSNotificationCenter defaultCenter] postNotificationName: @"FBLoginSuccess"
                                                        object: self];
    
    [mFacebook requestWithGraphPath: @"/me" andDelegate: self];
}

/**
 * Callback for facebook did not login
 */
- (void)fbDidNotLogin
{
    NSLog(@"Failed to log into Facebook");
    mIsLoggedIn = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"FBLoginFail"
                                                        object: self];
}

/**
 * Callback for facebook logout
 */ 
-(void) fbDidLogout
{
    NSLog(@"Logged out of Facebook");
    mIsLoggedIn = NO;
    [username release];
    username = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"FBLogout"
                                                        object: self];
}

@end
