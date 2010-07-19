//
//  RealTimeFxViewController.h
//  RealTimeFx
//
//  Created by Greg on 6/27/10.
//  Copyright Brown University 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EffectSelectorViewController;
@class CapturePreviewViewController;
@class UpgradeTeaserViewController;
@class EffectManager;
@class TextureRenderer;
@class EAGLContext;
@class FPSCalculator;
@class RenderView;
@protocol Camera;

@interface RealTimeFxViewController : UIViewController {

@private
    
	EffectSelectorViewController* selectorViewController;
	EffectManager* effectManager;
	TextureRenderer* renderer;
	EAGLContext* context;
        
    // UI autohide
    NSTimer* hideUITimer;
    BOOL uiIsHidden;
    
    // Child UI Controls
    RenderView* renderView;
    UIToolbar* toolBar;
    UILabel* effectNameLabel;
    
    UISlider* sliderOne;
    UISlider* sliderTwo;
    
    // Camera
    NSObject<Camera>* camera;
    
    FPSCalculator* fpsCalculator;
    FPSCalculator* vfpsCalculator;
    
    UpgradeTeaserViewController* upgradeTeaserViewController;
}

// Child UIControls
@property (nonatomic, retain) IBOutlet RenderView* renderView;
@property (nonatomic, retain) IBOutlet UIToolbar* toolBar;
@property (nonatomic, retain) IBOutlet UILabel* effectNameLabel;
@property (nonatomic, retain) IBOutlet UILabel* fpsLabel;
@property (nonatomic, retain) IBOutlet UILabel* vfpsLabel;
@property (nonatomic, retain) IBOutlet UISlider* sliderOne;
@property (nonatomic, retain) IBOutlet UISlider* sliderTwo;

@property (nonatomic, retain) IBOutlet CapturePreviewViewController* capturePreviewViewController;
@property (nonatomic, retain) IBOutlet EffectSelectorViewController* selectorViewController;
@property (nonatomic, retain) IBOutlet UpgradeTeaserViewController* upgradeTeaserViewController;

@property (nonatomic, readonly) BOOL isRendering;

- (void) startRendering;
- (void) stopRendering;

- (IBAction) didTapCaptureButton;
- (IBAction) showEffectSelectorView;
- (IBAction) goToNextEffect;
- (IBAction) goToPreviousEffect;
- (IBAction) valueDidChangeForSlider: (id) sender;

//! Touch handler
- (void) touchesBegan: (NSSet*) touches
            withEvent: (UIEvent*) event;

- (void) activeEffectDidChange: (NSNotification*) notification;

@end

