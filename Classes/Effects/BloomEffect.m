//
//  BloomEffect.m
//  RealTimeFx
//
//  Created by Greg on 7/11/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "Effect.h"
#import "ImageUtils.h"
#import "GLUtils.h"

@interface BloomEffect : Effect
{
	GLuint texture;
}
@end

@implementation BloomEffect

- (id) initWithVertexShaderPath: (NSString*) vertexShaderPath
			 fragmentShaderPath: (NSString*) fragmentShaderPath
{
	if(self = [super initWithVertexShaderPath: vertexShaderPath fragmentShaderPath: fragmentShaderPath])
	{
		GLCHECK(glGenTextures(1, &texture));
		GLCHECK(glBindTexture(GL_TEXTURE_2D, texture));
        
		NSData* data = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"bloom" ofType: @"lut"]];
        NSAssert([data length] == 256 * sizeof(float), @"");
        const int width = 256;
        const int height = 1;		
        
		GLCHECK(glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_FLOAT, [data bytes]));
        
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
	glBindTexture(GL_TEXTURE_2D, texture);
	glActiveTexture(GL_TEXTURE0);
}

@end
