//
//  PopArtEffect.m
//  RealTimeFx
//
//  Created by Greg on 7/11/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "Effect.h"
#import "ImageUtils.h"
#import "GLUtils.h"

@interface PopArtEffect : Effect
{
	GLuint texture;
}
@end

@implementation PopArtEffect

- (id) initWithVertexShaderPath: (NSString*) vertexShaderPath
			 fragmentShaderPath: (NSString*) fragmentShaderPath
{
	if(self = [super initWithVertexShaderPath: vertexShaderPath fragmentShaderPath: fragmentShaderPath])
	{
		GLCHECK(glGenTextures(1, &texture));
		GLCHECK(glBindTexture(GL_TEXTURE_2D, texture));
        
		int width, height;
		UIImage* image = [[UIImage imageNamed: @"sketch.png"] autorelease];
		const void* pixels = decodeImage(image, &width, &height);		
        
		GLCHECK(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels));
        
		GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR));
		GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR));
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
