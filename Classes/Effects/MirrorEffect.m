//
//  MirrorEffect.m
//  RealTimeFx
//
//  Created by Greg on 8/22/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "Effect.h"
#import "ImageUtils.h"
#import "GLUtils.h"

#define MMIN(a, b) (a < b) ? (a) : (b)
#define MMAX(a, b) (a > b) ? (a) : (b)

@interface MirrorEffect : Effect
{
	int mirrorType;
    GLint u_mirrorType;
}
@end

@implementation MirrorEffect

- (void) activate
{
	[super activate];
	
    mirrorType = 1;
    GLCHECK(u_mirrorType = glGetUniformLocation(self.shaderProgram, "u_mirrorType"));
    assert(u_mirrorType >= 0);
}

- (void) willRenderFrame
{
    GLCHECK(glUniform1i(u_mirrorType, mirrorType));
}

- (EffectVariable*) effectVariableAtIndex: (NSInteger) index
{
    if(index == 0)
    {
        return [[[EffectVariable alloc] initWithMinValue: 0.0f
                                                maxValue: 2.0f 
                                            defaultValue: 1.0f
                                              continuous: NO] autorelease];
    }
    else
    {
        return nil;
    }
}

- (void) effectVariableAtIndex: (NSInteger) index
                didChangeValue: (float) newValue
{
    mirrorType = MMIN(MMAX((int) (newValue + 0.5f), 0), 2);
    NSLog(@"Mirror type is now %d\n", mirrorType);
}

@end
