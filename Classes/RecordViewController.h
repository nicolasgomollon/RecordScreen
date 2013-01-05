//
//  RecordViewController.h
//  RecordScreen
//
//  Created by Nicolas Gomollon on 1/4/13.
//  Copyright (c) 2013 Techno-Magic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordViewController : UIViewController <AVAudioRecorderDelegate> {
	UIButton *recordButton;
}

@property (nonatomic, strong) UIButton *recordButton;

@end
