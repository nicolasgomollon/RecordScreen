//
//  NGTableViewCellDeleteConfirmationControl.m
//  NGTableViewCellDeleteConfirmationControl
//
//  Created by Nicolas Gomollon on 10/9/12.
//  Copyright (c) 2012 Techno-Magic. All rights reserved.
//

#import "NGTableViewCellDeleteConfirmationControl.h"
#import <objc/runtime.h>

@implementation NGTableViewCellDeleteConfirmationControl

- (void)drawRectCustom:(CGRect)rect {
	UIImage *image = nil;
	if (self.highlighted) {
		image = [UIImage imageNamed:@"archive-button-highlighted.png"];
	} else {
		image = [UIImage imageNamed:@"archive-button.png"];
	}
	[[image stretchableImageWithLeftCapWidth:5 topCapHeight:0] drawInRect:rect];
	
	NSString *text = [self valueForKey:@"title"];
	UIFont *font = [UIFont fontWithName:@"MyriadPro-Bold" size:15.0f];
	UILineBreakMode lineBreakMode = UILineBreakModeClip;
	UITextAlignment alignment = UITextAlignmentCenter;
	
	rect.origin.y += 11.0f;
	[[UIColor colorWithRed:0.588f green:0.090f blue:0.125f alpha:1.0f] set];
	[text drawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:alignment];
	
	[[UIColor whiteColor] set];
	rect.origin.y -= 1.0f;
	[text drawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:alignment];
}

@end
