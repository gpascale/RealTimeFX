//
//  PosterizeLUTEffect.m
//  RealTimeFx
//
//  Created by Greg on 7/3/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "Effect.h"
#import "ImageUtils.h"
#import "GLUtils.h"

@interface PosterizeLUTEffect : Effect
{
	GLuint gradientTexture;
}
@end

@implementation PosterizeLUTEffect

- (id) initWithVertexShaderPath: (NSString*) vertexShaderPath
			 fragmentShaderPath: (NSString*) fragmentShaderPath
{
	if(self = [super initWithVertexShaderPath: vertexShaderPath fragmentShaderPath: fragmentShaderPath])
	{        
        GLCHECK(glGenTextures(1, &gradientTexture));
		GLCHECK(glBindTexture(GL_TEXTURE_2D, gradientTexture));
        
		NSData* data = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"posterize" ofType: @"lut"]];
        NSAssert([data length] == 32 * 32 * 32 * 4, @"");
        const int width = 32 * 32;
        const int height = 32;
        
		GLCHECK(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, [data bytes]));
        
		GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST));
		GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST));
		GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE));
		GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE));
		GLCHECK(glBindTexture(GL_TEXTURE_2D, 0));
	}
	
	return self;
}

- (void) activate
{
	[super activate];
	
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, gradientTexture);
	glActiveTexture(GL_TEXTURE0);
}

@end