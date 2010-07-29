/*
 *  ImageUtils.m
 *  RealTimeFx
 *
 *  Created by Greg on 6/27/10.
 *  Copyright 2010 Brown University. All rights reserved.
 *
 */

#import "ImageUtils.h"

void* decodeImage(UIImage* imageToDecode,
				  int* widthOut,
				  int* heightOut)
{
	if(imageToDecode == nil)
	{
		*widthOut = 0;
		*heightOut = 0;
		return NULL;
	}

    CGImageRef cgImage = imageToDecode.CGImage;
    *widthOut = CGImageGetWidth(cgImage);
    *heightOut = CGImageGetHeight(cgImage);
    
    int bufferSize = *widthOut * *heightOut * 4 * sizeof(unsigned char);
    
    unsigned char* buffer = (unsigned char*) malloc(bufferSize);
    memset(buffer, 0x00, bufferSize * sizeof(unsigned char));
    
    const CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef spriteContext = CGBitmapContextCreate((void*) buffer,
                                                       *widthOut,
                                                       *heightOut,
                                                       8,
                                                       *widthOut * 4 * sizeof(unsigned char),
                                                       colorSpace,            
                                                       kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, 
                       CGRectMake(0.0f, 0.0f, *widthOut, *heightOut),
                       cgImage);
    
    CGContextRelease(spriteContext);
    
    return (void*) buffer;
}

void* decodeImageToPow2Buffer(UIImage* imageToDecode,
							  int* widthOut,
							  int* heightOut,
							  int* bufferWidthOut,
							  int* bufferHeightOut)
{
	if(imageToDecode == nil)
	{
		*widthOut = 0;
		*heightOut = 0;
		return NULL;
	}

    CGImageRef cgImage = imageToDecode.CGImage;
    *widthOut = CGImageGetWidth(cgImage);
    *heightOut = CGImageGetHeight(cgImage);
        
    
    const CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
	*bufferWidthOut = 1 << (int)ceil(log2((double)*widthOut));
	*bufferHeightOut = 1 << (int)ceil(log2((double)*heightOut));
	
	int bufferSize = *bufferWidthOut * *bufferHeightOut * 4 * sizeof(unsigned char);    
    unsigned char* buffer = (unsigned char*) malloc(bufferSize);
    memset(buffer, 0x00, bufferSize * sizeof(unsigned char));
	
    CGContextRef spriteContext = CGBitmapContextCreate((void*) buffer,
                                                       *bufferWidthOut,
                                                       *bufferHeightOut,
                                                       8,
                                                       *bufferWidthOut * 4 * sizeof(unsigned char),
                                                       colorSpace,            
                                                       kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, 
                       CGRectMake(0.0f, *bufferHeightOut - *heightOut, *widthOut, *heightOut),
                       cgImage);
    
    CGContextRelease(spriteContext);
    
    return (void*) buffer;
}