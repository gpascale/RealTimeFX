//
//  Watermarker.h
//  RealTimeFx
//
//  Created by Greg on 8/16/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Store.h"

@interface Watermarker : NSObject
{
@private
    UIImageView* compositeView;
    UIView* watermark;
}

@property (nonatomic, retain) IBOutlet UIView* watermark;

+ (UIImage*) addWatermarkIfNoUpgrade:(UIImage*)image;

@end
