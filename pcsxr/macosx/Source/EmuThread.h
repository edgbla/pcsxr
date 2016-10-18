//
//  EmuThread.h
//  Pcsxr
//
//  Created by Gil Pedersen on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <setjmp.h>

#define kEmuWindowDidClose @"emuWindowDidClose"

typedef NS_ENUM(char, EmuThreadPauseStatus) {
	PauseStateIsNotPaused = 0,
	PauseStatePauseRequested,
	PauseStateIsPaused
};

NS_ASSUME_NONNULL_BEGIN

@interface EmuThread : NSObject

- (void)EmuThreadRun:(nullable id)anObject;
- (void)EmuThreadRunBios:(nullable id)anObject;
- (void)handleEvents;

+ (void)run;
+ (void)runBios;
+ (void)stop;
+ (BOOL)pause;
+ (BOOL)pauseSafe;
+ (void)pauseSafeWithBlock:(void (^)(BOOL))theBlock;
+ (void)resume;
+ (void)resetNow;
+ (void)reset;

+ (BOOL)isPaused;
+ (EmuThreadPauseStatus)pausedState;
+ (BOOL)active;
+ (BOOL)isRunBios;

+ (void)freezeAt:(NSString *)path which:(int)num;
+ (BOOL)defrostAt:(NSString *)path;

@property (class, readonly, getter=isPaused) BOOL paused;
@property (class, readonly) EmuThreadPauseStatus pausedState;
@property (class, readonly) BOOL active;
@property (class, readonly, getter=isRunBios) BOOL runBios;

@end

extern EmuThread *__nullable emuThread;

NS_ASSUME_NONNULL_END
