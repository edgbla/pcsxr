#import "PluginController.h"
#include "stdafx.h"
#include "externals.h"
#include "maccfg.h"


#ifdef ENABLE_NLS
#include <libintl.h>
#include <locale.h>
#define _(x)  gettext(x)
#define N_(x) (x)
//If running under Mac OS X, use the Localizable.strings file instead.
#elif defined(_MACOSX)
#ifdef PCSXRCORE
__private_extern char* Pcsxr_locale_text(char* toloc);
#define _(String) Pcsxr_locale_text(String)
#define N_(String) String
#else
#ifndef PCSXRPLUG
#warning please define the plug being built to use Mac OS X localization!
#define _(msgid) msgid
#define N_(msgid) msgid
#else
//Kludge to get the preprocessor to accept PCSXRPLUG as a variable.
#define PLUGLOC_x(x,y) x ## y
#define PLUGLOC_y(x,y) PLUGLOC_x(x,y)
#define PLUGLOC PLUGLOC_y(PCSXRPLUG,_locale_text)
__private_extern char* PLUGLOC(char* toloc);
#define _(String) PLUGLOC(String)
#define N_(String) String
#endif
#endif
#else
#define _(x)  (x)
#define N_(x) (x)
#endif

#ifdef USEOPENAL
#define APP_ID @"net.sf.peops.SPUALPlugin"
#import "PeopsSpuAL-Swift.h"
#else
#define APP_ID @"net.sf.peops.SPUSDLPlugin"
#import "PeopsSpuSDL-Swift.h"
#endif
#define PrefsKey APP_ID @" Settings"

static SPUPluginController *pluginController = nil;

static inline void RunOnMainThreadSync(dispatch_block_t block)
{
	if ([NSThread isMainThread]) {
		block();
	} else {
		dispatch_sync(dispatch_get_main_queue(), block);
	}
}

void DoAbout()
{
	// Get parent application instance
	NSBundle *bundle = [NSBundle bundleWithIdentifier:APP_ID];
	
	// Get Credits.rtf
	NSString *path = [bundle pathForResource:@"Credits" ofType:@"rtf"];
	NSAttributedString *credits;
	if (!path) {
		path = [bundle pathForResource:@"Credits" ofType:@"rtfd"];
	}
	if (path) {
		credits = [[NSAttributedString alloc] initWithPath:path documentAttributes:NULL];
	} else {
		credits = [[NSAttributedString alloc] initWithString:@""];
	}
	
	// Get Application Icon
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[bundle bundlePath]];
	NSSize size = NSMakeSize(64, 64);
	[icon setSize:size];
	
	NSDictionary *infoPaneDict =
	@{@"ApplicationName": [bundle objectForInfoDictionaryKey:@"CFBundleName"],
	  @"ApplicationIcon": icon,
	  @"ApplicationVersion": [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
	  @"Version": [bundle objectForInfoDictionaryKey:@"CFBundleVersion"],
	  @"Copyright": [bundle objectForInfoDictionaryKey:@"NSHumanReadableCopyright"],
	  @"Credits": credits};
	dispatch_async(dispatch_get_main_queue(), ^{
		[NSApp orderFrontStandardAboutPanelWithOptions:infoPaneDict];
	});
}

long DoConfiguration()
{
	RunOnMainThreadSync(^{
		NSWindow *window;
		
		if (pluginController == nil) {
			pluginController = [[SPUPluginController alloc] initWithWindowNibName:@"NetSfPeopsSpuPluginMain"];
		}
		window = [pluginController window];
		
		/* load values */
		[pluginController loadValues];
		
		[window center];
		[window makeKeyAndOrderFront:nil];
	});

	return 0;
}

void ReadConfig(void)
{
	NSDictionary *keyValues;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[defaults registerDefaults:
		 @{PrefsKey: @{kHighCompMode: @YES,
					   kSPUIRQWait: @YES,
					   kXAPitch: @NO,
					   kMonoSoundOut: @NO,
					   kInterpolQual: @0,
					   kReverbQual: @1,
					   kVolume: @3}}];
	});
	
	keyValues = [defaults dictionaryForKey:PrefsKey];
	
	iUseTimer = [keyValues[kHighCompMode] boolValue] ? 2 : 0;
	iSPUIRQWait = [keyValues[kSPUIRQWait] boolValue];
	iDisStereo = [keyValues[kMonoSoundOut] boolValue];
	iXAPitch = [keyValues[kXAPitch] boolValue];
	
	iUseInterpolation = [keyValues[kInterpolQual] intValue];
	iUseReverb = [keyValues[kReverbQual] intValue];
	
	iVolume = 5 - [keyValues[kVolume] intValue];
}

#import "OSXPlugLocalization.h"
PLUGLOCIMP([SPUPluginController class]);
