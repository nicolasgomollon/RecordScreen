//
//  RecordViewController.h
//  RecordScreen
//
//  Created by Nicolas Gomollon on 1/4/13.
//  Copyright (c) 2013 Techno-Magic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

void CARenderServerRenderDisplay(kern_return_t a, CFStringRef b, IOSurfaceRef surface, int x, int y);

@interface RecordViewController : UIViewController <AVAudioRecorderDelegate> {
	UIButton *recordButton;
	MTStatusBarOverlay *statusBarOverlay;
	
	BOOL isRecording;
	NSTimer *recordingTimer;
	NSDate *recordStartDate;
	AVAudioRecorder *audioRecorder;
	
	IOSurfaceRef surface;
	int bytesPerRow;
	int width;
	int height;
	
	dispatch_queue_t video_queue;
	int kbps;
	int fps;
	NSLock *pixelBufferLock;
	AVAssetWriter *videoWriter;
	AVAssetWriterInput *videoWriterInput;
	AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor;
	
	NSString *screenRecordingName;
}

@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) MTStatusBarOverlay *statusBarOverlay;

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong) NSTimer *recordingTimer;
@property (nonatomic, strong) NSDate *recordStartDate;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

@property (nonatomic, assign) IOSurfaceRef surface;
@property (nonatomic, assign) int bytesPerRow;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;

@property (nonatomic, assign) dispatch_queue_t video_queue;
@property (nonatomic, assign) int kbps;
@property (nonatomic, assign) int fps;
@property (nonatomic, strong) NSLock *pixelBufferLock;
@property (nonatomic, strong) AVAssetWriter *videoWriter;
@property (nonatomic, strong) AVAssetWriterInput *videoWriterInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor;

@property (nonatomic, strong) NSString *screenRecordingName;

@end
