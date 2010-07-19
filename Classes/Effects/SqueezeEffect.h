/*
 *  SqueezeEffect.h
 *  RealTimeFx
 *
 *  Created by Greg on 7/10/10.
 *  Copyright 2010 Brown University. All rights reserved.
 *
 */

#import "Effect.h"
#import "GLUtils.h"

@interface SqueezeEffect : Effect
{
    float power;
    
    // Uniforms
    GLint u_power;
}

@end;