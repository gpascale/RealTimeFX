/*
 *  GLUtils.c
 *  RealTimeFx
 *
 *  Created by Greg on 6/27/10.
 *  Copyright 2010 Brown University. All rights reserved.
 *
 */
 
#import "GLUtils.h"

inline void checkGLError(const char* file, const int line, const char* code)
{
	GLenum errNo = glGetError();
	if(errNo != GL_NO_ERROR)
	{
		const char* errorMsg = NULL;
		switch (errNo)
		{
			case GL_INVALID_ENUM:
				errorMsg = "Invalid Enum";
				break;
			case GL_INVALID_VALUE:
				errorMsg = "Invalid Value";
				break;
			case GL_INVALID_OPERATION:
				errorMsg = "Invalid Operation";
				break;
			default:
				errorMsg = "Unknown Error";
				break;
		}
		printf("GL error: \'%s\' at line %d in file %s: %s\n", errorMsg, line, file, code);
	}
}