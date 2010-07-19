//
//  UpgradeTeaserViewController.h
//  RealTimeFx
//
//  Created by Greg on 7/12/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UpgradeTeaserViewController : UIViewController
{
    UIView* maskingView;
    UIActivityIndicatorView* spinner;
    BOOL hasBeenShown;
}

- (BOOL) hasBeenShown;
- (IBAction) didClickYesButton;
- (IBAction) didClickNoButton;

@property (nonatomic, retain) IBOutlet UIView* maskingView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* spinner;


@end
