//
//  ThumbnailCache.m
//  RealTimeFx
//
//  Created by Greg on 7/25/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "ThumbnailCache.h"

static ThumbnailCache* instance;

@implementation ThumbnailCache

+ (void) initialize
{
    instance = [[ThumbnailCache alloc] init];
}

+ (ThumbnailCache*) sharedCache
{
    return instance;
}

- (UIImage*) thumbnailForEffectWithName: (NSString*) effectName
{
    if (thumbnails == nil)
    {
        thumbnails = [[NSMutableDictionary alloc] init];
    }
    
    UIImage* ret = [thumbnails objectForKey: effectName];
    
    if(ret == nil)
    {
        NSString* name = [effectName stringByAppendingString: @"_thumb"];
        NSString* path = [[NSBundle mainBundle] pathForResource: name ofType: @"png"];
        ret = [UIImage imageWithContentsOfFile: path];
        [thumbnails setObject: ret forKey: effectName];
    }
    
    return ret;
}

- (void) clear
{
    [thumbnails removeAllObjects];
}

@end
