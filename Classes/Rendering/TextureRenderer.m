/*
 
 File: TextureRenderer.m
 
 Abstract: The TextureRenderer class creates an OpenGL ES 2.0 context and draws 
 using OpenGL ES 2.0 shaders.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
*/

#import "TextureRenderer.h"
#import "Shaders.h"
#import "Effect.h"
#include "matrix.h"

#include <OpenGLES/ES2/glext.h>

GLint uniforms[NUM_UNIFORMS];

@interface TextureRenderer (PrivateMethods)
- (BOOL) loadShaders;
@end

@implementation TextureRenderer

// Create an ES 2.0 context
- (TextureRenderer*) initWithContext: (EAGLContext*) ctx
{
	if (self = [super init])
	{
		context = ctx;
        
        if (!context || ![EAGLContext setCurrentContext:context])
		{
            [self release];
            return nil;
        }
		
		// Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
		GLCHECK(glGenFramebuffers(1, &defaultFramebuffer));
		GLCHECK(glGenRenderbuffers(1, &colorRenderbuffer));
		GLCHECK(glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer));
		GLCHECK(glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer));
		GLCHECK(glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer));
    }
	
	return self;
}

- (void) bindPrimaryTexture: (GLuint) texture
{
	GLCHECK(glActiveTexture(GL_TEXTURE0));
	GLCHECK(glBindTexture(GL_TEXTURE_2D, texture));
}

- (void) bindSecondaryTexture: (GLuint) texture
{
	GLCHECK(glActiveTexture(GL_TEXTURE1));
	GLCHECK(glBindTexture(GL_TEXTURE_2D, texture));
	GLCHECK(glActiveTexture(GL_TEXTURE0));
}

NSDate* curDate = nil;

- (void) render
{
    [EAGLContext setCurrentContext:context];
    
    const const GLfloat positions[] =
    {
		 -1.0f, -1.0f, 0.0f, 1.0f, 
		 1.0f, -1.0f, 0.0f, 1.0f,
		 -1.0f, 1.0f, 0.0f, 1.0f,
	  	 1.0f, 1.0f, 0.0f, 1.0f
    };

#if TARGET_IPHONE_SIMULATOR
    static const GLfloat texCoords[] =
	{
		0.0f, 1.0f,
		1.0f, 1.0f,
		0.0f, 0.0f,
        1.0f, 0.0f
	};
#else
    static const GLfloat texCoords[] =
    {
		1.0f, 1.0f - (1.0f/18.0f),
		1.0f, 1.0f/18.0f,
		0.0f, 1.0f - (1.0f/18.0f),
        0.0f, 1.0f/18.0f
	};
#endif

    GLuint program = activeEffect.shaderProgram;
	GLCHECK(glUseProgram(program));
    
	// set vertex attributes
    GLCHECK(glVertexAttribPointer(ATTRIB_POSITION, 4, GL_FLOAT, GL_FALSE, 0, positions));
	GLCHECK(glEnableVertexAttribArray(ATTRIB_POSITION));
    GLCHECK(glVertexAttribPointer(ATTRIB_TEXCOORDS, 2, GL_FLOAT, GL_FALSE, 0, texCoords));
	GLCHECK(glEnableVertexAttribArray(ATTRIB_TEXCOORDS));
	
	// set uniform variables
	GLCHECK(glUniform1i(uniforms[UNIFORM_TEXTURE_2D_0], 0));
	GLCHECK(glUniform1i(uniforms[UNIFORM_TEXTURE_2D_1], 1));
	 
    GLCHECK(glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer));
    GLCHECK(glViewport(0, 0, backingWidth, backingHeight));			

	// Validate program before using. This is a good check, but only really necessary in a debug build.
	// DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
	if (!validateProgram(activeEffect.shaderProgram))
	{
		NSLog(@"Failed to validate program");
		return;
	}
#endif	   
    
    [activeEffect willRenderFrame];
				
	// draw
    GLCHECK(glDrawArrays(GL_TRIANGLE_STRIP, 0, 4));
    
    GLCHECK(glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer));
    [context presentRenderbuffer:GL_RENDERBUFFER];
    
    [curDate release];
    curDate = [[NSDate date] retain];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"RenderedFrame"
                                                        object: curDate];
}

- (UIImage*) captureScreen
{
    // Read the contents of the color buffer
    GLCHECK(glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer));
    unsigned char pixels[4 * backingWidth * backingHeight];
    GLCHECK(glReadPixels(0, 0, backingWidth, backingHeight, GL_RGBA, GL_UNSIGNED_BYTE, pixels));
    
    // Create the image
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(pixels, backingWidth, backingHeight, 8, 
                                                       4*backingWidth, colorSpace, 
                                                       kCGImageAlphaNoneSkipLast);        
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    
    // glReadPixels returns the lower left pixel first, but CG expects the origin in
    // the upper left. Redraw the image upside down.
    CGContextScaleCTM(bitmapContext, 1.0f, -1.0f);
    CGContextTranslateCTM(bitmapContext, 0.0f, -480.0f);    
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, 320, 480), cgImage);
    
    CGImageRelease(cgImage);
    cgImage = CGBitmapContextCreateImage(bitmapContext);
    
    // Create a UIImage out of it.
    UIImage* ret = [[UIImage alloc] initWithCGImage: cgImage];

    // Cleanup
    CFRelease(colorSpace);
    CGContextRelease(bitmapContext);
    CGImageRelease(cgImage);
    
    return [ret autorelease];
}

- (void) setEffect: (Effect*) effect
{
    if(activeEffect == effect)
    {
        return;
    }
    
	[EAGLContext setCurrentContext: context];
    
    // Verify the shader program and read common uniform locations
    GLuint shaderProgram = effect.shaderProgram;
    GLCHECK(glIsProgram(shaderProgram));
    GLCHECK(uniforms[UNIFORM_TEXTURE_2D_0] = glGetUniformLocation(shaderProgram, "u_sampler0"));
	GLCHECK(uniforms[UNIFORM_TEXTURE_2D_1] = glGetUniformLocation(shaderProgram, "u_sampler1"));
    
    // Delegate to the effect for custom initialization	
    [effect activate];
    
    activeEffect = effect;
    
    printf("ActiveEffect = %p\n", activeEffect);
}

- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer
{
	// Allocate color buffer backing based on the current layer size
   GLCHECK(glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer));
   [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
	GLCHECK(glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth));
   GLCHECK(glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight));
	
   if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
       NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
       return NO;
   }
	
   return YES;
}

- (void) dealloc
{
	// tear down GL
	if (defaultFramebuffer)
	{
		glDeleteFramebuffers(1, &defaultFramebuffer);
		defaultFramebuffer = 0;
	}
	
	if (colorRenderbuffer)
	{
		glDeleteRenderbuffers(1, &colorRenderbuffer);
		colorRenderbuffer = 0;
	}
	
	// tear down context
	if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	
	[context release];
	context = nil;
	
	[super dealloc];
}

@end
