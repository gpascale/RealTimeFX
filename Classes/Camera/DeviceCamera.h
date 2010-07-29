//
//  DeviceCamera.h
//  RealTimeFx
//
//  Created by Greg on 6/27/10.
//  Copyright 2010 Brown University. All rights reserved.
//

#import "Camera.h"
#import "GLUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@class EAGLContext;
@class AVCaptureSession;
@class AVCaptureStillImageOutput;

@interface DeviceCamera : NSObject <Camera,
                                    AVCaptureVideoDataOutputSampleBufferDelegate,
                                    AVCaptureFileOutputRecordingDelegate>
{
	// Graphics
	GLuint m_texture;	
	CGSize textureSize;
	CGSize imageSize;
	EAGLContext* context;
	
	// Camera
	AVCaptureSession* avSession;
	CMTime previousTimestamp;	
	Float64 videoFrameRate;
	CMVideoDimensions videoDimensions;
	CMVideoCodecType videoType;
    
    // Inputs
    AVCaptureDevice* backCamera;
    AVCaptureDevice* frontCamera;
    AVCaptureDevice* activeCamera;
    AVCaptureDeviceInput* activeVideoInput;
    
    // Still-image output for taking pictures
    AVCaptureStillImageOutput* stillImageOutput;
    
    AVCaptureFileOutput* fileOutput;
	
	GLuint m_displacementTexture;
    
    BOOL isRecording;    
}

- (BOOL) hasFrontCamera;

- (void) toggleCameras;

- (void) activateCameraWithPosition: (AVCaptureDevicePosition) position;

// AVCaptureVideoDataOutputSampleBufferDelegate methods
- (void) captureOutput: (AVCaptureOutput*) captureOutput
 didOutputSampleBuffer: (CMSampleBufferRef) sampleBuffer
	    fromConnection: (AVCaptureConnection*) connection;

- (void) captureOutput: (AVCaptureFileOutput*) captureOutput
didStartRecordingToOutputFileAtURL: (NSURL*) fileURL
       fromConnections: (NSArray*) connections;

- (void) captureOutput: (AVCaptureFileOutput*) captureOutput
didFinishRecordingToOutputFileAtURL: (NSURL*) fileURL
       fromConnections: (NSArray*) connections
error: (NSError*) error;

- (void) takePicture;

- (GLuint) getTexture;
- (GLuint) getDisplacementTexture;

// Video properties
@property (readwrite) Float64 videoFrameRate;
@property (readwrite) CMVideoDimensions videoDimensions;
@property (readwrite) CMVideoCodecType videoType;
@property (readwrite) CMTime previousTimestamp;
@property (nonatomic, retain) AVCaptureDeviceInput* videoInput;

@property (nonatomic) CGSize textureSize;
@property (nonatomic) CGSize imageSize;

@end
