//
//  Camera.m
//  RealTimeFx
//
//  Created by Greg on 6/27/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#if TARGET_IPHONE_SIMULATOR

#import "SimulatorCamera.h"
#import "ImageUtils.h"
#import <OpenGLES/EAGL.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <CoreGraphics/CoreGraphics.h>

@interface SimulatorCamera (private)

- (void) configureAVSession;
- (void) createTexture;

@end

@implementation SimulatorCamera

@synthesize imageSize;
@synthesize textureSize;

- (id) init
{
	if ((self = [super init]))
	{
		// Create a texture to use for rendering and processing video
		[self createTexture];
	}
	return self;
}

- (GLuint) getTexture
{
	return m_texture;
}

- (GLuint) getDisplacementTexture
{
	return 0;
}

- (void) createTexture
{
	GLCHECK(glGenTextures(1, &m_texture));
	GLCHECK(glBindTexture(GL_TEXTURE_2D, m_texture));
	
	int width, height, bufferWidth, bufferHeight;
	UIImage* image = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"image" ofType: @"JPG"]];
    const void* pixels = decodeImage(image, &width, &height);		
 
	GLCHECK(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels));
	
	GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR));
	GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR));
	GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE));
	GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE));
	GLCHECK(glBindTexture(GL_TEXTURE_2D, 0));
	
	imageSize = CGSizeMake(width, height);
	textureSize = CGSizeMake(bufferWidth, bufferHeight);
    
    free(pixels);
}

- (void) takePicture
{
    UIImage* image = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Tillicum" ofType: @"jpg"]];    
}

- (void) startCapturing
{
    
}

- (void) stopCapturing
{
    
}

- (BOOL) hasMultipleCameras
{
    return NO;
}

- (void) toggleCameras
{
    
}

@end

#endif