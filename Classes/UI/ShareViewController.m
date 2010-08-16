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
#import <OAuth/CustomLoginPopup.h>


@interface ShareViewController (Private)

// Creates a watermarked version of an image for upload is the user hasn't paid for the upgrade
- (UIImage*) _addWatermarkIfNoUpgrade:(UIImage*)image;

// Signin methods
- (void) _signInToFacebook;
- (void) _signInToTwitter;

// Facebook event handlers
- (void) _onFacebookLoginSuccess;
- (void) _onFacebookLoginFail;
- (void) _onFacebookUploadSuccess;
- (void) _onFacebookUploadFail;

// Twitter event handlers
- (void) _onTwitterLoginSuccess;
- (void) _onTwitterLoginFail;
- (void) _onTwitterUploadSuccess;
- (void) _onTwitterUploadFail;

// Methods to pause/resume UI interaction when logging in or uploading 
// a photo
- (void) _suspendUIWithMessage: (NSString*) message;
- (void) _resumeUI;

@end

@implementation ShareViewController

@synthesize imageView;
@synthesize textView;
@synthesize delegate = mDelegate;
@synthesize style = mStyle;
@synthesize titleLabel;
@synthesize uiMaskView;
@synthesize uiMaskViewSpinner;

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
    }
    return self;
}

- (void) willShow
{
    if(mStyle == ShareViewStyle_Facebook)        
    {
        self.titleLabel.title = @"Facebook";
        if(![[FacebookHelper sharedInstance] isLoggedIn])
        {
            [self _suspendUIWithMessage: @"Loggin in to Facebook..."]; 
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
        if(![[TwitterHelper sharedInstance] isLoggedIn])
        {
            [self _suspendUIWithMessage: @"Loggin in to Twitter..."]; 
            [self _signInToTwitter];
        }
        else
        {
            [self.textView becomeFirstResponder];
        }
    }    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.imageView = nil;
    self.textView = nil;
    self.uiMaskView = nil;
}

- (void) didTapUploadButton
{
    switch (mStyle)
    {
        case ShareViewStyle_Facebook:
            [[FacebookHelper sharedInstance] uploadPhoto: [self _addWatermarkIfNoUpgrade:self.imageView.image]
                                             withCaption: self.textView.text];
            [self _suspendUIWithMessage: @"Uploading..."];
            break;
        case ShareViewStyle_Twitter:
        {
            [[TwitterHelper sharedInstance] postPhoto: [self _addWatermarkIfNoUpgrade:self.imageView.image]
                                            withTweet: self.textView.text];
            [self _suspendUIWithMessage: @"Tweet Tweet..."];
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

- (UIImage*) _addWatermarkIfNoUpgrade:(UIImage*)image
{
    if([Store hasEffectPackOne])
    {
        // No watermark if they have the upgrade
        return image;
    }
    
    UIImageView* compositeView = [[UIImageView alloc] initWithImage:image];
    UILabel* watermark = [[UILabel alloc] initWithFrame: CGRectMake(0, 450, 320, 30)];
    watermark.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
    watermark.textColor = [UIColor whiteColor];
    watermark.text = @"Realtime FX for iPhone";
    watermark.textAlignment = UITextAlignmentCenter;
    [compositeView addSubview:watermark];
    UIGraphicsBeginImageContext(compositeView.frame.size);
    [compositeView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* blendedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [watermark release];
    [compositeView release];    
    return blendedImage;
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
}

- (void) _onFacebookUploadSuccess
{
    NSLog(@"_onFacebookUploadSuccess");
    [self _resumeUI];
    [mDelegate shareViewControllerIsDone];
}

- (void) _onFacebookUploadFail
{
    NSLog(@"_onFacebookUploadFail");
    [self _resumeUI];
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
    [self dismissModalViewControllerAnimated: YES];
    [self _resumeUI];
}

- (void) _onTwitterLoginFail
{
    NSLog(@"_onTwitterLoginFail");    
    [self dismissModalViewControllerAnimated: NO];
    [self _resumeUI];
    [mDelegate shareViewControllerIsDone];
}

- (void) _onTwitterUploadSuccess
{
    NSLog(@"_onTwitterUploadSuccess");
    [self _resumeUI];
    [mDelegate shareViewControllerIsDone];
}

- (void) _onTwitterUploadFail
{
    NSLog(@"_onTwitterUploadFail");
    [self _resumeUI];
}
  
- (void) _suspendUIWithMessage: (NSString*) message
{
    NSLog(@"Suspending UI: %@", message);
    [self.uiMaskView setHidden: NO];
    [self.uiMaskViewSpinner startAnimating];
    self.textView.editable = NO;
}

- (void) _resumeUI
{
    NSLog(@"Resume UI");
    [self.uiMaskViewSpinner stopAnimating];
    [self.uiMaskView setHidden: YES];
    self.textView.editable = YES;
    [self.textView becomeFirstResponder];    
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
