//
//  PSXMemEnumerator.h
//  Pcsxr
//
//  Created by C.W. Betts on 7/20/14.
//
//

#import <Foundation/Foundation.h>
#import "PcsxrMemoryObject.h"
#include "MyQuickLook.h"

__private_extern NSArray<PcsxrMemoryObject*> *__nullable CreateArrayByEnumeratingMemoryCardAtURL(NSURL *__nonnull location) NS_RETURNS_RETAINED;
