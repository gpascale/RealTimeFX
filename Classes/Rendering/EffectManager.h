//
//  EffectManager.h
//  RealTimeFx
//
//  Created by Greg on 6/27/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLUtils.h"

@class Effect;
@class EAGLContext;

@interface EffectManager : NSObject
{
    NSArray* effects;
    NSArray* effectNames;
    
	Effect* activeEffect;
    NSString* activeEffectName;
}

@property (nonatomic, readonly) NSArray* effectNames;
@property (nonatomic, readonly) Effect* activeEffect;
@property (nonatomic, readonly) NSString* activeEffectName;

- (id) initWithContext: (EAGLContext*) context;

- (void) activateEffectWithName: (NSString*) effectName;
- (void) activatePreviousEffect;
- (void) activateNextEffect;

@end
