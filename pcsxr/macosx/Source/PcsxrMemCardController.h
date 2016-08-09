//
//  PcsxrMemCardManager.h
//  Pcsxr
//
//  Created by Charles Betts on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PcsxrMemCardArray;

@interface PcsxrMemCardController : NSViewController
@property (weak, null_unspecified) IBOutlet NSCollectionView *memCard1view;
@property (weak, null_unspecified) IBOutlet NSCollectionView *memCard2view;
@property (weak, null_unspecified) IBOutlet NSTextField *memCard1Label;
@property (weak, null_unspecified) IBOutlet NSTextField *memCard2Label;

@property (readonly, strong, nonnull) PcsxrMemCardArray *memCard1Array;
@property (readonly, strong, nonnull) PcsxrMemCardArray *memCard2Array;

- (IBAction)moveBlock:(nullable id)sender;
- (IBAction)formatCard:(nullable id)sender;
- (IBAction)deleteMemoryObject:(nullable id)sender;
- (void)loadMemoryCardInfoForCard:(int)theCard;

@end
