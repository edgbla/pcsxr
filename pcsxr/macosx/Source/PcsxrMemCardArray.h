//
//  PcsxrMemCardArray.h
//  Pcsxr
//
//  Created by C.W. Betts on 7/6/13.
//
//

#import <Foundation/Foundation.h>
//#import "PcsxrMemoryObject.h"

@interface PcsxrMemCardArray : NSObject

- (nonnull instancetype)initWithMemoryCardNumber:(int)carNum NS_DESIGNATED_INITIALIZER;

- (void)deleteMemoryBlocksAtIndex:(int)slotnum;
- (void)compactMemory;

@property (readonly) int freeBlocks;
@property (readonly) int availableBlocks;
- (int)memorySizeAtIndex:(int)idx;
- (BOOL)moveBlockAtIndex:(int)idx toMemoryCard:(nonnull PcsxrMemCardArray*)otherCard;
- (int)indexOfFreeBlocksWithSize:(int)asize;

@property (nonatomic, readonly, unsafe_unretained, nonnull) NSArray *memoryArray;
@property (nonatomic, readonly, unsafe_unretained, nonnull) NSURL *memCardURL;
@property (nonatomic, readonly, nonnull) const char *memCardCPath;

@end
