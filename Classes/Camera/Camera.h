//
//  Camera.h
//  RealTimeFx
//
//  Created by Greg on 6/30/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "GLUtils.h"

@protocol Camera

- (GLuint) getTexture;
- (GLuint) getDisplacementTexture;

- (void) startCapturing;
- (void) stopCapturing;

// support for front + back cameras
- (BOOL) hasMultipleCameras;
- (void) toggleCameras;

@property (readonly, nonatomic) BOOL isCapturing;
@property (nonatomic) CGSize textureSize;
@property (nonatomic) CGSize imageSize;

@end
