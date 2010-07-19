//
//  SpectrumEffect.m
//  RealTimeFx
//
//  Created by Greg on 7/15/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "Effect.h"
#import "GLUtils.h"

@interface SpectrumEffect : Effect
{
    float multiplier;
    GLint u_multiplier;
}

@end

@implementation SpectrumEffect

- (void) activate
{
    [super activate];
    
    multiplier = 1.0f;
}

- (void) willRenderFrame
{
    glUniform1f(u_multiplier, multiplier);
}

- (EffectVariable*) effectVariableAtIndex: (NSInteger) index
{
    if(index == 0)
    {
        return [[[EffectVariable alloc] initWithMinValue: 0.0f maxValue: 2.0f defaultValue: 1.0f] autorelease];
    }
    else
    {
        return nil;
    }
}

- (void) effectVariableAtIndex: (NSInteger) index
                didChangeValue: (float) newValue
{
    multiplier = newValue;
}

@end

