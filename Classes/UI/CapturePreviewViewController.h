//
//  CapturePreviewViewController.h
//  RealTimeFx
//
//  Created by Greg on 7/10/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CapturePreviewViewController : UIViewController
{
@private
    UIImage* image;
    
    UIImageView* imageView;
    UIView* actionMenuView;
}

@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UIView* actionMenuView;

- (IBAction) didTapDoneButton;
- (IBAction) showActionMenu;
- (IBAction) hideActionMenu;

// Action Menu button actions
- (IBAction) didTapSaveToCameraRollButton;

@end
