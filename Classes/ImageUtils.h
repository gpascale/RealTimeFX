/*
 *  ImageUtils.h
 *  RealTimeFx
 *
 *  Created by Greg on 6/27/10.
 *  Copyright 2010 Brown University. All rights reserved.
 *
 */

@class UIImage;

extern void* decodeImage(UIImage* imageToDecode,
						 int* widthOut,
						 int* heightOut);
						 
extern void* decodeImageToPow2Buffer(UIImage* imageToDecode,
								     int* widthOut,
									 int* heightOut,
									 int* bufferWidthOut,
									 int* bufferHeightOut);
