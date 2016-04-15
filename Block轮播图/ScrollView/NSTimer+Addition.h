//
//  NSTimer+Addition.h
//  YXLScrollView
//
//  Created by Yexinglong on 14/10/9.
//  Copyright (c) 2014年 Yexinglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Addition)
- (void)pauseTimer;
- (void)resumeTimer;
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;
@end
