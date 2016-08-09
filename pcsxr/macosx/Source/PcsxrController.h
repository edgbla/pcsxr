/* PcsxrController */

#import <Cocoa/Cocoa.h>
#import "EmuThread.h"

@class ConfigurationController;
@class CheatController;
@class RecentItemsMenu;

__private_extern void ShowHelpAndExit(FILE* __nonnull output, int exitCode);
extern BOOL wasFinderLaunch;

@interface PcsxrController : NSObject <NSApplicationDelegate>
@property (weak, null_unspecified) IBOutlet RecentItemsMenu *recentItems;
@property (strong, readonly, nullable) CheatController *cheatController;
@property (readonly) BOOL endAtEmuClose;

- (IBAction)ejectCD:(nullable id)sender;
- (IBAction)pause:(nullable id)sender;
- (IBAction)showCheatsWindow:(nullable id)sender;
- (IBAction)preferences:(nullable id)sender;
- (IBAction)reset:(nullable id)sender;
- (IBAction)runCD:(nullable id)sender;
- (IBAction)runIso:(nullable id)sender;
- (IBAction)runBios:(nullable id)sender;
- (IBAction)freeze:(nullable id)sender;
- (IBAction)defrost:(nullable id)sender;
- (IBAction)fullscreen:(nullable id)sender;
- (IBAction)pauseInBackground:(nullable id)sender;
- (void)runURL:(nonnull NSURL*)url;

+ (void)setConfigFromDefaults;
+ (void)setDefaultFromConfig:(nonnull NSString *)defaultKey;
+ (BOOL)biosAvailable;
+ (nonnull NSString*)saveStatePath:(int)slot;
+ (void)saveState:(int)num;
+ (void)loadState:(int)num;

@end
