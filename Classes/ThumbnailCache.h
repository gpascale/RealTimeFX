//
//  ThumbnailCache.h
//  RealTimeFx
//
//  Created by Greg on 7/25/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ThumbnailCache : NSObject
{
    NSMutableDictionary* thumbnails;
}

+ (ThumbnailCache*) sharedCache;

- (UIImage*) thumbnailForEffectWithName: (NSString*) effectName;

- (void) clear;

@end
