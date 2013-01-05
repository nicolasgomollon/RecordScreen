//
//  RecordViewController.m
//  RecordScreen
//
//  Created by Nicolas Gomollon on 1/4/13.
//  Copyright (c) 2013 Techno-Magic. All rights reserved.
//

#import "RecordViewController.h"

@implementation RecordViewController

@synthesize recordButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		[self setTitle:@"RecordScreen"];
		[self.tabBarItem setImage:[UIImage imageNamed:@"TabBar-Record.png"]];
	}
	return self;
}
							
- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Do any additional setup after loading the view, typically from a nib.
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
	} else {
		[self.recordButton setTitle:@"00:30:42" forState:UIControlStateNormal];
		[self.recordButton setBackgroundImage:[UIImage imageNamed:@"RecordButton2-Normal.png"] forState:UIControlStateNormal];
		[self.recordButton setBackgroundImage:[UIImage imageNamed:@"RecordButton2-Pressed.png"] forState:UIControlStateHighlighted];
		[self.recordButton setBackgroundImage:[UIImage imageNamed:@"RecordButton2-Pressed.png"] forState:UIControlStateSelected];
		[self.recordButton setTag:1];
	}
}

@end
