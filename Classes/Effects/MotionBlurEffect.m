//
//  MotionBlurEffect.m
//  RealTimeFx
//
//  Created by Greg on 7/2/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "Effect.h"
#import "GLUtils.h"

@interface MotionBlurEffect : Effect
{
    float alpha;
	GLuint u_alpha;
}
@end

@implementation MotionBlurEffect

- (void) activate
{
    [super activate];    
    
    GLCHECK(glEnable(GL_BLEND));
    GLCHECK(glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA));
    GLCHECK(u_alpha = glGetUniformLocation(shaderProgram, "u_alpha"));
    
    alpha = 0.3f;
}

- (void) willRenderFrame
{
    glUniform1f(u_alpha, alpha);
}

- (EffectVariable*) effectVariableAtIndex: (NSInteger) index
{
    if(index == 0)
    {
        return [[[EffectVariable alloc] initWithMinValue: 0.35f maxValue: 0.05f defaultValue: 0.2f] autorelease];
    }
    else
    {
        return nil;
    }
}

- (void) effectVariableAtIndex: (NSInteger) index
                didChangeValue: (float) newValue
{
    alpha = newValue;
}

@end
