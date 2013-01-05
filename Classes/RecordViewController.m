//
//  RecordViewController.m
//  RecordScreen
//
//  Created by Nicolas Gomollon on 1/4/13.
//  Copyright (c) 2013 Techno-Magic. All rights reserved.
//

#import "RecordViewController.h"

@implementation RecordViewController

@synthesize recordButton, statusBarOverlay, recordingTimer, shotTimer, recordStartDate, shotDirectory, shotCount, audioRecorder;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		[self setTitle:@"RecordScreen"];
		[self.tabBarItem setImage:[UIImage imageNamed:@"TabBar-Record.png"]];
		self.shotDirectory = [self inDocumentsDirectory:@"Shots"];
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
	
	[[NSFileManager defaultManager] removeItemAtPath:audioPath error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:self.shotDirectory error:nil];
	[[NSFileManager defaultManager] createDirectoryAtPath:self.shotDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	
	self.recordStartDate = [NSDate date];
	self.shotCount = 0;
	
	NSError *sessionError = nil;
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDuckOthers error:&sessionError];
	[[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
	
	NSError *error = nil;
	NSDictionary *audioSettings = @{AVNumberOfChannelsKey : @2};
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
	
	self.shotTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(grabShot) userInfo:nil repeats:YES];
}

- (void)grabShot {
	@autoreleasepool {
		IOMobileFramebufferConnection connect;
		kern_return_t result;
		CoreSurfaceBufferRef screenSurface = NULL;
		
		io_service_t framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleH1CLCD"));
		if (!framebufferService)
			framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleM2CLCD"));
		if (!framebufferService)
			framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleCLCD"));
		
		result = IOMobileFramebufferOpen(framebufferService, mach_task_self(), 0, &connect);
		
		result = IOMobileFramebufferGetLayerDefaultSurface(connect, 0, &screenSurface);
		
		uint32_t aseed;
		IOSurfaceLock(screenSurface, kIOSurfaceLockReadOnly, &aseed);
		uint32_t width = IOSurfaceGetWidth(screenSurface);
		uint32_t height = IOSurfaceGetHeight(screenSurface);
		
		CFMutableDictionaryRef dict;
		int pitch = width * 4;
		int size = 4 * width * height;
		int bPE = 4;
		char pixelFormat[4] = {'A','R','G','B'};
		
		CFNumberRef surfaceBytesPerRow, surfaceBytesPerElement, surfaceWidth, surfaceHeight, surfacePixelFormat, surfaceAllocSize;
		
		dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		CFDictionarySetValue(dict, kIOSurfaceIsGlobal, kCFBooleanTrue);
		
		surfaceBytesPerRow = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &pitch);
		CFDictionarySetValue(dict, kIOSurfaceBytesPerRow, surfaceBytesPerRow);
		
		surfaceBytesPerElement = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bPE);
		CFDictionarySetValue(dict, kIOSurfaceBytesPerElement, surfaceBytesPerElement);
		
		surfaceWidth = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &width);
		CFDictionarySetValue(dict, kIOSurfaceWidth, surfaceWidth);
		
		surfaceHeight = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &height);
		CFDictionarySetValue(dict, kIOSurfaceHeight, surfaceHeight);
		
		surfacePixelFormat = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, pixelFormat);
		CFDictionarySetValue(dict, kIOSurfacePixelFormat, surfacePixelFormat);
		
		surfaceAllocSize = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &size);
		CFDictionarySetValue(dict, kIOSurfaceAllocSize, surfaceAllocSize);
		
		IOSurfaceRef destSurf = IOSurfaceCreate(dict);
		CoreSurfaceAcceleratorRef outAcc;
		CoreSurfaceAcceleratorCreate(NULL, 0, &outAcc);
		
		CFDictionaryRef ed = (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:nil];
		CoreSurfaceAcceleratorTransferSurfaceWithSwap(outAcc, screenSurface, destSurf, ed);
		
		IOSurfaceUnlock(screenSurface, kIOSurfaceLockReadOnly, &aseed);
		
		CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, IOSurfaceGetBaseAddress(destSurf), (width * height * 4), NULL);
		CGColorSpaceRef devicergb = CGColorSpaceCreateDeviceRGB();
		
		CGImageRef cgImage = CGImageCreate(width, height, 8, 8 * 4, IOSurfaceGetBytesPerRow(destSurf), devicergb, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little, provider, NULL, YES, kCGRenderingIntentDefault);
		UIImage *shot = [UIImage imageWithCGImage:cgImage];
		
		CGImageRelease(cgImage);
		CGColorSpaceRelease(devicergb);
		CGDataProviderRelease(provider);
		
		CFRelease(outAcc);
		
		CFRelease(surfaceBytesPerRow);		//Don't keep these in the RAM. They're poisonous!
		CFRelease(surfaceBytesPerElement);
		CFRelease(surfaceWidth);
		CFRelease(surfaceHeight);
		CFRelease(surfacePixelFormat);
		CFRelease(surfaceAllocSize);
		CFRelease(dict);
		
		IOServiceClose(framebufferService);	//Close those connections!
		IOServiceClose(connect);
		
		NSString *shotName = [NSString stringWithFormat:@"%i.png", self.shotCount];
		NSData *data = UIImagePNGRepresentation(shot);
		[data writeToFile:[self.shotDirectory stringByAppendingPathComponent:shotName] atomically:YES];
		
		CFRelease(destSurf);
		self.shotCount++;
	}
}

- (void)stopRecording {
	[self.recordingTimer invalidate];
	self.recordingTimer = nil;
	
	[self.shotTimer invalidate];
	self.shotTimer = nil;
	
	self.shotCount -= 1;
	
	[self.audioRecorder stop];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	self.statusBarOverlay = [MTStatusBarOverlay sharedInstance];
	[self.statusBarOverlay setAnimation:MTStatusBarOverlayAnimationFallDown];	// MTStatusBarOverlayAnimationShrink
	[self.statusBarOverlay setProgress:0.0];
	[self.statusBarOverlay postMessage:@"Encoding Video…"];
	
	UITabBarItem *recordingsTabBarItem = [self.tabBarController.tabBar items][1];
	[recordingsTabBarItem setEnabled:NO];
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
	dispatch_async(queue, ^{
		NSLog(@"Start");
		
		NSString *firstShotPath = [self.shotDirectory stringByAppendingPathComponent:@"0.png"];
		UIImage *firstShot = [UIImage imageWithContentsOfFile:firstShotPath];
		CGSize size = firstShot.size;
		
		NSDate *currentDate = [NSDate date];
		NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.recordStartDate];
		
		NSArray *documents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self inDocumentsDirectory:@""] error:nil];
		NSString *videoName = [NSString stringWithFormat:@"ScreenRecording-%i.mp4", (documents.count - 2)];
		NSString *videoPath = [self inDocumentsDirectory:videoName];
		
		[self encodeVideotoPath:videoPath size:size duration:timeInterval];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSFileManager defaultManager] removeItemAtPath:[self inDocumentsDirectory:@"audio.caf"] error:nil];
			[[NSFileManager defaultManager] removeItemAtPath:self.shotDirectory error:nil];
			
			[self.recordButton setEnabled:YES];
			
			[self.statusBarOverlay postImmediateFinishMessage:@"Saved Recording!" duration:2.0 animated:YES];
			[self.statusBarOverlay setProgress:1.0];
			
			[recordingsTabBarItem setEnabled:YES];
		});
	});
	
	self.recordStartDate = nil;
	self.audioRecorder = nil;
}


#pragma mark -
#pragma mark Video Encoding Methods

- (void)encodeVideotoPath:(NSString *)path size:(CGSize)size duration:(int)duration {
	NSError *error = nil;
	AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path] fileType:AVFileTypeMPEG4 error:&error];
	
	NSParameterAssert(videoWriter);
	NSDictionary *videoSettings = @{AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : @(size.width), AVVideoHeightKey : @(size.height)};
	AVAssetWriterInput *videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
	
	AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput sourcePixelBufferAttributes:nil];
	NSParameterAssert(videoWriterInput);
	
	NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
	[videoWriter addInput:videoWriterInput];
	
	[videoWriter startWriting];
	[videoWriter startSessionAtSourceTime:kCMTimeZero];
	
	
	CVPixelBufferRef buffer = NULL;
	int i = 0;
	
	NSString *shotName = [NSString stringWithFormat:@"%i.png", i];
	NSString *shotPath = [self.shotDirectory stringByAppendingPathComponent:shotName];
	UIImage *shot = [UIImage imageWithContentsOfFile:shotPath];
	
	buffer = [self pixelBufferFromCGImage:[shot CGImage] size:size];
	CVPixelBufferPoolCreatePixelBuffer(NULL, pixelBufferAdaptor.pixelBufferPool, &buffer);
	
	while (videoWriterInput.readyForMoreMediaData && i < self.shotCount) {
		@autoreleasepool {
			dispatch_async(dispatch_get_main_queue(), ^{
				float encodeProgress = (float)i / (float)self.shotCount;
				[self.statusBarOverlay setProgress:encodeProgress];
			});
			
			CMTime frameTime = CMTimeMake(1, 1);
			CMTime lastTime = CMTimeMake(i, 10);
			CMTime presentTime = CMTimeAdd(lastTime, frameTime);
			
			NSString *imageName = [NSString stringWithFormat:@"%i.png", i];
			NSString *imagePath = [self.shotDirectory stringByAppendingPathComponent:imageName];
			UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
			
			buffer = [self pixelBufferFromCGImage:[image CGImage] size:size];
			[pixelBufferAdaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
			
			CVPixelBufferRelease(buffer);
		}
		i++;
	}
	
	[videoWriterInput markAsFinished];
	[videoWriter finishWriting];
	
	CVPixelBufferPoolRelease(pixelBufferAdaptor.pixelBufferPool);
	
	NSLog(@"Done");
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size {
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 @YES, kCVPixelBufferCGImageCompatibilityKey,
							 @YES, kCVPixelBufferCGBitmapContextCompatibilityKey,
							 nil];
	
	CVPixelBufferRef pxbuffer = NULL;
	CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options, &pxbuffer);
	
	NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
	CVPixelBufferLockBaseAddress(pxbuffer, 0);
	void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
	
	NSParameterAssert(pxdata != NULL);
	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4 * size.width, rgbColorSpace, kCGImageAlphaNoneSkipFirst);
	
	NSParameterAssert(context);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, CGImageGetWidth(image), CGImageGetHeight(image)), image);
	CGColorSpaceRelease(rgbColorSpace);
	CGContextRelease(context);
	
	CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
	
	return pxbuffer;
}


#pragma mark -
#pragma mark NSFileManager Methods

- (NSString *)inDocumentsDirectory:(NSString *)path {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:path];
}

@end
