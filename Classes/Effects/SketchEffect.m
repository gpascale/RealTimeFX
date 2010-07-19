//
//  SketchEffect.m
//  RealTimeFx
//
//  Created by Greg on 7/14/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "Effect.h"
#import "GLUtils.h"
#import "ImageUtils.h"

@interface SketchEffect : Effect
{
    GLuint paperTexture;
}

@end


@implementation SketchEffect

- (id) initWithVertexShaderPath: (NSString*) vertexShaderPath
			 fragmentShaderPath: (NSString*) fragmentShaderPath
{
	if(self = [super initWithVertexShaderPath: vertexShaderPath fragmentShaderPath: fragmentShaderPath])
	{        
        GLCHECK(glGenTextures(1, &paperTexture));
		GLCHECK(glBindTexture(GL_TEXTURE_2D, paperTexture));
        
		UIImage* image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"paper" ofType: @"jpg"]];
        int width, height;
        void* pixels = decodeImage(image, &width, &height);
        
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
	
	GLCHECK(glActiveTexture(GL_TEXTURE1));
	GLCHECK(glBindTexture(GL_TEXTURE_2D, paperTexture));
	GLCHECK(glActiveTexture(GL_TEXTURE0));
}

/*
- (EffectVariable*) effectVariableAtIndex: (NSInteger) index
{
    if(index == 0)
    {
        return [[[EffectVariable alloc] initWithMinValue: 0.2f maxValue: 0.8f defaultValue: 0.5f] autorelease];
    }
    else
    {
        return nil;
    }
}

- (void) effectVariableAtIndex: (NSInteger) index
                didChangeValue: (float) newValue
{
    intensity = newValue;
}*/

@end