//
//  RecordViewController.h
//  RecordScreen
//
//  Created by Nicolas Gomollon on 1/4/13.
//  Copyright (c) 2013 Techno-Magic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

extern UIImage *_UICreateScreenUIImage();

@interface RecordViewController : UIViewController <AVAudioRecorderDelegate> {
	UIButton *recordButton;
	
	MTStatusBarOverlay *statusBarOverlay;
	
	NSTimer *recordingTimer;
	NSTimer *shotTimer;
	
	NSDate *recordStartDate;
	NSString *shotDirectory;
	int shotCount;
	
	AVAudioRecorder *audioRecorder;
}

@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) MTStatusBarOverlay *statusBarOverlay;
@property (nonatomic, strong) NSTimer *recordingTimer;
@property (nonatomic, strong) NSTimer *shotTimer;
@property (nonatomic, strong) NSDate *recordStartDate;
@property (nonatomic, strong) NSString *shotDirectory;
@property (nonatomic, assign) int shotCount;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

@end
