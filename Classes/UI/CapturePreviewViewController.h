//
//  CapturePreviewViewController.h
//  RealTimeFx
//
//  Created by Greg on 7/10/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "ShareViewController.h"

#import <UIKit/UIKit.h>

@class ShareViewController;

@interface CapturePreviewViewController : UIViewController <ShareViewControllerDelegate>
{
@private
    UIImage* image;
    
    UIImageView* imageView;
    UIView* actionMenuView;
}

@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UIView* actionMenuView;
@property (nonatomic, retain) IBOutlet ShareViewController* shareViewController;

@end
