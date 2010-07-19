//
//  Camera.h
//  RealTimeFx
//
//  Created by Greg on 6/27/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "Camera.h"
#import "GLUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@class EAGLContext;
@class AVCaptureSession;

@interface SimulatorCamera : NSObject <Camera>
{
	// Graphics
	GLuint m_texture;	
	CGSize textureSize;
	CGSize imageSize;
	EAGLContext* context;
	
	GLuint m_displacementTexture;
}

- (GLuint) getTexture;
- (GLuint) getDisplacementTexture;

- (void) takePicture;

@property (nonatomic) CGSize textureSize;
@property (nonatomic) CGSize imageSize;

@end
