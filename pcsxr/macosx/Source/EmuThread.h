//
//  EmuThread.h
//  Pcsxr
//
//  Created by Gil Pedersen on Sun Sep 21 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kEmuWindowDidClose kEmuWindowDidCloseNotification

typedef NS_ENUM(char, EmuThreadPauseStatus) {
	PauseStateIsNotPaused = 0,
	PauseStatePauseRequested,
	PauseStateIsPaused
};

NS_ASSUME_NONNULL_BEGIN

/// "emuWindowDidClose"
extern NSString *const kEmuWindowDidCloseNotification;

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

#if __has_feature(objc_class_property)
@property (class, readonly, getter=isPaused) BOOL paused;
@property (class, readonly) EmuThreadPauseStatus pausedState;
@property (class, readonly) BOOL active;
@property (class, readonly, getter=isRunBios) BOOL runBios;
#else
+ (BOOL)isPaused;
+ (EmuThreadPauseStatus)pausedState;
+ (BOOL)active;
+ (BOOL)isRunBios;
#endif

+ (void)freezeAt:(NSString *)path which:(int)num;
+ (BOOL)defrostAt:(NSString *)path;

@end

extern EmuThread *__nullable emuThread;

NS_ASSUME_NONNULL_END
