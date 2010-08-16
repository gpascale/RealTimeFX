//
//  ShareViewController.h
//  RealTimeFx
//
//  Created by Greg on 8/15/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OAuth/TwitterLoginUiFeedback.h>

@class OAuth;
@class CustomLoginPopup;

@protocol ShareViewControllerDelegate

- (void) shareViewControllerIsDone;

@end

typedef enum ShareViewStyle_t
{
    ShareViewStyle_Facebook,
    ShareViewStyle_Twitter
} ShareViewStyle;

@interface ShareViewController : UIViewController <TwitterLoginUiFeedback>
{
    UIImageView* imageView;
    UITextView* textView;
    
    UIBarButtonItem* titleLabel;
    
    NSObject<ShareViewControllerDelegate>* mDelegate;
    ShareViewStyle mStyle;
    
    // Twitter
    OAuth* oAuth;
    CustomLoginPopup* loginPopup;
    
    UIView* uiMaskView;
}

@property (nonatomic, retain) IBOutlet NSObject<ShareViewControllerDelegate>* delegate;
@property (nonatomic) IBOutlet ShareViewStyle style;

@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UITextView* textView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* titleLabel;
@property (nonatomic, retain) IBOutlet UIView* uiMaskView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* uiMaskViewSpinner;

- (IBAction) didTapCancelButton;
- (IBAction) didTapUploadButton;

- (void) willShow;

@end
