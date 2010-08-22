//
//  SocialInfoViewController.m
//  RealTimeFx
//
//  Created by Greg on 8/17/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "SocialInfoViewController.h"
#import "FacebookHelper.h"
#import "TwitterHelper.h"

@interface SocialInfoViewController (Private)

- (void) _updateFacebookLabel;
- (void) _updateTwitterLabel;

@end

@implementation SocialInfoViewController

@synthesize facebookLabel;
@synthesize twitterLabel;
@synthesize facebookLogoutButton;
@synthesize twitterLogoutButton;
@synthesize delegate;

- (void) viewDidAppear:(BOOL)animated
{
    [self _updateFacebookLabel];
    [self _updateTwitterLabel];    
}

- (void)viewDidUnload
{
    self.delegate = nil;
    self.facebookLabel = nil;
    self.twitterLabel = nil;
    self.facebookLogoutButton = nil;
    self.twitterLogoutButton = nil;
    [super viewDidUnload];
}

- (IBAction) logOutOfFacebook
{
    [[FacebookHelper sharedInstance] logout];
    [self _updateFacebookLabel];
}

- (IBAction) logOutOfTwitter
{
    [[TwitterHelper sharedInstance] logout];
    [self _updateTwitterLabel];
}

- (IBAction) beDone
{
    [self.delegate socialInfoViewControllerIsDone: self];
}

- (void) _updateFacebookLabel
{
    NSString* facebookUserName = [FacebookHelper sharedInstance].username;
    if(facebookUserName)
    {
        facebookLabel.text = [NSString stringWithFormat: @"Logged in as %@", facebookUserName];
        facebookLogoutButton.hidden = NO;
    }
    else
    {
        facebookLabel.text = @"Not Logged In";
        facebookLogoutButton.hidden = YES;
    }
}

- (void) _updateTwitterLabel
{
    NSString* twitterUsername = [TwitterHelper sharedInstance].username;
    if(twitterUsername)
    {
        twitterLabel.text = [NSString stringWithFormat: @"Logged in as %@", twitterUsername];
        twitterLogoutButton.hidden = NO;
    }
    else
    {
        twitterLabel.text = @"Not Logged In";
        twitterLogoutButton.hidden = YES;
    }
}

@end
