//
//  FPSCalculator.h
//  RealTimeFx
//
//  Created5 by Greg on 7/8/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifdef __cplusplus
#include <list>
#endif

@interface FPSCalculator : NSObject
{
    
#ifdef __cplusplus
    std::list<float> lastNFrames;
#endif
    
    NSDate* lastFrameTime;
    
    float currentFPS;
}

- (id) initWithFrameNotificationName: (NSString*) notificationName;

@property (nonatomic) float currentFPS;

@end
