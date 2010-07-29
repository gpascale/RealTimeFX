//
//  FPSCalculator.m
//  RealTimeFx
//
//  Created by Greg on 7/8/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "FPSCalculator.h"

using namespace std;

@interface FPSCalculator ( Private )

- (void) didRenderFrame: (NSNotification*) notification;

@end

@implementation FPSCalculator

@synthesize currentFPS;

- (id) initWithFrameNotificationName: (NSString*) notificationName
{
    if(self = [super init])
    {
        currentFPS = 0;
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(didRenderFrame:)
                                                     name: notificationName
                                                   object: nil];
    }
    return self;
}

- (void) didRenderFrame: (NSNotification*) notification
{
    NSAssert([notification.object isKindOfClass: [NSDate class]], @"");
    NSDate* frameTime = (NSDate*) notification.object;
    
    if(lastFrameTime)
    {
        
        const float frameDuration = [frameTime timeIntervalSinceDate: lastFrameTime];
        if(lastNFrames.size() >= 5)
        {
            lastNFrames.pop_front();
        }
        lastNFrames.push_back(frameDuration);
    }
    
    [lastFrameTime release];
    lastFrameTime = [frameTime retain];
    
    const int nFramesInAverage = lastNFrames.size();
    float totalTime = 0.0f;
    for(list<float>::const_iterator iter = lastNFrames.begin();
        iter != lastNFrames.end();
        ++iter)
    {
        totalTime += *iter;
    }
    
    if(nFramesInAverage > 0)
    {
        currentFPS = nFramesInAverage / totalTime;
    }
}

@end
