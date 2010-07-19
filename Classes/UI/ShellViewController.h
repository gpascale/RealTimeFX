//
//  ShellViewController.h
//  RealTimeFx
//
//  Created by Greg on 7/10/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/ADBannerView.h>

@class RealTimeFxViewController;

@interface ShellViewController : UIViewController <ADBannerViewDelegate>
{
@private
    
    UIView* contentView;
    ADBannerView* bannerView;
    RealTimeFxViewController* fxViewController;
    BOOL wasRendering;
    
}

@property (nonatomic, retain) IBOutlet UIView* contentView;
@property (nonatomic, retain) IBOutlet ADBannerView* bannerView;
@property (nonatomic, retain) IBOutlet RealTimeFxViewController* fxViewController;

@end
