//
//  ShareViewController.m
//  RealTimeFx
//
//  Created by Greg on 8/15/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "ShareViewController.h"
#import "FacebookHelper.h"
#import "TwitterHelper.h"
#import "Store.h"
#import "Watermarker.h"
#import "FlurryAPI.h"
#import <OAuth/CustomLoginPopup.h>
#import <QuartzCore/QuartzCore.h>

@interface ShareViewController (Private)

// Signin methods
- (void) _signInToFacebook;
- (void) _signInToTwitter;

// Facebook event handlers
- (void) _onFacebookLoginSuccess;
- (void) _onFacebookLoginCancel;
- (void) _onFacebookLoginFail;
- (void) _onFacebookUploadSuccess;
- (void) _onFacebookUploadFail;

// Twitter event handlers
- (void) _onTwitterLoginSuccess;
- (void) _onTwitterLoginCancel;
- (void) _onTwitterLoginFail;
- (void) _onTwitterUploadSuccess;
- (void) _onTwitterUploadFail;
- (void) _onTwitterUploadTimeout;

// Methods to pause/resume UI interaction when logging in or uploading 
// a photo
- (void) _suspendUIWithMessage: (NSString*) message;
- (void) _resumeUI;

// Show an alert to tell the user that upload failed
- (void) _showUploadFailedAlert;
- (void) _showUploadTimedOutAlert;
// Show an alert to tell the user that upload failed
- (void) _showLoginFailedAlert:(NSString*) serviceName;

@end

@implementation ShareViewController

@synthesize imageView;
@synthesize textView;
@synthesize delegate = mDelegate;
@synthesize style = mStyle;
@synthesize titleLabel;
@synthesize promptLabel;
@synthesize uiMaskView;
@synthesize uiMaskSubview;
@synthesize uiMaskViewSpinner;
@synthesize uiMaskViewLabel;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        // Subscribe to Facebook events
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(_onFacebookLoginSuccess)
                                                     name: @"FBLoginSuccess"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(_onFacebookLoginFail)
                                                     name: @"FBLoginFail"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(_onFacebookLoginCancel)
                                                     name: @"FBLoginCancel"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(_onFacebookUploadSuccess)
                                                     name: @"FBRequestSuccess"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(_onFacebookUploadFail)
                                                     name: @"FBRequestFail"
                                                   object: nil];
        
        // Subscribe to Twitter events
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(_onTwitterLoginSuccess)
                                                     name: @"TWLoginSuccess"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(_onTwitterLoginCancel)
                                                     name: @"TWLoginCancel"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(_onTwitterLoginFail)
                                                     name: @"TWLoginFail"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(_onTwitterUploadSuccess)
                                                     name: @"TWPostSuccess"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(_onTwitterUploadFail)
                                                     name: @"TWPostFail"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(_onTwitterUploadTimeout)
                                                     name: @"TWPostTimeout"
                                                   object: nil];
    }
    return self;
}

- (void) willShow
{
    if(mStyle == ShareViewStyle_Facebook)        
    {
        self.titleLabel.title = @"Facebook";
        self.promptLabel.text = @"Optionally enter a caption";
        self.textView.text = @"Check out this photo I took with Realtime FX for iPhone!";
        if(![[FacebookHelper sharedInstance] isLoggedIn])
        {
            [self _suspendUIWithMessage: @"Logging in to Facebook"]; 
            [self _signInToFacebook];
        }
        else
        {
            [self.textView becomeFirstResponder];
        }
    }
    else if(mStyle == ShareViewStyle_Twitter)
    {
        self.titleLabel.title = @"Twitter";
        self.promptLabel.text = @"Optionally enter a message";
        self.textView.text = @"Check out this photo I took with #RealtimeFX for iPhone!";
        if(![[TwitterHelper sharedInstance] isLoggedIn])
        {
            [self _suspendUIWithMessage: @"Logging in to Twitter"]; 
            [self _signInToTwitter];
        }
        else
        {
            [self.textView becomeFirstResponder];
        }
    }
}

- (void) viewDidLoad
{
    uiMaskSubview.layer.masksToBounds = YES;
    uiMaskSubview.layer.cornerRadius = 10.0;
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    self.imageView = nil;
    self.textView = nil;
    self.uiMaskView = nil;
    self.uiMaskSubview = nil;
    self.uiMaskViewSpinner = nil;
    self.uiMaskViewLabel = nil;
}

- (void) didTapUploadButton
{
    switch (mStyle)
    {
        case ShareViewStyle_Facebook:
            [[FacebookHelper sharedInstance] uploadPhoto: [Watermarker addWatermarkIfNoUpgrade:self.imageView.image]
                                             withCaption: self.textView.text];
            [self _suspendUIWithMessage: @"Uploading"];
            break;
        case ShareViewStyle_Twitter:
        {
            [[TwitterHelper sharedInstance] postPhoto: [Watermarker addWatermarkIfNoUpgrade:self.imageView.image]
                                            withTweet: self.textView.text];
            [self _suspendUIWithMessage: @"Tweeting"];
            break;
        }
        default:
            NSAssert(NO, @"Unrecognized ShareViewStyle");
            break;
    }
}

- (IBAction) didTapCancelButton
{
    [mDelegate shareViewControllerIsDone];
}

- (IBAction) clearMessage
{
    self.textView.text = nil;
}

- (IBAction) cancelUpload
{
    [[TwitterHelper sharedInstance] cancel];
    [[FacebookHelper sharedInstance] cancel];
    NSLog(@"Upload cancelled");
    [self _resumeUI];
}

#pragma mark Facebook

- (void) _signInToFacebook
{
    [[FacebookHelper sharedInstance] login];
    [self _suspendUIWithMessage: @"Signing in"]; 
}

- (void) _onFacebookLoginSuccess
{
    NSLog(@"_onFacebookLoginSuccess");
    [self _resumeUI];
}

- (void) _onFacebookLoginFail
{
    NSLog(@"_onFacebookLoginFail");
    [self _resumeUI];
    [mDelegate shareViewControllerIsDone];
    
    // looks like this only actually happens when the user cancels,
    // so don't show a popup
    //[self _showLoginFailedAlert:@"Facebook"];
}

- (void) _onFacebookUploadSuccess
{
    NSLog(@"_onFacebookUploadSuccess");
    [self _resumeUI];
    [mDelegate shareViewControllerIsDone];
    @try
    {
        [FlurryAPI logEvent:@"SharedPhoto"
             withParameters: [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Facebook", @"Method",
                              [NSNumber numberWithBool: [Store hasEffectPackOne]], @"HasFXPack1",
                              nil]];
    }
    @catch (id)
    {
        NSLog(@"Log facebook success failed");
    }
}

- (void) _onFacebookUploadFail
{
    NSLog(@"_onFacebookUploadFail");
    [self _resumeUI];
    [mDelegate shareViewControllerIsDone];
    [self _showUploadFailedAlert];
}

- (void) _signInToTwitter
{
    NSString* oAuthBundlePath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent: @"OAuthResources.bundle"];
    NSLog(@"OAuth bundle path: %@\n", oAuthBundlePath);
    NSBundle* oAuthBundle = [NSBundle bundleWithPath: oAuthBundlePath];
    loginPopup = [[CustomLoginPopup alloc] initWithNibName: @"TwitterLoginPopup"
                                                    bundle: oAuthBundle];
    loginPopup.oAuth = [TwitterHelper sharedInstance].oAuth;
    loginPopup.delegate = [TwitterHelper sharedInstance];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController: loginPopup];
    [self presentModalViewController:navController animated:YES];
}

- (void) _onTwitterLoginSuccess
{
    NSLog(@"_onTwitterLoginSuccess");
    [self dismissModalViewControllerAnimated:YES];
    [self _resumeUI];
}

- (void) _onTwitterLoginCancel
{
    NSLog(@"_onTwitterLoginCancel");
    [self dismissModalViewControllerAnimated:NO];
    [self _resumeUI];
    [mDelegate shareViewControllerIsDone];
}

- (void) _onTwitterLoginFail
{
    NSLog(@"_onTwitterLoginFail");    
    [self dismissModalViewControllerAnimated:NO];
    [self _resumeUI];
    [mDelegate shareViewControllerIsDone];
    [self _showLoginFailedAlert:@"Twitter"];
}

- (void) _onTwitterUploadSuccess
{
    NSLog(@"_onTwitterUploadSuccess");
    [self _resumeUI];
    [mDelegate shareViewControllerIsDone];
    
    @try
    {
        [FlurryAPI logEvent:@"SharedPhoto"
             withParameters: [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Twitter", @"Method",
                              [NSNumber numberWithBool: [Store hasEffectPackOne]], @"HasFXPack1",
                              nil]];
    }
    @catch (id)
    {
        NSLog(@"Log twitter success failed");
    }
                          
}

- (void) _onTwitterUploadFail
{
    NSLog(@"_onTwitterUploadFail");
    [self _resumeUI];
    [mDelegate shareViewControllerIsDone];
    [self _showUploadFailedAlert];
}

- (void) _onTwitterUploadTimeout
{
    NSLog(@"_onTwitterUploadTimeout");
    [self _resumeUI];
    [mDelegate shareViewControllerIsDone];
    [self _showUploadTimedOutAlert];
}
  
- (void) _suspendUIWithMessage: (NSString*) message
{
    NSLog(@"Suspending UI: %@", message);

    self.uiMaskView.alpha = 0.0f;
    self.uiMaskView.hidden = NO;
    self.uiMaskSubview.alpha = 0.0f;
    self.uiMaskSubview.hidden = NO;
    [self.uiMaskViewSpinner startAnimating];
    self.textView.editable = NO;
    self.uiMaskViewLabel.text = message;
    
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         self.uiMaskView.alpha = 1.0f;
                         self.uiMaskSubview.alpha = 1.0f;
                     }
                     completion: ^( BOOL finished )
                     {
                     }
     ];
}

- (void) _resumeUI
{
    NSLog(@"Resume UI");
    
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         self.uiMaskView.alpha = 0.0f;
                         self.uiMaskSubview.alpha = 0.0f;
                     }
                     completion: ^( BOOL finished )
                     {
                         [self.uiMaskViewSpinner stopAnimating];
                         self.uiMaskView.hidden = YES;
                         self.uiMaskSubview.hidden = YES;
                         self.textView.editable = YES;
                         [self.textView becomeFirstResponder];
                         self.uiMaskViewLabel.text = nil;
                     }
    ];
}

- (void) _showUploadFailedAlert
{
    UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:@""
                                                         message:@"Upload failed. If this happened instantly, the problem is most "
                                                                 @"likely your network connection. Otherwise, it may work if you try again."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil] autorelease];
    [alertView show];
}

- (void) _showUploadTimedOutAlert
{
    UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:@""
                                                         message:@"Upload timed out. It may work if you try again."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil] autorelease];
    [alertView show];
}

- (void) _showLoginFailedAlert:(NSString*) serviceName
{
    NSString* message = [NSString stringWithFormat: @"Could not connect to %@. Check your network connection", serviceName];
    UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:@""
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil] autorelease];
    [alertView show];
}

// Delegate methods       

- (void) tokenRequestDidStart:(TwitterLoginPopup *)twitterLogin
{
    NSLog(@"token request did start");
    //[loginPopup.activityIndicator startAnimating];
}

- (void) tokenRequestDidSucceed:(TwitterLoginPopup *)twitterLogin {
    NSLog(@"token request did succeed");    
    //[loginPopup.activityIndicator stopAnimating];
}

- (void) tokenRequestDidFail:(TwitterLoginPopup *)twitterLogin {
    NSLog(@"token request did fail");
    //[loginPopup.activityIndicator stopAnimating];
}

- (void) authorizationRequestDidStart:(TwitterLoginPopup *)twitterLogin {
    NSLog(@"authorization request did start");    
    //[loginPopup.activityIndicator startAnimating];
}

- (void) authorizationRequestDidSucceed:(TwitterLoginPopup *)twitterLogin {
    NSLog(@"authorization request did succeed");
}

- (void) authorizationRequestDidFail:(TwitterLoginPopup *)twitterLogin {
    NSLog(@"token request did fail");
    //[loginPopup.activityIndicator stopAnimating];
}

@end
