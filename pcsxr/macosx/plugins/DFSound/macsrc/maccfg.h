//
//  maccfg.h
//  PeopsSPU
//

#ifndef PeopsSPU_maccfg_h
#define PeopsSPU_maccfg_h

#ifndef __private_extern
#define __private_extern __attribute__((visibility("hidden")))
#endif

__private_extern void DoAbout();
__private_extern long DoConfiguration();

#endif
