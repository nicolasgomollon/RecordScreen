//
//  AppDelegate.h
//  RecordScreen
//
//  Created by Nicolas Gomollon on 1/4/13.
//  Copyright (c) 2013 Techno-Magic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordViewController.h"
#import "RecordingsViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UITabBarController *tabBarController;

@end
