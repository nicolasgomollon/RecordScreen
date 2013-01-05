//
//  NSTimer+Blocks.h
//  NSTimer+Blocks
//
//  Created by Nicolas Gomollon on 6/2/12.
//  Copyright (c) 2012 Techno-Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Blocks)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
+ (id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;

@end
