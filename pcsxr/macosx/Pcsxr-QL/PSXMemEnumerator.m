//
//  PSXMemEnumerator.c
//  Pcsxr
//
//  Created by C.W. Betts on 7/20/14.
//
//

#include <stdio.h>
#import "PSXMemEnumerator.h"

#define MAX_MEMCARD_BLOCKS 15
#define ISLINKMIDBLOCK(Info) (((Info)->Flags & 0xF) == 0x2)
#define ISLINKENDBLOCK(Info) (((Info)->Flags & 0xF) == 0x3)
#define ISLINKBLOCK(Info) (ISLINKENDBLOCK((Info)) || ISLINKMIDBLOCK((Info)))
#define ISDELETED(Info) (((Info)->Flags & 0xF) >= 1 && ((Info)->Flags & 0xF) <= 3)
#define ISBLOCKDELETED(Info) (((Info)->Flags & 0xF0) == 0xA0)
#define ISSTATUSDELETED(Info) (ISBLOCKDELETED(Info) && ISDELETED(Info))
#define ISLINKED(Data) ( ((Data) != 0xFFFFU) && ((Data) <= MAX_MEMCARD_BLOCKS) )
#define GETLINKFORBLOCK(Data, block) (*((Data)+(((block)*128)+0x08)))

static int GetMcdBlockCount(unsigned char *data, u8 startblock, u8* blocks) {
	int i=0;
	u8 *dataT, curblock=startblock;
	u16 linkblock;
	
	blocks[i++] = startblock;
	do {
		dataT = data+((curblock*128)+0x08);
		linkblock = ((u16*)dataT)[0];
		
		// TODO check if target block has link flag (2 or 3)
		linkblock = ( ISLINKED(linkblock) ? linkblock : 0xFFFFU );
		blocks[i++] = curblock = linkblock + 1;
		//printf("LINKS %x %x %x %x %x\n", blocks[0], blocks[i-2], blocks[i-1], blocks[i], blocks[i+1]);
	} while (ISLINKED(linkblock));
	return i-1;
}

static void GetSoloBlockInfo(unsigned char *data, int block, McdBlock *Info)
{
	unsigned char *ptr = data + block * 8192 + 2;
	unsigned char *str = Info->Title;
	unsigned short clut[16];
	unsigned char *	sstr = Info->sTitle;
	unsigned short c;
	int i, x = 0;
	
	memset(Info, 0, sizeof(McdBlock));
	Info->IconCount = *ptr & 0x3;
	ptr += 2;
	
	for (i = 0; i < 48; i++) {
		c = *(ptr) << 8;
		c |= *(ptr + 1);
		if (!c)
			break;
		
		// Convert ASCII characters to half-width
		if (c >= 0x8281 && c <= 0x829A) {
			c = (c - 0x8281) + 'a';
		} else if (c >= 0x824F && c <= 0x827A) {
			c = (c - 0x824F) + '0';
		} else if (c == 0x8140) {
			c = ' ';
		} else if (c == 0x8143) {
			c = ',';
		} else if (c == 0x8144) {
			c = '.';
		} else if (c == 0x8146) {
			c = ':';
		} else if (c == 0x8147) {
			c = ';';
		} else if (c == 0x8148) {
			c = '?';
		} else if (c == 0x8149) {
			c = '!';
		} else if (c == 0x815E) {
			c = '/';
		} else if (c == 0x8168) {
			c = '"';
		} else if (c == 0x8169) {
			c = '(';
		} else if (c == 0x816A) {
			c = ')';
		} else if (c == 0x816D) {
			c = '[';
		} else if (c == 0x816E) {
			c = ']';
		} else if (c == 0x817C) {
			c = '-';
		} else {
			str[i] = ' ';
			sstr[x++] = *ptr++;
			sstr[x++] = *ptr++;
			continue;
		}
		
		str[i] = sstr[x++] = c;
		ptr += 2;
	}
	
	ptr = data + block * 8192 + 0x60; // icon palette data
	
	for (i = 0; i < 16; i++) {
		clut[i] = *((unsigned short *)ptr);
		ptr += 2;
	}
	
	for (i = 0; i < Info->IconCount; i++) {
		short *icon = &Info->Icon[i * 16 * 16];
		
		ptr = data + block * 8192 + 128 + 128 * i; // icon data
		
		for (x = 0; x < 16 * 16; x++) {
			icon[x++] = clut[*ptr & 0xf];
			icon[x] = clut[*ptr >> 4];
			ptr++;
		}
	}

	ptr = data + block * 128;
	
	Info->Flags = *ptr;
	
	ptr += 0xa;
	strlcpy(Info->ID, ptr, 13);
	ptr += 12;
	strlcpy(Info->Name, ptr, 17);
}

static inline PCSXRMemFlag MemBlockFlag(unsigned char blockFlags)
{
	if ((blockFlags & 0xF0) == 0xA0) {
		if ((blockFlags & 0xF) >= 1 && (blockFlags & 0xF) <= 3)
			return PCSXRMemFlagDeleted;
		else
			return PCSXRMemFlagFree;
	} else if ((blockFlags & 0xF0) == 0x50) {
		if ((blockFlags & 0xF) == 0x1)
			return PCSXRMemFlagUsed;
		else if ((blockFlags & 0xF) == 0x2)
			return PCSXRMemFlagLink;
		else if ((blockFlags & 0xF) == 0x3)
			return PCSXRMemFlagEndLink;
	} else
		return PCSXRMemFlagFree;
	
	//Xcode complains unless we do this...
	//NSLog(@"Unknown flag %x", blockFlags);
	return PCSXRMemFlagFree;
}


NSArray *CreateArrayByEnumeratingMemoryCardAtURL(NSURL *location)
{
	NSMutableArray *memArray = [[NSMutableArray alloc] initWithCapacity:MAX_MEMCARD_BLOCKS];
	if (!location) {
		return nil;
	}
	NSData *fileData = [[NSData alloc] initWithContentsOfURL:location options:NSDataReadingMappedIfSafe error:NULL];
	if (!fileData) {
		return nil;
	}
	
	const unsigned char *memPtr = [fileData bytes];
	if ([fileData length] == MCD_SIZE + 64)
		memPtr += 64;
	else if([fileData length] == MCD_SIZE + 3904)
		memPtr += 3904;
	else if ([fileData length] != MCD_SIZE)
		return nil;
	unsigned char cardNums[MAX_MEMCARD_BLOCKS+1];
	BOOL populated[MAX_MEMCARD_BLOCKS] = {0};

	int i = 0, x;
	while (i < MAX_MEMCARD_BLOCKS) {
		x = 1;
		McdBlock memBlock;
		GetSoloBlockInfo((unsigned char *)memPtr, i + 1, &memBlock);
		
		if (MemBlockFlag(memBlock.Flags) == PCSXRMemFlagFree) {
			//Free space: ignore
			i++;
			continue;
		}
		
		@autoreleasepool {
			int idxCount = GetMcdBlockCount((unsigned char *)memPtr, i+1, cardNums);
			NSMutableIndexSet *cardIdx = [[NSMutableIndexSet alloc] init];
			for (int idxidx = 0; idxidx < idxCount; idxidx++) {
				[cardIdx addIndex:cardNums[idxidx] - 1];
				populated[cardNums[idxidx] - 1] = YES;
			}
			i += x;
			if (MemBlockFlag(memBlock.Flags) == PCSXRMemFlagDeleted) {
				continue;
			}
			PcsxrMemoryObject *obj = [[PcsxrMemoryObject alloc] initWithMcdBlock:&memBlock blockIndexes:cardIdx];
			[memArray addObject:obj];
		}
	}
	
	return [[NSArray alloc] initWithArray:memArray];
}
