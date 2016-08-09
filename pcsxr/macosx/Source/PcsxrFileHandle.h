//
//  PcsxrFileHandle.h
//  Pcsxr
//
//  Created by Charles Betts on 12/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PcsxrFileHandle <NSObject>
@property (readonly, copy, class) NSArray<NSString*> *supportedUTIs;
- (BOOL)handleFile:(NSString *)theFile;
@end

NS_ASSUME_NONNULL_END
