//
//  RealTimeFxViewController.m
//  RealTimeFx
//
//  Created by Greg on 6/27/10.
//  Copyright Brown University 2010. All rights reserved.
//

#import "RealTimeFxViewController.h"
#import "EffectSelectorViewController.h"
#import "CapturePreviewViewController.h"
#import "UpgradeTeaserViewController.h"
#import "RenderView.h"
#import "EffectManager.h"
#import "TextureRenderer.h"
#import "Effect.h"
#import "FPSCalculator.h"

#import "FlurryAPI.h"

#if TARGET_IPHONE_SIMULATOR
    #import "SimulatorCamera.h"
#else
    #import "DeviceCamera.h"
#endif

// Track so we can show the teaser view in the free version after
// the user view 5 effects
static int numberOfEffectsViewed = 0;

// temporary
#import "Store.h"

@interface RealTimeFxViewController (private)
 
- (void) startHideUITimer;

- (void) showUI;
- (void) hideUI;
- (void) showUIAnimated: (BOOL) animated;
- (void) hideUIAnimated: (BOOL) animated;

- (void) dismissModalViewController: (NSNotification*) notification;

- (void) resumeRenderingIfWasParentOfUpgradeView;

- (void) updateSlider: (UISlider*) slider
   withEffectVariable: (EffectVariable*) effectVariable;

- (void) showSlider: (UISlider*) slider
           animated: (BOOL) animated;
- (void) hideSlider: (UISlider*) slider
           animated: (BOOL) animated;

@end

@implementation RealTimeFxViewController

@synthesize renderView;
@synthesize toolBar;
@synthesize effectNameLabel;
@synthesize fpsLabel;
@synthesize vfpsLabel;
@synthesize sliderOne;
@synthesize sliderTwo;
@synthesize toggleCameraButton;
@synthesize effectNameTextField;
@synthesize selectorViewController;
@synthesize capturePreviewViewController;
@synthesize upgradeTeaserViewController;

- (id) initWithCoder: (NSCoder*) aDecoder
{
    if(self = [super initWithCoder: aDecoder])
    {
        uiIsHidden = NO;        
    }
    
    return self;
}

- (void) awakeFromNib
{
    context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];    
    effectManager = [[EffectManager alloc] initWithContext: context];                   
    renderer = [[TextureRenderer alloc] initWithContext: context]; 
    selectorViewController.effectManager = effectManager;
    
#if TARGET_IPHONE_SIMULATOR
    camera = [[SimulatorCamera alloc] init];
#else
    camera = [[DeviceCamera alloc] init];
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(activeEffectDidChange:)
                                                 name: @"ActiveEffectDidChange"
                                               object: effectManager]; 
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didRenderFrame:)
                                                 name: @"RenderedFrame"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didProcessVideoFrame:)
                                                 name: @"ProcessedVideoFrame"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(dismissModalViewController:)
                                                 name: @"didTapDoneButton"
                                               object: capturePreviewViewController];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(hideEffectSelectorView)
                                                 name: @"SelectedEffectOrTappedCanel"
                                               object: selectorViewController];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(resumeRenderingIfWasParentOfUpgradeView)
                                                 name: @"WillGoAway"
                                               object: upgradeTeaserViewController];
    
    fpsCalculator = [[FPSCalculator alloc] initWithFrameNotificationName: @"RenderedFrame"];
    vfpsCalculator = [[FPSCalculator alloc] initWithFrameNotificationName: @"ProcessedVideoFrame"];        
}

- (void) viewWillAppear: (BOOL) animated
{
    [self startRendering];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [self stopRendering];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    [self activeEffectDidChange: nil];    

    sliderOne.backgroundColor = [UIColor clearColor];
    UIImage* sliderTrack = [[UIImage imageNamed:@"sliderTrack.png"]
                            stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    [sliderOne setMinimumTrackImage: sliderTrack forState: UIControlStateNormal];
    [sliderOne setMaximumTrackImage: sliderTrack forState: UIControlStateNormal];
    
	renderView.renderer = renderer;
    [renderView setCamera: camera];
        
    // Update the effect name to reflect the new effect's name
    self.effectNameLabel.text = effectManager.activeEffectName;
    
    [self showUIAnimated: NO];
    [self startHideUITimer];
    
    [renderView setAnimationFrameInterval: 2];
    
#if !SHOWFPS
    
    [self.fpsLabel removeFromSuperview];
    self.fpsLabel = nil;
    
    [self.vfpsLabel removeFromSuperview];
    self.vfpsLabel = nil;
    
#endif
    
    if (![camera hasMultipleCameras])
    {
        [self.toggleCameraButton setHidden: YES];
    }
    
    printf("%d toolbar items\n", [self.toolBar.items count]);
    [[self.toolBar.items objectAtIndex: 0] setAccessibilityLabel: @"previousButton"];
    [[self.toolBar.items objectAtIndex: 2] setAccessibilityLabel: @"effectTitle"];
    [[self.toolBar.items objectAtIndex: 4] setAccessibilityLabel: @"nextButton"];
    
    self.effectNameTextField.text = effectManager.activeEffectName;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    self.renderView = nil;
    self.toolBar = nil;
    self.effectNameLabel = nil;  
    self.sliderOne = nil;
    self.sliderTwo = nil;
    self.upgradeTeaserViewController = nil;
    self.fpsLabel = nil;
    self.vfpsLabel = nil;
}

- (void)dealloc
{
    [super dealloc];
}

- (BOOL) isRendering
{
    return [renderView isAnimating] && [camera isCapturing];
}

- (void) resumeRenderingIfWasParentOfUpgradeView
{
    if(upgradeTeaserViewController.view.superview == self.view)
    {
        [self startRendering];
    }
}

- (void) startRendering
{
    [renderer setEffect: effectManager.activeEffect];
	[renderView startAnimation];
	[camera startCapturing];
}

- (void) stopRendering
{
    [camera stopCapturing];
	[renderView stopAnimation];
}

- (IBAction) didTapCaptureButton
{
    UIImage* image = [renderer captureScreen];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"TookPicture"
                                                        object: image];
    capturePreviewViewController.image = image;
    
    [self.view addSubview: capturePreviewViewController.view];
    capturePreviewViewController.view.alpha = 0.0f;    
    
    [self stopRendering];
    [UIView animateWithDuration: 0.3
                     animations: ^{
                                      capturePreviewViewController.view.alpha = 1.0f;
                                  }
                     completion: ^( BOOL finished )
                                  {
                                      [capturePreviewViewController willShow];
                                  }
     
    ];
    
    @try
    {
        NSString* effectNameWithoutSpaces = [effectManager.activeEffectName stringByReplacingOccurrencesOfString: @" "
                                                                                                      withString: @""];
        
        NSDictionary* logInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                 effectNameWithoutSpaces, @"ActiveEffect",
                                 [NSNumber numberWithBool: [Store hasEffectPackOne]], @"HasFXPack1", 
                                 nil];
        
        [FlurryAPI logEvent: @"TookPicture"
             withParameters: logInfo];
    }             
    @catch (NSException*e)
    {
        NSAssert(NO, @"Failed to upload log to mobclix");
    }
    
}

- (IBAction) didTapToggleCameraButton
{
    [camera toggleCameras];
    [self startHideUITimer];
}

- (IBAction) showEffectSelectorView
{
    [selectorViewController viewWillAppear: YES];
    
	[UIView transitionWithView: self.view
                      duration: 0.5
                       options: UIViewAnimationOptionTransitionFlipFromRight
                    animations: ^{ [self.view addSubview: selectorViewController.view]; }
                    completion: ^(BOOL finished)
                                {
                                    if(finished)
                                    {
                                        [self stopRendering];
                                    }
                                }
    ];
}

- (void) hideEffectSelectorView
{
    [self startRendering];
    [self showUIAnimated: NO];
    
    [UIView transitionWithView: self.view
                      duration: 0.5
                       options: UIViewAnimationOptionTransitionFlipFromLeft
                    animations: ^{ [selectorViewController.view removeFromSuperview]; }
                    completion: ^(BOOL finished)
                                {
                                    if(finished)
                                    {
                                    }
                                }
     ];
}

- (IBAction) goToNextEffect
{
    [effectManager activateNextEffect];
    
    ++numberOfEffectsViewed;
    if(![Store hasEffectPackOne] &&
       ![upgradeTeaserViewController hasBeenShown] &&
       numberOfEffectsViewed > 4)
    {
        [self stopRendering];
        [UIView transitionWithView: self.view
                          duration: 0.5
                           options: UIViewAnimationOptionTransitionFlipFromRight
                        animations: ^{ [self.view addSubview: upgradeTeaserViewController.view]; }
                        completion: NULL];
    }
}

- (IBAction) goToPreviousEffect
{
    [effectManager activatePreviousEffect];
    
    ++numberOfEffectsViewed;
    if(![Store hasEffectPackOne] &&
       ![upgradeTeaserViewController hasBeenShown] &&
       numberOfEffectsViewed > 4)
    {
        [self stopRendering];
        [UIView transitionWithView: self.view
                          duration: 0.5
                           options: UIViewAnimationOptionTransitionFlipFromRight
                        animations: ^{ [self.view addSubview: upgradeTeaserViewController.view]; }
                        completion: NULL];
    }
}

- (void) activeEffectDidChange: (NSNotification*) notification
{
    // Update the effect name to reflect the new effect's name
    self.effectNameLabel.text = effectManager.activeEffectName;
	
    [renderer setEffect: effectManager.activeEffect];
    
    // Update slider controls for the active effect
    [self updateSlider: sliderOne
    withEffectVariable: [effectManager.activeEffect effectVariableAtIndex: 0]];
    
    [self updateSlider: sliderTwo
    withEffectVariable: [effectManager.activeEffect effectVariableAtIndex: 1]];
        
    [self startHideUITimer];
    
    self.effectNameTextField.text = effectManager.activeEffectName;
}

- (void) updateSlider: (UISlider*) slider
   withEffectVariable: (EffectVariable*) effectVariable
{
    if(effectVariable)
    {
        if(effectVariable.minValue > effectVariable.maxValue)
        {
            slider.minimumValue = effectVariable.maxValue;
            slider.maximumValue = effectVariable.minValue;
            slider.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
        else
        {
            slider.minimumValue = effectVariable.minValue;
            slider.maximumValue = effectVariable.maxValue;
            slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
        slider.value = effectVariable.defaultValue;
        slider.continuous = effectVariable.continuous;
        [self showSlider: slider animated: YES];
    }
    else
    {
        [self hideSlider: slider animated: YES];
    }

}

- (IBAction) valueDidChangeForSlider: (id) sender
{
    NSAssert([sender isKindOfClass: [UISlider class]], @"Sender should be a UISlider");
    
    UISlider* slider = (UISlider*) sender;
    
    if (!slider.continuous)
    {
        int closestVal = (int) (slider.value + 0.5f);
        slider.value = (float) closestVal;
    }
    
    if (slider.tag == 0)
    {
        [effectManager.activeEffect effectVariableAtIndex: 0
                                           didChangeValue: slider.value];
    }
    else if (slider.tag == 1)
    {
        [effectManager.activeEffect effectVariableAtIndex: 1
                                           didChangeValue: slider.value];
    }
    
    [self startHideUITimer];
}

- (void) touchesBegan: (NSSet*) touches
            withEvent: (UIEvent*) event
{
    if([touches count] == 1)
    {
        if(uiIsHidden)
        {
            [self showUIAnimated: YES];
        }
        else
        {
            [self hideUIAnimated: YES];
        }
    }
}

- (void) startHideUITimer
{
    [hideUITimer invalidate];
    [hideUITimer release];
    hideUITimer = [[NSTimer scheduledTimerWithTimeInterval: 5.0f
                                                    target: self
                                                  selector: @selector(hideUI)
                                                  userInfo: nil
                                                   repeats: NO] retain];
}

- (void) showUI
{
    [self showUIAnimated: YES];
}

- (void) hideUI
{
    [self hideUIAnimated: YES];
}

- (void) showUIAnimated: (BOOL) animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
    }
    
    CGRect newToolbarFrame = toolBar.frame;
    newToolbarFrame.origin.y = 0;
    toolBar.frame = newToolbarFrame;
    
    CGRect newEffectNameLabelFrame = effectNameLabel.frame;
    newEffectNameLabelFrame.origin.y = toolBar.frame.size.height;
    effectNameLabel.frame = newEffectNameLabelFrame;
    
    CGRect newToggleCameraButtonFrame = toggleCameraButton.frame;
    newToggleCameraButtonFrame.origin.x = self.view.frame.size.width - toggleCameraButton.frame.size.width;
    toggleCameraButton.frame = newToggleCameraButtonFrame;
    
    if (animated)
    {
        [UIView commitAnimations];
    }
    
    uiIsHidden = NO;
    
    if ([effectManager.activeEffect effectVariableAtIndex: 0])
    {
        [self showSlider: sliderOne animated: animated];
    }
    if ([effectManager.activeEffect effectVariableAtIndex: 1])
    {
        [self showSlider: sliderTwo animated: animated];
    }
    
    [self startHideUITimer];
}

- (void) hideUIAnimated: (BOOL) animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
    }
        
    CGRect newToolbarFrame = toolBar.frame;
    newToolbarFrame.origin.y = -toolBar.frame.size.height - effectNameLabel.frame.size.height;
    toolBar.frame = newToolbarFrame;
    
    CGRect newEffectNameLabelFrame = effectNameLabel.frame;
    newEffectNameLabelFrame.origin.y = -effectNameLabel.frame.size.height;
    effectNameLabel.frame = newEffectNameLabelFrame;
    
    CGRect newToggleCameraButtonFrame = toggleCameraButton.frame;
    newToggleCameraButtonFrame.origin.x = self.view.frame.size.width;
    toggleCameraButton.frame = newToggleCameraButtonFrame;
    
    if (animated)
    {
        [UIView commitAnimations];
    }
    
    uiIsHidden = YES;
    
    [self hideSlider: sliderOne animated: animated];
    [self hideSlider: sliderTwo animated: animated];
}

- (void) dismissModalViewController: (NSNotification*) notification
{
    [self startRendering];
    
    [capturePreviewViewController willHide];
    [UIView animateWithDuration: 0.5
                          delay: 0.0
                        options: 0
                     animations: ^{
                                      capturePreviewViewController.view.alpha = 0.0f;
                                      self.view.alpha = 1.0f;
                                  }
                     completion: ^( BOOL finished )
                                   {
                                       if(finished)
                                       {
                                           [capturePreviewViewController.view removeFromSuperview];                                           
                                       }
                                   }
                        
    ];        
}

static const float sliderOneX = 212.0f;

- (void) showSlider: (UISlider*) slider
           animated: (BOOL) animated
{
    if (animated)
    {
        [UIView animateWithDuration: 0.3
                         animations: ^{ slider.frame = CGRectMake(10, slider.frame.origin.y,
                                                                  slider.frame.size.width, slider.frame.size.height ); 
                                    }
                         completion: ^( BOOL finished ) { }];
    }
    else
    {
        slider.frame = CGRectMake(10, slider.frame.origin.y,
                                  slider.frame.size.width, slider.frame.size.height);
    }

}

- (void) hideSlider: (UISlider*) slider
           animated: (BOOL) animated
{
    if (animated)
    {
    [UIView animateWithDuration: 0.3
                     animations: ^{ slider.frame = CGRectMake(-slider.frame.size.width - 10, slider.frame.origin.y,
                                                              slider.frame.size.width, slider.frame.size.height);
                                  }
                     completion: ^( BOOL finished ) { }];
    }
    else
    {
        slider.frame = CGRectMake(-slider.frame.size.width - 10, slider.frame.origin.y,
                                  slider.frame.size.width, slider.frame.size.height);
    }
}

#if SHOWFPS
    static int frame = 0;
#endif

- (void) didRenderFrame: (NSNotification*) notification
{
#if SHOWFPS
    frame = (frame + 1) % 5;
    if(frame == 0)
    {
        fpsLabel.text = [NSString stringWithFormat: @"%2.f\n", fpsCalculator.currentFPS];
    }
#endif
}

- (void) didProcessVideoFrame: (NSNotification*) notification
{
    [notification.object release];
#if SHOWFPS
    if (frame == 0)
    {
        vfpsLabel.text = [NSString stringWithFormat: @"%2.f\n", vfpsCalculator.currentFPS];
    }
#endif
}

@end
