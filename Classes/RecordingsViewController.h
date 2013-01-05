//
//  RecordingsViewController.h
//  RecordScreen
//
//  Created by Nicolas Gomollon on 1/4/13.
//  Copyright (c) 2013 Techno-Magic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

@interface RecordingsViewController : UITableViewController {
	UILabel *footerLabel;
}

@property (nonatomic, strong) UILabel *footerLabel;

@end
