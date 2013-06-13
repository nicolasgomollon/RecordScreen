//
//  RecordViewController.m
//  RecordScreen
//
//  Created by Nicolas Gomollon on 1/4/13.
//  Copyright (c) 2013 Techno-Magic. All rights reserved.
//

#import "RecordViewController.h"

@implementation RecordViewController

@synthesize recordButton, statusBarOverlay;
@synthesize isRecording, recordingTimer, recordStartDate, audioRecorder;
@synthesize surface, bytesPerRow, width, height;
@synthesize video_queue, kbps, fps, pixelBufferLock, videoWriter, videoWriterInput, pixelBufferAdaptor;
@synthesize screenRecordingName;


- (id)init {
	self = [super init];
	if (self) {
		// Custom initialization
		[self setTitle:@"RecordScreen"];
		[self.tabBarItem setImage:[UIImage imageNamed:@"TabBar-Record.png"]];
		
		self.pixelBufferLock = [NSLock new];
		
		self.video_queue = dispatch_queue_create("video_queue", DISPATCH_QUEUE_SERIAL);
		self.fps = 24;
		self.kbps = 5000;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Do any additional setup after loading the view.
	UIImage *archesPattern = [UIImage imageNamed:@"arches.png"];
	UIColor *archesPatternColor = [UIColor colorWithPatternImage:archesPattern];
	[self.view setBackgroundColor:archesPatternColor];
	
	UIViewAutoresizing autoresizingCenter = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
											 UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
	
	CGSize screenSize = self.view.bounds.size;
	float centerOriginY = (screenSize.height / 2.0f) - 20.0f;
	
	self.recordButton = [[UIButton alloc] initWithFrame:CGRectMake(79.0f, centerOriginY, 162.0f, 41.0f)];
	[self.recordButton addTarget:self action:@selector(recordButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[self.recordButton setBackgroundColor:[UIColor clearColor]];
	[self.recordButton setTitleEdgeInsets:UIEdgeInsetsMake(7.0f, 0.0f, 0.0f, 0.0f)];
	[self.recordButton.titleLabel setFont:[UIFont fontWithName:@"Gotham-Bold" size:18.0f]];
	[self.recordButton setTitleColor:RGBA(150.0f, 150.0f, 150.0f, 1.0f) forState:UIControlStateNormal];
	[self.recordButton setTitleShadowColor:RGBA(255.0f, 255.0f, 255.0f, 0.65f) forState:UIControlStateNormal];
	[self.recordButton.titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
	[self.recordButton setAutoresizingMask:autoresizingCenter];
	[self.recordButton setTitle:@"" forState:UIControlStateNormal];
	[self.recordButton setBackgroundImage:[UIImage imageNamed:@"RecordButton1-Normal.png"] forState:UIControlStateNormal];
	[self.recordButton setBackgroundImage:[UIImage imageNamed:@"RecordButton1-Pressed.png"] forState:UIControlStateHighlighted];
	[self.recordButton setBackgroundImage:[UIImage imageNamed:@"RecordButton1-Pressed.png"] forState:UIControlStateSelected];
	[self.recordButton setBackgroundImage:[UIImage imageNamed:@"RecordButton-Disabled.png"] forState:UIControlStateDisabled];
	[self.recordButton setTag:0];
	[self.view addSubview:self.recordButton];
	
	// TODO: Change recordButton.frame depending on device.
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		
	} else {
		
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)recordButtonTapped {
	if (self.recordButton.tag) {
		[self.recordButton setTitle:@"" forState:UIControlStateNormal];
		[self.recordButton setBackgroundImage:[UIImage imageNamed:@"RecordButton1-Normal.png"] forState:UIControlStateNormal];
		[self.recordButton setBackgroundImage:[UIImage imageNamed:@"RecordButton1-Pressed.png"] forState:UIControlStateHighlighted];
		[self.recordButton setBackgroundImage:[UIImage imageNamed:@"RecordButton1-Pressed.png"] forState:UIControlStateSelected];
		[self.recordButton setTag:0];
		[self.recordButton setEnabled:NO];
		[self stopRecording];
	} else {
		[self.recordButton setTitle:@"00:00:00" forState:UIControlStateNormal];
		[self.recordButton setBackgroundImage:[UIImage imageNamed:@"RecordButton2-Normal.png"] forState:UIControlStateNormal];
		[self.recordButton setBackgroundImage:[UIImage imageNamed:@"RecordButton2-Pressed.png"] forState:UIControlStateHighlighted];
		[self.recordButton setBackgroundImage:[UIImage imageNamed:@"RecordButton2-Pressed.png"] forState:UIControlStateSelected];
		[self.recordButton setTag:1];
		[self startRecording];
	}
}


#pragma mark -
#pragma mark Screen Recording Methods

- (void)startRecording {
	NSString *audioPath = [self inDocumentsDirectory:@"audio.caf"];
	
	if (!self.videoWriter) [self setupVideoContext];
	self.recordStartDate = [NSDate date];
	
	NSError *sessionError = nil;
	if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(setCategory:withOptions:error:)])
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDuckOthers error:&sessionError];
	else
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
	[[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
	
	NSError *error = nil;
	NSDictionary *audioSettings = @{AVNumberOfChannelsKey : @2, AVSampleRateKey : @44100.0f};
	
	self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:audioPath] settings:audioSettings error:&error];
	[self.audioRecorder setDelegate:self];
	[self.audioRecorder prepareToRecord];
	[self.audioRecorder record];
	
	self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 block:^{
		NSDate *currentDate = [NSDate date];
		NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.recordStartDate];
		NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"HH:mm:ss"];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
		
		NSString *timeString = [dateFormatter stringFromDate:timerDate];
		[self.recordButton setTitle:timeString forState:UIControlStateNormal];
	} repeats:YES];
	
	self.isRecording = YES;
	
	// Capture loop
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		int targetFPS = self.fps;
		int msBeforeNextCapture = 1000 / targetFPS;
		
		struct timeval lastCapture, currentTime, startTime;
		lastCapture.tv_sec = 0;
		lastCapture.tv_usec = 0;
		
		// Recording start time
		gettimeofday(&startTime, NULL);
		startTime.tv_usec /= 1000;
		
		int lastFrame = -1;
		while (self.isRecording) {
			// Time passed since last capture
			gettimeofday(&currentTime, NULL);
			
			// Convert to milliseconds to avoid overflows
			currentTime.tv_usec /= 1000;
			
			unsigned long long diff = (currentTime.tv_usec + (1000 * currentTime.tv_sec)) - (lastCapture.tv_usec + (1000 * lastCapture.tv_sec));
			
			if (diff >= msBeforeNextCapture) {
				// Time since start
				unsigned long long msSinceStart = (currentTime.tv_usec + (1000 * currentTime.tv_sec)) - (startTime.tv_usec + (1000 * startTime.tv_sec));
				
				int frameNumber = msSinceStart / msBeforeNextCapture;
				CMTime presentTime;
				presentTime = CMTimeMake(frameNumber, targetFPS);
				
				NSParameterAssert(frameNumber != lastFrame);
				lastFrame = frameNumber;
				
				[self captureShot:presentTime];
				lastCapture = currentTime;
			}
		}
		
		dispatch_async(self.video_queue, ^{
			[self finishEncoding];
		});
	});
}

- (void)stopRecording {
	self.isRecording = NO;
	
	[self.recordingTimer invalidate];
	self.recordingTimer = nil;
	[self.audioRecorder stop];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	self.statusBarOverlay = [MTStatusBarOverlay sharedInstance];
	[self.statusBarOverlay setAnimation:MTStatusBarOverlayAnimationFallDown];	// MTStatusBarOverlayAnimationShrink
	[self.statusBarOverlay setProgress:0.0];
	[self.statusBarOverlay postMessage:@"Encoding Video…"];
	
	UITabBarItem *recordingsTabBarItem = [self.tabBarController.tabBar items][1];
	[recordingsTabBarItem setEnabled:NO];
	
	self.recordStartDate = nil;
	self.audioRecorder = nil;
}


#pragma mark -
#pragma mark Capturing Methods

- (void)createScreenSurface {
	unsigned pixelFormat = 0x42475241;	// 'ARGB';
	int bytesPerElement = 4;
	self.bytesPerRow = (bytesPerElement * self.width);
	NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
								@YES, kIOSurfaceIsGlobal,
								@(bytesPerElement), kIOSurfaceBytesPerElement,
								@(self.bytesPerRow), kIOSurfaceBytesPerRow,
								@(self.width), kIOSurfaceWidth,
								@(self.height), kIOSurfaceHeight,
								@(pixelFormat), kIOSurfacePixelFormat,
								@(self.bytesPerRow * self.height), kIOSurfaceAllocSize,
								nil];
	self.surface = IOSurfaceCreate((__bridge CFDictionaryRef)properties);
}

- (void)captureShot:(CMTime)frameTime {
	if (!self.surface) [self createScreenSurface];
	
	IOSurfaceLock(self.surface, 0, nil);
	CARenderServerRenderDisplay(0, CFSTR("LCD"), self.surface, 0, 0);
	IOSurfaceUnlock(self.surface, 0, 0);
	
	void *baseAddr = IOSurfaceGetBaseAddress(self.surface);
	int totalBytes = self.bytesPerRow * self.height;
	void *rawData = malloc(totalBytes);
	memcpy(rawData, baseAddr, totalBytes);
	
	dispatch_async(dispatch_get_main_queue(), ^{
		CVPixelBufferRef pixelBuffer = NULL;
		if (!self.pixelBufferAdaptor.pixelBufferPool){
			NSLog(@"skipping frame: %lld", frameTime.value);
			free(rawData);
			return;
		}
		
		NSParameterAssert(self.pixelBufferAdaptor.pixelBufferPool != NULL);
		[self.pixelBufferLock lock];
		CVPixelBufferPoolCreatePixelBuffer (kCFAllocatorDefault, self.pixelBufferAdaptor.pixelBufferPool, &pixelBuffer);
		[self.pixelBufferLock unlock];
		NSParameterAssert(pixelBuffer != NULL);
		
		// Unlock pixel buffer data
		CVPixelBufferLockBaseAddress(pixelBuffer, 0);
		void *pixelData = CVPixelBufferGetBaseAddress(pixelBuffer);
		NSParameterAssert(pixelData != NULL);
		
		// Copy over raw image data and free
		memcpy(pixelData, rawData, totalBytes);
		free(rawData);
		
		// Unlock pixel buffer data
		CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
		
		dispatch_async(self.video_queue, ^{
			while (!self.videoWriterInput.readyForMoreMediaData) usleep(1000);
			
			[self.pixelBufferLock lock];
			[self.pixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:frameTime];
			CVPixelBufferRelease(pixelBuffer);
			[self.pixelBufferLock unlock];
		});
	});
}


#pragma mark -
#pragma mark Encoding Methods

- (void)setupVideoContext {
	CGRect screenRect = [UIScreen mainScreen].bounds;
	float scale = [UIScreen mainScreen].scale;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		// iPhone frame buffer is Portrait
		self.width = screenRect.size.width * scale;
		self.height = screenRect.size.height * scale;
	} else {
		// iPad frame buffer is Landscape
		self.width = screenRect.size.height * scale;
		self.height = screenRect.size.width * scale;
	}
	
	int videoWidth = self.width;
	int videoHeight = self.height;
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if ([prefs objectForKey:@"videoSize"]) {
		if (![[prefs objectForKey:@"videoSize"] boolValue]) {
			videoWidth /= 2;
			videoHeight /= 2;
		}
	}
	
	NSArray *documents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self inDocumentsDirectory:@""] error:nil];
	self.screenRecordingName = [NSString stringWithFormat:@"ScreenRecording-%i.mp4", documents.count];
	NSString *videoPath = [self inDocumentsDirectory:self.screenRecordingName];
	
	NSError *error = nil;
	self.videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:videoPath] fileType:AVFileTypeMPEG4 error:&error];
	if (error) {
		NSLog(@"error: %@", error);
		return;
	}
	
	NSParameterAssert(self.videoWriter);
	
	NSDictionary *compressionProperties = @{AVVideoAverageBitRateKey : @(self.kbps * 1000), AVVideoMaxKeyFrameIntervalKey : @(self.fps), AVVideoProfileLevelKey : AVVideoProfileLevelH264Main41};
	
	NSDictionary *outputSettings = @{AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : @(videoWidth), AVVideoHeightKey : @(videoHeight), AVVideoCompressionPropertiesKey : compressionProperties};
	
	NSParameterAssert([self.videoWriter canApplyOutputSettings:outputSettings forMediaType:AVMediaTypeVideo]);
	
	self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
	
	NSParameterAssert(self.videoWriterInput);
	NSParameterAssert([self.videoWriter canAddInput:self.videoWriterInput]);
	[self.videoWriter addInput:self.videoWriterInput];
	
	NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									  @(kCVPixelFormatType_32BGRA), kCVPixelBufferPixelFormatTypeKey,
									  @(self.width), kCVPixelBufferWidthKey,
									  @(self.height), kCVPixelBufferHeightKey,
									  kCFAllocatorDefault, kCVPixelBufferMemoryAllocatorKey,
									  nil];
	
	self.pixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoWriterInput
																							   sourcePixelBufferAttributes:bufferAttributes];
	
	// FPS
	[self.videoWriterInput setMediaTimeScale:self.fps];
	[self.videoWriter setMovieTimeScale:self.fps];
	
	// Start a session
	[self.videoWriterInput setExpectsMediaDataInRealTime:YES];
	[self.videoWriter startWriting];
	[self.videoWriter startSessionAtSourceTime:kCMTimeZero];
	
	// TODO: Hhmmm, seems to be crashing right here on the iPad.
	NSParameterAssert(self.pixelBufferAdaptor.pixelBufferPool != NULL);
}

- (void)finishEncoding {
	[self.videoWriterInput markAsFinished];
	[self.videoWriter finishWriting];
	
	self.videoWriter = nil;
	self.videoWriterInput = nil;
	self.pixelBufferAdaptor = nil;
	
	[self.statusBarOverlay setProgress:0.5];
	[self addAudioTrackToRecording];
	
	NSLog(@"Done");
}

- (void)addAudioTrackToRecording {
	double degrees = 0.0;
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if ([prefs objectForKey:@"videoOrientation"])
		degrees = [[prefs objectForKey:@"videoOrientation"] doubleValue];
	
	NSString *videoPath = [self inDocumentsDirectory:self.screenRecordingName];
	NSString *audioPath = [self inDocumentsDirectory:@"audio.caf"];
	
	NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
	NSURL *audioURL = [NSURL fileURLWithPath:audioPath];
	
	AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
	AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioURL options:nil];
	
	AVAssetTrack *assetVideoTrack = nil;
	AVAssetTrack *assetAudioTrack = nil;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath])
		assetVideoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo][0];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:audioPath] && [prefs boolForKey:@"recordAudio"])
		assetAudioTrack = [audioAsset tracksWithMediaType:AVMediaTypeAudio][0];
	
	AVMutableComposition *mixComposition = [AVMutableComposition composition];
	
	if (assetVideoTrack != nil) {
		AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
		[compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:assetVideoTrack atTime:kCMTimeZero error:nil];
		if (assetAudioTrack != nil) [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) toDuration:audioAsset.duration];
		[compositionVideoTrack setPreferredTransform:CGAffineTransformMakeRotation(degreesToRadians(degrees))];
	}
	
	if (assetAudioTrack != nil) {
		AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
		[compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:assetAudioTrack atTime:kCMTimeZero error:nil];
	}
	
	[self.statusBarOverlay setProgress:0.75];
	
	NSString *exportPath = [self inDocumentsDirectory:@"ScreenRecording.mov"];
	NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
		[[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
	
	AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
	[exportSession setOutputFileType:AVFileTypeQuickTimeMovie];
	[exportSession setOutputURL:exportURL];
	[exportSession setShouldOptimizeForNetworkUse:NO];
	
	[exportSession exportAsynchronouslyWithCompletionHandler:^(void){
		switch (exportSession.status) {
			case AVAssetExportSessionStatusCompleted:{
				[[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
				[[NSFileManager defaultManager] removeItemAtPath:audioPath error:nil];
				
				NSString *movieName = [self.screenRecordingName componentsSeparatedByString:@"."][0];
				NSString *moviePath = [self inDocumentsDirectory:[NSString stringWithFormat:@"%@.mov", movieName]];
				[[NSFileManager defaultManager] moveItemAtPath:exportPath toPath:moviePath error:nil];
				break;
			}
				
			case AVAssetExportSessionStatusFailed:
				NSLog(@"Failed: %@", exportSession.error);
				break;
				
			case AVAssetExportSessionStatusCancelled:
				NSLog(@"Canceled: %@", exportSession.error);
				break;
				
			default:
				break;
		}
		
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
		dispatch_async(queue, ^{
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.recordButton setEnabled:YES];
				
				UITabBarItem *recordingsTabBarItem = [self.tabBarController.tabBar items][1];
				[recordingsTabBarItem setEnabled:YES];
				
				[self.statusBarOverlay postImmediateFinishMessage:@"Saved Recording!" duration:2.0 animated:YES];
				[self.statusBarOverlay setProgress:1.0];
			});
		});
	}];
}


#pragma mark -
#pragma mark NSFileManager Methods

- (NSString *)inDocumentsDirectory:(NSString *)path {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:path];
}

@end
