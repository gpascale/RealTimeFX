/*
 *  FilmEffect.h
 *  RealTimeFx
 *
 *  Created by Greg on 7/4/10.
 *  Copyright 2010 Brown University. All rights reserved.
 *
 */

#import "Effect.h"
#import "GLUtils.h"

@interface FilmEffect : Effect
{
	GLuint filmGrainTexture;
    
    float intensity;
    
    // Uniforms
    GLint u_rotationAmt;
    GLint u_intensity;
}

@end;