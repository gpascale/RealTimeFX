//
//  SocialInfoViewController.h
//  RealTimeFx
//
//  Created by Greg on 8/17/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SocialInfoViewController;

@protocol SocialInfoViewControllerDelegate

- (void) socialInfoViewControllerIsDone: (SocialInfoViewController*) controller;

@end


@interface SocialInfoViewController : UIViewController
{
}

@property (nonatomic, retain) IBOutlet NSObject<SocialInfoViewControllerDelegate>* delegate;
@property (nonatomic, retain) IBOutlet UILabel* facebookLabel;
@property (nonatomic, retain) IBOutlet UILabel* twitterLabel;

- (IBAction) logOutOfFacebook;
- (IBAction) logOutOfTwitter;
- (IBAction) beDone;
   

@end
