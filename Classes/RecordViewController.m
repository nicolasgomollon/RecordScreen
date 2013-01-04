//
//  RecordViewController.m
//  RecordScreen
//
//  Created by Nicolas Gomollon on 1/4/13.
//  Copyright (c) 2013 Techno-Magic. All rights reserved.
//

#import "RecordViewController.h"

@implementation RecordViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		[self setTitle:@"Record"];
		[self.tabBarItem setImage:[UIImage imageNamed:@"TabBar-Record.png"]];
	}
	return self;
}
							
- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Do any additional setup after loading the view, typically from a nib.
	[self.view setBackgroundColor:[UIColor whiteColor]];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 228.0f, 320.0f, 24.0f)];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setTextAlignment:UITextAlignmentCenter];
		[label setText:@"If you can read this, it worked! :)"];
		[self.view addSubview:label];
	} else {
		
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
