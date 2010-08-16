//
//  FacebookHelper.m
//  RealTimeFx
//
//  Created by Greg on 8/14/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "FacebookHelper.h"

static NSString* apiKey = @"f504560da96cd7644e8732e279471596";
static FacebookHelper* instance;

@interface FacebookPendingOperation : NSObject
{
    NSString* operationName;
    NSDictionary* operationArgs;
}

@property(nonatomic, retain) NSString* operationName;
@property(nonatomic, retain) NSDictionary* operationArgs;

- (id) initWithName: (NSString*) name
            andArgs: (NSDictionary*) args;

@end

@implementation FacebookPendingOperation

@synthesize operationName;
@synthesize operationArgs;

- (id) initWithName: (NSString*) name
            andArgs: (NSDictionary*) args
{
    if(self = [super init])
    {
        self.operationName = name;
        self.operationArgs = args;
    }
    return self;
}

- (void) dealloc
{
    self.operationName = nil;
    self.operationArgs = nil;
    [super dealloc];
}

@end

@interface FacebookHelper (Private)

- (void) _handlePendingOperations;

@end


@implementation FacebookHelper

@synthesize isLoggedIn = mIsLoggedIn;

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
        mPendingOperations = [[NSMutableArray alloc] init];
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

- (void) uploadPhoto:(UIImage*)photo withCaption:(NSString*)caption
{
    if(!mIsLoggedIn)
    {
        FacebookPendingOperation* operation = 
            [[FacebookPendingOperation alloc] initWithName: @"uploadPhoto"
            andArgs: [NSDictionary dictionaryWithObjectsAndKeys: photo, @"photo",
                                                                 caption, @"caption",
                                                                 nil]];                    
        [mPendingOperations addObject: operation];
        
        [self login];
        
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

- (void) _handlePendingOperations
{
    for(FacebookPendingOperation* operation in mPendingOperations)
    {
        if([operation.operationName isEqualToString: @"uploadPhoto"])
        {
            UIImage* photo = [operation.operationArgs objectForKey: @"photo"];
            NSString* caption = [operation.operationArgs objectForKey: @"caption"];
            [self uploadPhoto:photo withCaption:caption];
        }
        else
        {
            NSAssert(NO, @"Unknown pending operation type");
        }
    }
    
    [mPendingOperations removeAllObjects];
}

- (void) dealloc
{
    [mPendingOperations release];
    [super dealloc];
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
};

/**
 * Called when a request returns and its response has been parsed into an object.
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result
{
    NSLog(@"Request loaded");
    [[NSNotificationCenter defaultCenter] postNotificationName: @"FBRequestSuccess"
                                                        object: self];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"FBLogout"
                                                        object: self];
}

@end
