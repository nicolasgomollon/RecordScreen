//
//  NSTimer+Blocks.m
//  NSTimer+Blocks
//
//  Created by Nicolas Gomollon on 6/2/12.
//  Copyright (c) 2012 Techno-Magic. All rights reserved.
//

#import "NSTimer+Blocks.h"

@implementation NSTimer (Blocks)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats {
	void (^block)() = [inBlock copy];
	id ret = [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(jdExecuteSimpleBlock:) userInfo:block repeats:inRepeats];
#if !__has_feature(objc_arc)
	[block release];
#endif
	return ret;
}

+ (id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats {
	void (^block)() = [inBlock copy];
	id ret = [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(jdExecuteSimpleBlock:) userInfo:block repeats:inRepeats];
#if !__has_feature(objc_arc)
	[block release];
#endif
	return ret;
}

+ (void)jdExecuteSimpleBlock:(NSTimer *)inTimer {
	if ([inTimer userInfo]) {
		void (^block)() = (void (^)())[inTimer userInfo];
		block();
	}
}

@end
