#import <Foundation/Foundation.h>
#import <AppKit/NSImage.h>

static NSString* heatmapImageName = @"heatmap.png";
static NSString* posterizeImageName = @"posterize.png";
static NSString* popArtImageName = @"popArt.png";
static NSString* sketchImageName = @"sketch.png";

void saveImage(CGImageRef image, NSString* filename)
{
    NSBitmapImageRep* rep = [[NSBitmapImageRep alloc] initWithCGImage: image];
    assert([rep isKindOfClass: [NSBitmapImageRep class]]);
	NSData* imageBits = [rep representationUsingType: NSPNGFileType
                                          properties: nil];
    [imageBits writeToFile: [@"../../output" stringByAppendingPathComponent: filename]
                atomically: NO];
}

typedef struct color_t
{
    unsigned char r, g, b, a;
} color;

CGImageRef createHeatmapImage()
{
    #define NUM_GRADIENT_STOPS 6
    
    color gradientStops[NUM_GRADIENT_STOPS] = 
    {
        { 255, 0, 255, 255 },
        { 0, 0, 255, 255 },
        { 0, 255, 255, 255 },
        { 0, 255, 0, 255 },
        { 255, 255, 0, 255 },
        { 255, 0, 0, 255 },
    };
    
    color data[256];
    memset(data, 0x00, sizeof(data));
    
    for(int i = 0; i < 256; ++i)
    {
        float cur = (float) i / 256 * (NUM_GRADIENT_STOPS - 1);
        
        color color1 = gradientStops[(int) floor(cur)];
        color color2 = gradientStops[(int) floor(cur) + 1];
        
        float weight = fmodf(cur, 1.0f);        
        
        data[i].r = (unsigned char) ((1.0f - weight) * color1.r) + (weight * color2.r);
        data[i].g = (unsigned char) ((1.0f - weight) * color1.g) + (weight * color2.g);
        data[i].b = (unsigned char) ((1.0f - weight) * color1.b) + (weight * color2.b);
        data[i].a = 255;        
    }
    
    #undef NUM_GRADIENT_STOPS
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(data, 256, 1, 8, 4*256, colorSpace, kCGImageAlphaNoneSkipLast);
    CFRelease(colorSpace);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    
    return cgImage;
}

CGImageRef createPosterizeImage()
{
    color data[256];
    memset(data, 0x00, sizeof(data));
    
    for(int i = 0; i < 256; ++i)
    {
        data[i].r = data[i].g = data[i].b = 255 * ((1 + (i / 86)) / 3.0f);
        data[i].a = 255;
        printf("color = %d\n", data[i].r);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(data, 256, 1, 8, 4*256, colorSpace, kCGImageAlphaNoneSkipLast);
    CFRelease(colorSpace);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    
    return cgImage;
}

#define PALETTE_SIZE 17

color palette[PALETTE_SIZE] = 
{
    {0, 0, 0},       // Black    
    {128, 0, 0},     // Dark Red
    {0, 128, 0},     // Dark Green
    {0, 0, 128},     // Dark Blue
    {128, 128, 0},   // Dark Yellow
    {128, 0, 128},   // Violet
    {0, 128, 128},   // Teal
    {128, 128, 128}, // Gray (50%)
    {192, 192, 192}, // Gray (25%)
    {255, 0, 0},     // Red
    {0, 255, 0},     // Green
    {0, 0, 255},     // Blue
    {255, 255, 0},   // Yellow
    {255, 0, 255},   // Pink
    {0, 255, 255},   // Turquoise
    {100, 85, 73},   // Tan
    {255, 255, 255}  // White
};

float colorDistance(const color* c1, const color* c2)
{
#define SQR(a) ((a)*(a))
    return SQR((float) c2->r - c1->r) +
           SQR((float) c2->g - c1->g) +
           SQR((float) c2->b - c1->b);
#undef SQR
}

color nearestColor(const color* c)
{
    float minDist = 99999999.0f;
    int bestColor = -1;
    for(int i = 0; i < PALETTE_SIZE; ++i)
    {
        const float dist = colorDistance(c, &(palette[i]));
        if(dist < minDist)
        {
            minDist = dist;
            bestColor = i;
        }
    }
    
    assert (bestColor >= 0 && bestColor < PALETTE_SIZE);
    return palette[bestColor];
}

NSData* createPosterizeLUT()
{
    #define R_QUANTSIZE 32
    #define G_QUANTSIZE 32
    #define B_QUANTSIZE 32
    
    color data[R_QUANTSIZE][G_QUANTSIZE][B_QUANTSIZE];
    memset(data, 0x00, sizeof(data));
    
    for(int i = 0; i < R_QUANTSIZE; ++i)    
    {
        int r = (float) 256 / R_QUANTSIZE * i;
        for(int j = 0; j < G_QUANTSIZE; ++j)
        {
            int g = (float) 256 / G_QUANTSIZE * j;
            for(int k = 0; k < B_QUANTSIZE; ++k)
            {
                int b = (float) 256 / B_QUANTSIZE * k;
                color curColor;
                curColor.r = r;
                curColor.g = g;
                curColor.b = b;
                curColor.a = 255;
                color nearest = nearestColor(&curColor);
                memcpy(&(data[i][j][k]), &nearest, sizeof(color));
            }
        }        
    }
    
    NSData* ret = [[NSData alloc] initWithBytes: data length: sizeof(data)];
    
    return ret;
    
    #undef R_QUANTSIZE
    #undef G_QUANTSIZE
    #undef B_QUANTSIZE
}

CGImageRef createPopArtImage()
{
    color data[256];
    memset(data, 0x00, sizeof(data));
    
    color colors[4] = 
    {                
        {255, 0, 0, 255},
        {255, 255, 155, 255},
        {225, 0, 125, 255},
        {255, 255, 20, 255},
    };
    
    for(int i = 0; i < 256; ++i)
    {
        data[i] = colors[i / 64];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(data, 256, 1, 8, 4*256, colorSpace, kCGImageAlphaNoneSkipLast);
    CFRelease(colorSpace);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    
    return cgImage;
}

NSData* createBloomLUT()
{
    float data[256];
    memset(data, 0x00, sizeof(data));    
    
    for(int i = 0; i < 0.3 * 256; ++i)
    {
        data[i] = 0.032f;
    }
    for(int i = 0.3 * 256; i < 0.7 * 256; ++i)
    {
        data[i] = 0.007f;
    }
    for(int i = 0.7 * 256; i < 256; ++i)
    {
        data[i] = 0.004f;
    }
    
    return [NSData dataWithBytes: data length: sizeof(data)];
}

CGImageRef createSketchImage()
{
    color data[256];
    memset(data, 0x00, sizeof(data));
    
    static const int numLevels = 8;
    const int pixelsPerLevel = 256 / numLevels;
    
    for(int i = 0; i < 256; ++i)
    {
        const int level = i / pixelsPerLevel;
        data[i].r = data[i].g = data[i].b = (float) level / (numLevels - 1) * 255;
        data[i].a = 255;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(data, 256, 1, 8, 4*256, colorSpace, kCGImageAlphaNoneSkipLast);
    CFRelease(colorSpace);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    
    return cgImage;
}

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        
    CGImageRef heatmapImage = createHeatmapImage();
    saveImage(heatmapImage, heatmapImageName);
    CGImageRelease(heatmapImage);
    
    CGImageRef popArtImage = createPopArtImage();
    saveImage(popArtImage, popArtImageName);
    CGImageRelease(popArtImage);
        
    CGImageRef sketchImage = createSketchImage();
    saveImage(sketchImage, sketchImageName);
    CGImageRelease(sketchImage);
    
    NSData* bloomLUT = createBloomLUT();
    [bloomLUT writeToFile: @"../../output/bloom.lut" atomically: NO];
    
    /*
    CGImageRef posterizeImage = createPosterizeImage2();
    saveImage(posterizeImage, posterizeImageName);
    CGImageRelease(posterizeImage);
     */
    
    NSData* posterizeLUT = createPosterizeLUT();
    [posterizeLUT writeToFile: @"../../output/posterize.lut" atomically: NO];
    [posterizeLUT release];
    
    [pool drain];
    return 0;
}
