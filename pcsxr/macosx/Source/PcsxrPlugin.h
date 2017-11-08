//
//  PcsxrPlugin.h
//  Pcsxr
//
//  Created by Gil Pedersen on Fri Oct 03 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PcsxrPlugin : NSObject
@property (readonly, copy) NSString *path;
@property (readonly, copy, nullable) NSString *name;
@property (readonly) int type;

+ (NSString *)prefixForType:(int)type;
+ (NSString *)defaultKeyForType:(int)type;
+ (char *__nullable *__nonnull)configEntriesForType:(int)type;
@property (class, readonly, copy) NSArray<NSString*> *pluginsPaths;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (nullable instancetype)initWithPath:(NSString *)aPath NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithURL:(NSURL *)aPath;

@property (readonly, copy) NSString *displayVersion;
- (BOOL)hasAboutAs:(int)type;
- (BOOL)hasConfigureAs:(int)type;
- (long)runAs:(int)aType;
- (long)shutdownAs:(int)aType;
- (void)aboutAs:(int)type;
- (void)configureAs:(int)type;
- (BOOL)verifyOK;

@end

NS_ASSUME_NONNULL_END
