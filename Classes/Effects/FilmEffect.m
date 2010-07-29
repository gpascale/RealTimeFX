//
//  FilmEffect.m
//  RealTimeFx
//
//  Created by Greg on 7/3/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "FilmEffect.h"
#import "ImageUtils.h"

@implementation FilmEffect

- (id) initWithVertexShaderPath: (NSString*) vertexShaderPath
			 fragmentShaderPath: (NSString*) fragmentShaderPath
{
	if(self = [super initWithVertexShaderPath: vertexShaderPath fragmentShaderPath: fragmentShaderPath])
	{        
        GLCHECK(glGenTextures(1, &filmGrainTexture));
		GLCHECK(glBindTexture(GL_TEXTURE_2D, filmGrainTexture));
        
		UIImage* image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"filmgrain" ofType: @"jpg"]];
        int width, height;
        void* pixels = decodeImage(image, &width, &height);
        
		GLCHECK(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels));
        
		GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR));
		GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR));
		GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT));
		GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT));
		GLCHECK(glBindTexture(GL_TEXTURE_2D, 0));
        
        //GLCHECK(glBindAttribLocation(self.shaderProgram, ATTRIB_SPECIAL0, @"a_filmTexCoords")
        GLCHECK(u_rotationAmt = glGetUniformLocation(self.shaderProgram, "u_rotationAmt"));
        GLCHECK(u_intensity = glGetUniformLocation(self.shaderProgram, "u_intensity"));
        assert(u_rotationAmt >= 0);
        assert(u_intensity >= 0);
        
        free(pixels);
	}
	
	return self;
}

- (void) activate
{
	[super activate];
	
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, filmGrainTexture);
	glActiveTexture(GL_TEXTURE0);
    
    intensity = 0.5;
}

static int counter = 0;

- (void) willRenderFrame
{
    if(counter % 3 == 0)
    {
        glUniform1f(u_rotationAmt, (rand() % 16) * (M_PI / 8.0f));
    }
    counter = (counter + 1) % 3;
    
    glUniform1f(u_intensity, intensity);
}

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
}

@end