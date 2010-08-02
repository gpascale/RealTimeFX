//
//  ThreeEffectTableViewCell.m
//  RealTimeFx
//
//  Created by Greg on 7/5/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "ThreeEffectTableViewCell.h"
#import "EffectSelectorViewController.h"
#import "ThumbnailCache.h"
#import <QuartzCore/QuartzCore.h>

@interface ThreeEffectTableViewCell (private)

- (void) didTapButton: (id) sender;

@end

@implementation ThreeEffectTableViewCell

@synthesize buttonLeft;
@synthesize buttonCenter;
@synthesize buttonRight;
@synthesize labelLeft;
@synthesize labelCenter;
@synthesize labelRight;
@synthesize imageLeft;
@synthesize imageCenter;
@synthesize imageRight;
@synthesize parentView;

- (void) awakeFromNib
{
    [buttonLeft addTarget: self action: @selector(didTapButton:) forControlEvents: UIControlEventTouchUpInside];
    [buttonCenter addTarget: self action: @selector(didTapButton:) forControlEvents: UIControlEventTouchUpInside];
    [buttonRight addTarget: self action: @selector(didTapButton:) forControlEvents: UIControlEventTouchUpInside];
    
    imageLeft.layer.masksToBounds = YES;
    imageLeft.layer.cornerRadius = 10.0;
    
    imageCenter.layer.masksToBounds = YES;
    imageCenter.layer.cornerRadius = 10.0;
    
    imageRight.layer.masksToBounds = YES;
    imageRight.layer.cornerRadius = 10.0;
    
    UIView* backgroundView = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 130)] autorelease];
    backgroundView.backgroundColor = [UIColor colorWithRed: 42.0f / 255.0f
                                                     green: 42.0f / 255.0f
                                                      blue: 42.0f / 255.0f
                                                     alpha: 1.0f];
    backgroundView.opaque = YES;
    self.backgroundView = backgroundView;
}

- (void) dealloc
{
    self.buttonLeft = nil;
    self.buttonCenter = nil;
    self.buttonRight = nil;
    self.labelLeft = nil;
    self.labelCenter = nil;
    self.labelRight = nil;
    self.imageLeft = nil;
    self.imageCenter = nil;
    self.imageRight = nil;
    [super dealloc];
}

- (void) setEffectForIndex: (NSInteger) index
                  withName: (NSString*) effectName
{
    switch(index)
    {
        case 0:
            labelLeft.text = effectName;
            imageLeft.image = [[ThumbnailCache sharedCache] thumbnailForEffectWithName: effectName];
            break;
        case 1:
            labelCenter.text = effectName;
            imageCenter.image = [[ThumbnailCache sharedCache] thumbnailForEffectWithName: effectName];
            break;
        case 2:
            labelRight.text = effectName;
            imageRight.image = [[ThumbnailCache sharedCache] thumbnailForEffectWithName: effectName];
            break;
        default:
            NSAssert(NO, @"Index must be between 0 and 2");
            break;
            
    }
}

- (void) clearSelection
{
    imageLeft.layer.borderWidth = 0.0;    
    imageCenter.layer.borderWidth = 0.0;    
    imageRight.layer.borderWidth = 0.0;
}

- (void) setSelection: (int) index
{
    [self clearSelection];
    
    UIImageView* imageView = (index == 0) ? imageLeft : ((index == 1) ? imageCenter : imageRight);
    
    imageView.layer.borderWidth = 5.0;
    imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void) didTapButton: (id) sender
{    
    if(![sender isKindOfClass: [UIButton class]])
    {
        NSAssert(NO, @"Not a UIButton");
        return;
    }
    
    switch(((UIButton*)sender).tag)
    {
        case ButtonTag_Left:
            if(![labelLeft.text isEqualToString: @""])
            {
                [self setSelection: 0];
                [parentView didSelectEffectWithName: labelLeft.text];                
            }
            break;
        case ButtonTag_Center:
            if(![labelCenter.text isEqualToString: @""])
            {
                [self setSelection: 1];
                [parentView didSelectEffectWithName: labelCenter.text];                
            }
            break;
        case ButtonTag_Right:
            if(![labelRight.text isEqualToString: @""])
            {
                [self setSelection: 2];
                [parentView didSelectEffectWithName: labelRight.text];                
            }
            break;
        default:
            NSAssert(NO, @"Button unrecognized");
    }
}

@end
