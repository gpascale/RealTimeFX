//
//  PointillismEffect.m
//  RealTimeFx
//
//  Created by Greg on 8/22/10.
//  Copyright 2010 Brown University. All rights reserved.
//


#import "Effect.h"
#import "GLUtils.h"
#import "ImageUtils.h"
#include <vector>
#include <algorithm>
using namespace std;

#define MMIN(a, b) (((a) < (b)) ? (a) : (b))
#define MMAX(a, b) (((a) > (b)) ? (a) : (b))

@interface PointillismEffect : Effect
{
    GLuint texture;
    
    int radius;
    GLint u_radius;
}

- (void) createTextureWithRadius:(NSInteger)rad;

@end


@implementation PointillismEffect

- (id) initWithVertexShaderPath: (NSString*) vertexShaderPath
			 fragmentShaderPath: (NSString*) fragmentShaderPath
{
	if(self = [super initWithVertexShaderPath: vertexShaderPath fragmentShaderPath: fragmentShaderPath])
	{        
        GLCHECK(glGenTextures(1, &texture));
		GLCHECK(glBindTexture(GL_TEXTURE_2D, texture));
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
    [self createTextureWithRadius:3.0f];
}


- (EffectVariable*) effectVariableAtIndex: (NSInteger) index
{
    if(index == 0)
    {
        return [[[EffectVariable alloc] initWithMinValue:1.0f
                                                maxValue:18.0f
                                            defaultValue:3.0f
                                              continuous:NO] autorelease];
    }  
    
    return nil;
}

- (void) willRenderFrame
{
    GLCHECK(glClearColor(0.0f, 0.0f, 0.0f, 1.0f));
    GLCHECK(glClear(GL_COLOR_BUFFER_BIT));
    GLCHECK(glEnable(GL_BLEND));
    GLCHECK(glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA));
}
 
- (void) effectVariableAtIndex: (NSInteger) index
                didChangeValue: (float) newValue
{
    const int newRadius = (int) (newValue + 0.5f);
    
    if(newRadius != radius)
    {
        [self createTextureWithRadius:newRadius];
    }
}

typedef struct bytevec4_t
{
    unsigned char r,g,b,a;
} bytevec4;

- (void) createTextureWithRadius:(NSInteger)rad
{
    const int width = 480;
    const int height = 320; 
    
    bytevec4 data[height][width];
    memset(data, 0x00, sizeof(data));
   
    const int step = 0.85 * (2 * rad + 1);
    const int radiusSq = rad * rad;

    // Randomly sort point order
    vector<pair<int, int> > pointLocations;
    
    for(int cy = 0; cy < height + step; cy += step)
    {
        for(int cx = 0; cx < width + step; cx += step)
        {
            int R = rad % 2 == 0 ? rad : rad + 1;
            int rx = rand() % R - (R / 2);
            int ry = rand() % R - (R / 2);            
            pointLocations.push_back(make_pair(cx + rx, cy + ry));                        
        }
    }
    
    random_shuffle(pointLocations.begin(), pointLocations.end());
    
    int cx, cy;
    for(int c = 0; c < pointLocations.size(); ++c)
    {
        cx = pointLocations[c].first;
        cy = pointLocations[c].second;
        for(int i = MMAX(cy - rad, 0); i < MMIN(cy + rad + 1, height); ++i)
        {
            for(int j = MMAX(cx - rad, 0); j < MMIN(cx + rad + 1, width); ++j)
            {
                #define SQR(a) ((a)*(a))
                const int distSq = SQR(cx - j) + SQR(cy - i);
                if(distSq <= radiusSq)
                {
                    if(data[i][j].r == 0 && data[i][j].g == 0)
                    {
                        if(distSq > 0.55f * radiusSq)
                        {
                            data[i][j].b = 255 * ((1.0f - (float)distSq/radiusSq));
                        }
                        else
                        {
                            data[i][j].b = 255;
                        }
                    }
                    else
                    {
                        data[i][j].b = 255;
                    }

                    data[i][j].r = 128 + (cx - j);
                    data[i][j].g = 128 + (cy - i);
                    //data[i][j].b = 255 * min(1.0f,max(1.0f - (float)2.0f*distSq/radiusSq, 0.5f));                    
                }

                #undef SQR
            }
        }
    }
    
    GLCHECK(glActiveTexture(GL_TEXTURE1));
	GLCHECK(glBindTexture(GL_TEXTURE_2D, texture));
    GLCHECK(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0,
                         GL_RGBA, GL_UNSIGNED_BYTE, data));
    GLCHECK(glActiveTexture(GL_TEXTURE0));
    
    radius = rad;
}

@end
