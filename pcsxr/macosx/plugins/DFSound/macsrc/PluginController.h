/* NetSfPeopsSPUPluginController */

#import <Cocoa/Cocoa.h>

@class SPUPluginController;

#ifndef __private_extern
#define __private_extern __attribute__((visibility("hidden")))
#endif

__private_extern void ReadConfig(void);

#define kHighCompMode @"High Compatibility Mode"
#define kSPUIRQWait @"SPU IRQ Wait"
#define kXAPitch @"XA Pitch"
#define kMonoSoundOut @"Mono Sound Output"

#define kInterpolQual @"Interpolation Quality"
#define kReverbQual @"Reverb Quality"
#define kVolume @"Volume"
