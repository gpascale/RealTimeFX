//
//  Effect.h
//  RealTimeFx
//
//  Created by Greg on 6/30/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EffectVariable : NSObject
{
@private
    float minValue;
    float maxValue;
    float defaultValue;
    BOOL continuous;
}

@property(nonatomic, readonly) float minValue;
@property(nonatomic, readonly) float maxValue;
@property(nonatomic, readonly) float defaultValue;
@property(nonatomic, readonly) BOOL continuous;

- (id) initWithMinValue: (float) minValue
               maxValue: (float) maxValue
           defaultValue: (float) defaultValue;

- (id) initWithMinValue: (float) minValue
               maxValue: (float) maxValue
           defaultValue: (float) defaultValue
             continuous: (BOOL) continuous; 

@end;

@interface Effect : NSObject
{
	unsigned int vertexShader;
	unsigned int fragmentShader;
	unsigned int shaderProgram;
}

@property(nonatomic) unsigned int shaderProgram;

- (id) initWithVertexShaderPath: (NSString*) vertexShaderPath
			 fragmentShaderPath: (NSString*) fragmentShaderPath;

- (void) activate;

- (void) willRenderFrame;

- (UIView*) loadControlView;
- (void) dismissControlView; 

- (EffectVariable*) effectVariableAtIndex: (NSInteger) index;

- (void) effectVariableAtIndex: (NSInteger) index
                didChangeValue: (float) newValue;

@end