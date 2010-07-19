//
//  EffectDescription.m
//  RealTimeFx
//
//  Created by Greg on 7/11/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "EffectDescription.h"

@implementation EffectDescription

@synthesize vertexShaderName;
@synthesize fragmentShaderName;
@synthesize effectClass;

- (id) initWithVertexShaderName: (NSString*) vertName
             fragmentShaderName: (NSString*) fragName
                    effectClass: (Class) theClass
{
    if(self = [super init])
    {
        vertexShaderName = [vertName retain];
        fragmentShaderName = [fragName retain];
        effectClass = theClass;
    }
    
    return self;
}

- (void) dealloc
{
    [vertexShaderName release];
    [fragmentShaderName release];
    [super dealloc];
}

@end
