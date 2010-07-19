//
//  DeviceCamera.m
//  RealTimeFx
//
//  Created by Greg on 6/27/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#if !TARGET_IPHONE_SIMULATOR

#import "DeviceCamera.h"
#import "ImageUtils.h"
#import <OpenGLES/EAGL.h>
#import <math.h>

@interface DeviceCamera (private)

- (BOOL) configureAVSession;
- (void) createTexture;

@end

@implementation DeviceCamera

@synthesize imageSize;
@synthesize textureSize;
@synthesize videoFrameRate;
@synthesize videoDimensions;
@synthesize videoType;
@synthesize previousTimestamp;

#undef MAX
#undef MIN
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define MIN(a, b) ((a) < (b) ? (a) : (b))

- (id) init
{
	if ((self = [super init]))
	{
		// Setup our Capture Session.
		avSession = [[AVCaptureSession alloc] init];
		if(![self configureAVSession])
		{
			return nil;
		}		
		
		[avSession startRunning];
	}
	return self;
}

- (GLuint) getTexture
{
	return m_texture;
}

- (GLuint) getDisplacementTexture
{
	return m_displacementTexture;
}

- (BOOL) isCapturing
{
    return [avSession isRunning];
}

- (void) startCapturing
{
    [avSession startRunning];
}

- (void) stopCapturing
{
    [avSession stopRunning];
}

- (void) captureOutput: (AVCaptureOutput*) captureOutput
 didOutputSampleBuffer: (CMSampleBufferRef) sampleBuffer
	    fromConnection: (AVCaptureConnection*) connection
{
    NSDate* processBegin = [NSDate date];
    
	CMTime timestamp = CMSampleBufferGetPresentationTimeStamp( sampleBuffer );
	if (CMTIME_IS_VALID( self.previousTimestamp ))
		self.videoFrameRate = 1.0 / CMTimeGetSeconds( CMTimeSubtract( timestamp, self.previousTimestamp ) );
	
	previousTimestamp = timestamp;

	CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
	self.videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDesc);
	
	// Create a texture if its size does not match the video's size
	if(textureSize.width != self.videoDimensions.width || textureSize.height != self.videoDimensions.height)
	{
		[self createTexture];
		return;
	}
	
	CMVideoCodecType type = CMFormatDescriptionGetMediaSubType(formatDesc);
#if defined(__LITTLE_ENDIAN__)
	type = OSSwapInt32(type);
#endif
	self.videoType = type;
	
	CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CVPixelBufferLockBaseAddress( pixelBuffer, 0 );		
	glBindTexture(GL_TEXTURE_2D, m_texture);
	    
	unsigned char* linebase = (unsigned char *)CVPixelBufferGetBaseAddress( pixelBuffer );    
    
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, videoDimensions.width, videoDimensions.height, GL_BGRA_EXT, GL_UNSIGNED_BYTE, linebase);	    
    
	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"ProcessedVideoFrame" object: [[NSDate date] retain]];
    
    NSLog(@"Processed Frame in %f seconds", [[NSDate date] timeIntervalSinceDate: processBegin]);

}

- (BOOL) configureAVSession
{
	[avSession beginConfiguration];
		
	//-- Set a preset session size. 
	[avSession setSessionPreset: AVCaptureSessionPresetMedium];
	
	//-- Creata a video device and input from that Device.  Add the input to the capture session.
	AVCaptureDevice* videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if(videoDevice == nil)
	{
		return NO;
	}	
	//-- Add the device to the session.
	NSError* error;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
	if(error)
	{
		return NO;
	}	
	[avSession addInput:input];
	
    // Create a still-image output so we can take pictures
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [avSession addOutput: stillImageOutput];
    
	//-- Create the output for the capture session.  We want 32bit BRGA
	AVCaptureVideoDataOutput* dataOutput = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    // Probably want to set this to NO when we're recording
	[dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    // Necessary for manual preview
	[dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                             forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
	// we want our dispatch to be on the main thread so OpenGL can do things with the data
	[dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];	
	[avSession addOutput:dataOutput];
    
    /*
    //-- Create the recording output
    fileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if([avSession canAddOutput: fileOutput])
    {
        [avSession addOutput: fileOutput];
    }*/
    
    // Gregsperimentation
    /*
    [videoDevice lockForConfiguration: &error];
    // turn off auto white balance    
    videoDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeLocked;
    // turn off auto focus
    videoDevice.focusMode = AVCaptureFocusModeLocked;
    // turn off auto exposure adjustment
    videoDevice.exposureMode = AVCaptureExposureModeLocked;
    [videoDevice unlockForConfiguration];
    */
    dataOutput.minFrameDuration = CMTimeMake(1, 24);
    
	[avSession commitConfiguration];
	
	return YES;
}

- (void) createTexture
{
	GLCHECK(glGenTextures(1, &m_texture));
	GLCHECK(glBindTexture(GL_TEXTURE_2D, m_texture));		
 
	GLCHECK(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.videoDimensions.width, self.videoDimensions.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL));
	
	GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR));
	GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR));
	GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE));
	GLCHECK(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE));
	GLCHECK(glBindTexture(GL_TEXTURE_2D, 0));
	
	imageSize = CGSizeMake(self.videoDimensions.width, self.videoDimensions.height);
	textureSize = CGSizeMake(self.videoDimensions.width, self.videoDimensions.height);
	
	/*
	#define BLOCK_SIZE 8	
	
	unsigned char* data = malloc(4 * self.videoDimensions.height * self.videoDimensions.width);
	memset(data, 0, 4 * self.videoDimensions.height * self.videoDimensions.width);
	const int rowBytes = 4 * self.videoDimensions.width;
	for(int i = 0; i < self.videoDimensions.height; ++i)
	{
		for(int j = 0; j < self.videoDimensions.width; ++j)
		{			
			data[i * rowBytes + 4 * j + 0] = 255 * ((float) (BLOCK_SIZE*(j/BLOCK_SIZE)) / self.videoDimensions.width);
			data[i * rowBytes + 4 * j + 1] = 255 * ((float) (BLOCK_SIZE*(i/BLOCK_SIZE)) / self.videoDimensions.height);
			data[i * rowBytes + 4 * j + 3] = 255 * ((float) j / self.videoDimensions.width);
		}
	}

	#undef BLOCK_SIZE
	
	#define RADIUS 5
     
	unsigned char* data = malloc(4 * self.videoDimensions.height * self.videoDimensions.width);
	memset(data, 0, 4 * self.videoDimensions.height * self.videoDimensions.width);
	const int rowBytes = 4 * self.videoDimensions.width;
	for(int i = 0; i < self.videoDimensions.height; i += 7)
	{
		for(int j = 0; j < self.videoDimensions.width; j += 7)
		{
			int centerR = i + (rand() % 10) - 5;
			int centerC = j + (rand() % 10) - 5;
			for(int ii = MAX(0, centerR - RADIUS); ii < MIN(self.videoDimensions.height, centerR + RADIUS); ++ii)
			{
				for(int jj = MAX(0, centerC - RADIUS); jj < MIN(self.videoDimensions.width, centerC + RADIUS); ++jj)
				{					
					double distSq = (ii - centerR) * (ii - centerR) + (jj - centerC) * (jj - centerC);
					if(distSq < RADIUS * RADIUS)
					{
						data[ii * rowBytes + 4 * jj + 0] = 255 * ((double)centerC / self.videoDimensions.width);
						data[ii * rowBytes + 4 * jj + 1] = 255 * ((double)centerR / self.videoDimensions.height);
					}
				}
			}
		}
	}
	
	#undef RADIUS
	
     */

}

- (void) captureOutput: (AVCaptureFileOutput*) captureOutput
didStartRecordingToOutputFileAtURL: (NSURL*) fileURL
       fromConnections: (NSArray*) connections
{
    printf("Started recording\n");
}

- (void) captureOutput: (AVCaptureFileOutput*) captureOutput
didFinishRecordingToOutputFileAtURL: (NSURL*) fileURL
     fromConnections: (NSArray*) connections
error: (NSError*) error
{
    printf("Finished recording\n");
    NSLog(@"%@", [error localizedDescription]);
}
     
@end

#endif