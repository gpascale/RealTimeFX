//
//  Watermarker.m
//  RealTimeFx
//
//  Created by Greg on 8/16/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "Watermarker.h"

static Watermarker* instance;

@interface Watermarker (Private)

- (UIImage*) _addWatermarkIfNoUpgrade:(UIImage*)image;

@end

@implementation Watermarker

+ (void) initialize
{
    instance = [[Watermarker alloc] init];
}

+ (UIImage*) addWatermarkIfNoUpgrade:(UIImage*)image
{
    if([Store hasEffectPackOne])
    {
        // No watermark if they have the upgrade
        return image;
    }
    
    return [instance _addWatermarkIfNoUpgrade:image];
}

- (UIImage*) _addWatermarkIfNoUpgrade:(UIImage*)image
{
    if(compositeView == nil)
    {
        compositeView = [[UIImageView alloc] initWithImage:image];
        [compositeView addSubview:watermark];
    }
    else
    {
        compositeView.image = image;
    }
    
    
    UIGraphicsBeginImageContext(compositeView.frame.size);
    [compositeView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* blendedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return blendedImage;
}

@end