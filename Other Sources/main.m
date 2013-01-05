//
//  main.m
//  RecordScreen
//
//  Created by Nicolas Gomollon on 1/4/13.
//  Copyright (c) 2013 Techno-Magic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "NGTableViewCellDeleteConfirmationControl.h"
#import "AppDelegate.h"

int main(int argc, char *argv[]) {
	@autoreleasepool {
		// Swizzle delete button
		Class deleteControl = NSClassFromString([NSString stringWithFormat:@"_%@DeleteConfirmationControl", @"UITableViewCell"]);
		if (deleteControl) {
			Method drawRectCustom = class_getInstanceMethod(deleteControl, @selector(drawRect:));
			Method drawRect = class_getInstanceMethod([NGTableViewCellDeleteConfirmationControl class], @selector(drawRectCustom:));
			method_exchangeImplementations(drawRect, drawRectCustom);
		}
		
		return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
	}
}
