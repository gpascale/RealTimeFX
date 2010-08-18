//
//  CapturePreviewViewController.h
//  RealTimeFx
//
//  Created by Greg on 7/10/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "ShareViewController.h"
#import "SocialInfoViewController.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface CapturePreviewViewController : UIViewController <ShareViewControllerDelegate,
                                                            SocialInfoViewControllerDelegate,
                                                            MFMailComposeViewControllerDelegate>
{
@private
    UIImage* image;
    UIImageView* imageView;
    UIView* actionMenuView;
    BOOL actionMenuVisible;
}

@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UIView* actionMenuView;
@property (nonatomic, retain) IBOutlet ShareViewController* shareViewController;
@property (nonatomic, retain) IBOutlet SocialInfoViewController* socialInfoViewController;

- (void) willShow;
- (void) willHide;

- (IBAction) didTapSocialInfoButton;
- (IBAction) didTapDoneButton;
- (IBAction) didTapShareOnFacebookButton;
- (IBAction) didTapShareOnTwitterButton;
- (IBAction) didTapEmailButton;

@end
