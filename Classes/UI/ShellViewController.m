//
//  ShellViewController.m
//  RealTimeFx
//
//  Created by Greg on 7/10/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "ShellViewController.h"
#import "RealTimeFxViewController.h"
#import "Store.h"

@interface ShellViewController (Private)

@end

@implementation ShellViewController

@synthesize contentView;
@synthesize bannerView;
@synthesize fxViewController;

- (id) initWithCoder: (NSCoder*) aDecoder
{
    if (self = [super initWithCoder: aDecoder])
    {
        wasRendering = NO;
    }
    
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([Store hasEffectPackOne])
    {
        self.bannerView.delegate = nil;
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
        NSLog(@"bannerview retain count is now %d\n", [bannerView retainCount]);        
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.contentView = nil;
    self.bannerView = nil;
}


- (void)dealloc
{
    [super dealloc];
}

#pragma mark ADBannerViewDelegate protocol methods

- (void) bannerViewDidLoadAd: (ADBannerView*) banner
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
    bannerView.frame = CGRectMake(0,
                                  self.view.frame.size.height - bannerView.frame.size.height,
                                  bannerView.frame.size.width,
                                  bannerView.frame.size.height);
    contentView.frame = CGRectMake(0,
                                   0,
                                   self.view.frame.size.width,
                                   self.view.frame.size.height - bannerView.frame.size.height);
    [UIView commitAnimations];
}

- (void) bannerView: (ADBannerView*) banner didFailToReceiveAdWithError: (NSError*) error
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
    bannerView.frame = CGRectMake(0,
                                  self.view.frame.size.height,
                                  bannerView.frame.size.width,
                                  bannerView.frame.size.height);
    contentView.frame = CGRectMake(0,
                                   0,
                                   self.view.frame.size.width,
                                   self.view.frame.size.height);
    [UIView commitAnimations];
}

- (BOOL) bannerViewActionShouldBegin: (ADBannerView*) banner
                willLeaveApplication: (BOOL) willLeave
{
    if (!willLeave)
    {
        wasRendering = fxViewController.isRendering;
        [fxViewController stopRendering];
    }        

    return YES;
}

- (void) bannerViewActionDidFinish: (ADBannerView*) banner
{
    if (wasRendering)
    {
        [fxViewController startRendering];
    }
}

@end
