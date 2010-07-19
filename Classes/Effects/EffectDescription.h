//
//  EffectDescription.h
//  RealTimeFx
//
//  Created by Greg on 7/11/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EffectDescription : NSObject
{
    NSString* vertexShaderName;
    NSString* fragmentShaderName;
    Class effectClass;
}

@property (nonatomic, readonly) NSString* vertexShaderName;
@property (nonatomic, readonly) NSString* fragmentShaderName;
@property (nonatomic, readonly) Class effectClass;

- (id) initWithVertexShaderName: (NSString*) vertName
             fragmentShaderName: (NSString*) fragName
                    effectClass: (Class) theClass;

@end
