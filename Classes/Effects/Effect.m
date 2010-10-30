//
//  Effect.m
//  RealTimeFx
//
//  Created by Greg on 6/30/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "Effect.h"
#import "Shaders.h"
#import "GLUtils.h"

@implementation EffectVariable

@synthesize minValue;
@synthesize maxValue;
@synthesize defaultValue;
@synthesize continuous;

- (id) initWithMinValue: (float) minVal
               maxValue: (float) maxVal
           defaultValue: (float) defaultVal
{
    if(self = [super init])
    {
        minValue = minVal;
        maxValue = maxVal;
        defaultValue = defaultVal;
        continuous = YES;
    }
    
    return self;
}

- (id) initWithMinValue: (float) minVal
               maxValue: (float) maxVal
           defaultValue: (float) defaultVal
             continuous: (BOOL) cont
{
    if(self = [super init])
    {
        minValue = minVal;
        maxValue = maxVal;
        defaultValue = defaultVal;
        continuous = cont;
    }
    
    return self;
}

@end

@implementation Effect

@synthesize shaderProgram;

- (id) initWithVertexShaderPath: (NSString*) vertexShaderPath
			 fragmentShaderPath: (NSString*) fragmentShaderPath
{
	if(self = [super init])
	{
		if (!compileShader(&vertexShader, GL_VERTEX_SHADER, 1, vertexShaderPath))
		{
			return nil;
		}
		if (!compileShader(&fragmentShader, GL_FRAGMENT_SHADER, 1, fragmentShaderPath))
		{
			return nil;
		}
				
		GLCHECK(shaderProgram = glCreateProgram());
		
		// Bind common attributes so they can be easily set from outside the shader
		GLCHECK(glBindAttribLocation(shaderProgram, ATTRIB_POSITION, "a_position"));
		GLCHECK(glBindAttribLocation(shaderProgram, ATTRIB_TEXCOORDS, "a_texCoords"));
		
		GLCHECK(glAttachShader(shaderProgram, vertexShader));	
		GLCHECK(glAttachShader(shaderProgram, fragmentShader));
		
		if(!linkProgram(shaderProgram))
		{
			return nil;
		}
	}
	
	return self;
}

- (void) activate
{        
    // Activate the program
	(validateProgram(shaderProgram));
	GLCHECK(glUseProgram(shaderProgram));        
    
    // Set default GL state
    GLCHECK(glDisable(GL_BLEND));
    GLCHECK(glDisable(GL_DEPTH_TEST));
}

- (void) willRenderFrame
{
    
}

- (UIView*) loadControlView
{
    return nil;
}

- (void) dismissControlView
{
    
}

- (EffectVariable*) effectVariableAtIndex: (NSInteger) index
{
    return nil;
}

- (void) effectVariableAtIndex: (NSInteger) index
                didChangeValue: (float) newValue
{
    // no-op by default
}

@end
