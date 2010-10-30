/*
 *  glUtils.h
 *  RealTimeFx
 *
 *  Created by Greg on 6/27/10.
 *  Copyright 2010 Brown University. All rights reserved.
 *
 */

#import <stdio.h>
#ifdef __cplusplus
extern "C" {
#endif
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

extern void checkGLError(const char* file, const int line, const char* code);

#ifdef __cplusplus
}
#endif

// uniform index
enum
{
	UNIFORM_TEXTURE_2D_0 = 0,
	UNIFORM_TEXTURE_2D_1,
    UNIFORM_TEXTURE_2D_2,
    UNIFORM_TEXTURE_2D_3,
    UNIFORM_SPECIAL_0,
    UNIFORM_SPECIAL_1,
	NUM_UNIFORMS
};

// attribute index
enum
{
	ATTRIB_POSITION = 0,
	ATTRIB_TEXCOORDS,
	NUM_ATTRIBUTES
};

#if DEBUG
	#define GLCHECK(expr) expr; checkGLError(__FILE__, __LINE__, #expr)
#else
	#define GLCHECK(expr) expr
#endif