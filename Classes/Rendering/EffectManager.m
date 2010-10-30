//
//  EffectManager.m
//  RealTimeFx
//
//  Created by Greg on 6/27/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "EffectManager.h"
#import "Effect.h"
#import "EffectDescription.h"
#import "Shaders.h"
#import "Store.h"
#import <OpenGLES/EAGL.h>

@interface HeatmapEffect : Effect { } @end
@interface PosterizeEffect : Effect { } @end
@interface PosterizeLUTEffect : Effect { } @end
@interface FilmEffect : Effect { } @end
@interface MotionBlurEffect : Effect { } @end
@interface SqueezeEffect : Effect { } @end
@interface StretchEffect : Effect { } @end
@interface PopArtEffect : Effect { } @end
@interface BloomEffect : Effect { } @end
@interface ComicEffect : Effect { } @end
@interface SketchEffect : Effect { } @end
@interface SpectrumEffect : Effect { } @end
@interface MirrorEffect : Effect { } @end
@interface PointillismEffect : Effect { } @end

@interface EffectManager (private)

- (void) broadcastActiveEffectChanged;

@end

static NSDictionary* effectDescriptionDictionary;
static NSArray* freeEffectNames;
static NSArray* ep1EffectNames;

NSDictionary* createEffectDictionary()
{
    NSDictionary* ret = [[NSDictionary alloc] initWithObjectsAndKeys: 
          
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"basic"
                                                 effectClass: [Effect class]] autorelease],
        @"None",
                         
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"grayscale"
                                                 effectClass: [Effect class]] autorelease],
        @"Black and White",
        
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"invert"
                                                 effectClass: [Effect class]] autorelease],
        @"Negative",
        
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"sepia"
                                                 effectClass: [Effect class]] autorelease],
        @"Sepia",
        
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"edge"
                                                 effectClass: [Effect class]] autorelease],
        @"Edge",
        
        // Glow effect
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"bloom"
                                                 effectClass: [BloomEffect class]] autorelease],
        @"Glow",
        
        // Heat Sensor effect
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"heatmap"
                                                 effectClass: [HeatmapEffect class]] autorelease],
        @"Heat Sensor",
        
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"posterize"
                                                 effectClass: [PosterizeEffect class]] autorelease],
        @"Posterize",
        
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"film"
                                                 effectClass: [FilmEffect class]] autorelease],
        @"Film",
                                       
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"motionblur"
                                                 effectClass: [MotionBlurEffect class]] autorelease],
        @"Motion Blur",
                                       
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"squeeze"
                                                 effectClass: [SqueezeEffect class]] autorelease],
        @"Squeeze",
                                       
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"squeeze"
                                                 effectClass: [StretchEffect class]] autorelease],
        @"Stretch",
                         
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"emboss"
                                                 effectClass: [Effect class]] autorelease],
        @"Emboss",
        
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"cartoon"
                                                 effectClass: [Effect class]] autorelease],
        @"Cartoon",
                         
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"comic"
                                                 effectClass: [ComicEffect class]] autorelease],
        @"Newspaper",

        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"sketch"
                                                 effectClass: [SketchEffect class]] autorelease],
        @"Sketch",
                         
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"spectrum"
                                                 effectClass: [SpectrumEffect class]] autorelease],
        @"Spectrum",
                         
        [[[EffectDescription alloc] initWithVertexShaderName: @"basic"
                                          fragmentShaderName: @"mirror"
                                                 effectClass: [MirrorEffect class]] autorelease],
        @"Mirror",

        /*[[[EffectDescription alloc] initWithVertexShaderName:@"basic"
                                          fragmentShaderName:@"pointillism"
                                                 effectClass:[PointillismEffect class]] autorelease],
        @"Pointillism",*/
        
        (id)nil
    ];
    
    return ret;
}

static NSArray* createFreeEffectNames()
{
    NSArray* ret = [[NSArray alloc] initWithObjects:
                           @"Sepia",
                           @"Negative",
                           @"Edge",
                           @"Posterize",
                           @"Squeeze",
                           @"Mirror",
                           @"Cartoon",
                           @"None",
                           nil];
    return ret;
}

NSArray* createEP1EffectNames()
{
    NSArray* ret = [[NSArray alloc] initWithObjects:
                           @"Sepia", @"Black and White", @"Negative",
                           @"Edge", @"Posterize", @"Heat Sensor",
                           @"Glow", @"Film", @"Motion Blur",
                           @"Squeeze", @"Stretch", @"Mirror", @"Cartoon",
                           @"Emboss", @"Newspaper", @"Sketch", @"Spectrum", @"None",
                           (id) nil];
    return ret;
}

@implementation EffectManager

@synthesize effectNames;
@synthesize activeEffect;
@synthesize activeEffectName;

+ (void) initialize
{
    effectDescriptionDictionary = createEffectDictionary();
    freeEffectNames = createFreeEffectNames();
    ep1EffectNames = createEP1EffectNames();
}

- (id) initWithContext: (EAGLContext*) context;
{
	if(!(self = [super init]))
	{
		return nil;
	}    
	
	@try
	{
		[EAGLContext setCurrentContext: context];	        
        
        effectNames = [Store hasEffectPackOne] ? ep1EffectNames : freeEffectNames;
        
        NSMutableArray* mutableEffects = [[[NSMutableArray alloc] init] autorelease];
        for(NSString* effectName in effectNames)
        {
            EffectDescription* desc = [effectDescriptionDictionary objectForKey: effectName];
            NSAssert(desc, @"");
            NSString* vertexShaderPath = [[NSBundle mainBundle] pathForResource: desc.vertexShaderName ofType: @"vsh"];
            NSString* fragmentShaderPath = [[NSBundle mainBundle] pathForResource: desc.fragmentShaderName ofType: @"fsh"];
            [mutableEffects addObject: [[[desc.effectClass alloc] initWithVertexShaderPath: vertexShaderPath
                                                                  fragmentShaderPath: fragmentShaderPath] autorelease]];
        }

        effects = [[NSArray alloc] initWithArray: mutableEffects];                             

        // Attempt to read the last active effect from disk - default to grayscale.
        NSString* lastActiveEffectName = [[NSUserDefaults standardUserDefaults] stringForKey: @"LastActiveEffectName"];
        if(lastActiveEffectName)
        {
            activeEffectName = lastActiveEffectName;
            activeEffect = [effects objectAtIndex: [effectNames indexOfObject: activeEffectName]];
        }
        else
        {
            activeEffect = [effects objectAtIndex: 0];
            activeEffectName = [effectNames objectAtIndex: 0];
        }
        
        [self broadcastActiveEffectChanged];
	}
	@catch(NSException* exc)
	{
		self = nil;
	}

	return self;
}

- (void) activateEffectWithName: (NSString*) effectName
{
	const int index = [effectNames indexOfObject: effectName];
	activeEffect = [effects objectAtIndex: index];
    activeEffectName = [effectNames objectAtIndex: index];
    [activeEffect activate];
    [self broadcastActiveEffectChanged];
}

- (void) activateNextEffect
{
    const int newIndex = ([effects indexOfObject: activeEffect] + 1) % [effects count];
    activeEffect = [effects objectAtIndex: newIndex];
    activeEffectName = [effectNames objectAtIndex: newIndex];
    [activeEffect activate];
    [self broadcastActiveEffectChanged];    
}

- (void) activatePreviousEffect
{
    const int newIndex = ([effects indexOfObject: activeEffect] - 1 + [effects count]) % [effects count];
    activeEffect = [effects objectAtIndex: newIndex];
    activeEffectName = [effectNames objectAtIndex: newIndex];
    [activeEffect activate];
    [self broadcastActiveEffectChanged];
}

- (void) broadcastActiveEffectChanged
{
    // Write the last active effect to user defaults so we can start with it next time.
    // This should be somewhere better.
    [[NSUserDefaults standardUserDefaults] setObject: activeEffectName forKey: @"LastActiveEffectName"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"ActiveEffectDidChange"
                                                        object: self];
}

- (void) dealloc
{    
    [effects release];
    [effectNames release];
    [activeEffect release];
    [super dealloc];
}

@end
