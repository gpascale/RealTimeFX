    //
//  UpgradeTeaserViewController.m
//  RealTimeFx
//
//  Created by Greg on 7/12/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "UpgradeTeaserViewController.h"
#import "Store.h"
#import "ThumbnailCache.h"
#import <QuartzCore/QuartzCore.h>

@interface UpgradeTeaserViewController (Private)

- (void) showMaskingView;
- (void) hideMaskingView;

- (void) onPurchaseSucceeded: (NSNotification*) notification;
- (void) onPurchaseFailed: (NSNotification*) notification;

- (void) removeFromSuperviewAnimated;

@end

@implementation UpgradeTeaserViewController

@synthesize maskingView;
@synthesize spinner;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id) initWithCoder: (NSCoder*) aDecoder
{
    if (self = [super initWithCoder: aDecoder])
    {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onPurchaseSucceeded:)
                                                     name: @"PurchaseSucceeded"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onPurchaseFailed:)
                                                     name: @"PurchaseFailed"
                                                   object: nil];
        
        hasBeenShown = NO;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (BOOL) hasBeenShown
{
    return hasBeenShown;
}

static NSString* names[6] = 
{
    @"Emboss",
    @"Cartoon",
    @"Squeeze",
    @"Heat Sensor",
    @"Sketch",
    @"Film"
};

- (void) viewDidLoad
{
    int n = 0;
    for(UIView* view in self.view.subviews)
    {
        if([view isKindOfClass: [UIImageView class]])
        {
            UIImageView* imageView = (UIImageView*) view;
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = 10.0;
            
            imageView.image = [[ThumbnailCache sharedCache] thumbnailForEffectWithName: names[n]];
            ++n;
        }
    }
    hasBeenShown = YES;
}

- (IBAction) didClickYesButton
{
    [self showMaskingView];
    [[Store instance] makePurchase];
}

- (IBAction) didClickNoButton
{
    [self removeFromSuperviewAnimated];
}

- (void) showMaskingView
{
    maskingView.alpha = 1.0;
    [spinner startAnimating];
}

- (void) hideMaskingView
{
    [spinner stopAnimating];
    maskingView.alpha = 0.0;    
}

- (void) onPurchaseSucceeded: (NSNotification*) notification
{
    [self hideMaskingView];
    [self removeFromSuperviewAnimated];
}

- (void) onPurchaseFailed: (NSNotification*) notification
{
    [self hideMaskingView];
}

- (void) removeFromSuperviewAnimated
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"WillGoAway"
                                                        object: self];
    
    [UIView transitionWithView: [self.view superview]
                      duration: 0.5
                       options: UIViewAnimationOptionTransitionFlipFromLeft
                    animations: ^{ [self.view removeFromSuperview]; }
                    completion: NULL];
}

@end
