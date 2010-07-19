//
//  StretchEffect.m
//  RealTimeFx
//
//  Created by Greg on 7/11/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "StretchEffect.h"


@implementation StretchEffect

- (void) activate
{
    power = 1.0f;
}

- (void) willRenderFrame
{
    glUniform1f(u_power, power);
}

- (EffectVariable*) effectVariableAtIndex: (NSInteger) index
{
    if(index == 0)
    {
        return [[[EffectVariable alloc] initWithMinValue: 0.3f maxValue: 2.0f defaultValue: 1.0f] autorelease];
    }
    else
    {
        return nil;
    }
}

- (void) effectVariableAtIndex: (NSInteger) index
                didChangeValue: (float) newValue
{
    power = newValue;
}

@end
