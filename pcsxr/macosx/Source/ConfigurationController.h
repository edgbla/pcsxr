/* ConfigurationController */

#import <Cocoa/Cocoa.h>
#import "HotkeyController.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const memChangeNotifier;
extern NSString *const memCardChangeNumberKey;

@class PcsxrMemCardController;
@class PluginController;

@interface ConfigurationController : NSWindowController <NSWindowDelegate, NSTabViewDelegate>
@property (weak, null_unspecified) IBOutlet PluginController *cdromPlugin;
@property (weak, null_unspecified) IBOutlet PluginController *graphicsPlugin;
@property (weak, null_unspecified) IBOutlet PluginController *padPlugin;
@property (weak, null_unspecified) IBOutlet PluginController *soundPlugin;
@property (weak, null_unspecified) IBOutlet PluginController *netPlugin;
@property (weak, null_unspecified) IBOutlet PluginController *sio1Plugin;

@property (weak, null_unspecified) IBOutlet PcsxrMemCardController *memCardEdit;

// Hotkeys
@property (weak, null_unspecified) IBOutlet HotkeyController *hkController;
@property (weak, null_unspecified) IBOutlet NSTabViewItem *hkTab;

@property (weak, null_unspecified) IBOutlet NSButtonCell *noXaAudioCell;
@property (weak, null_unspecified) IBOutlet NSButtonCell *sioIrqAlwaysCell;
@property (weak, null_unspecified) IBOutlet NSButtonCell *bwMdecCell;
@property (weak, null_unspecified) IBOutlet NSButtonCell *autoVTypeCell;
@property (weak, null_unspecified) IBOutlet NSPopUpButton *vTypePALCell;
@property (weak, null_unspecified) IBOutlet NSButtonCell *noCDAudioCell;
@property (weak, null_unspecified) IBOutlet NSButtonCell *usesHleCell;
@property (weak, null_unspecified) IBOutlet NSButtonCell *usesDynarecCell;
@property (weak, null_unspecified) IBOutlet NSButtonCell *consoleOutputCell;
@property (weak, null_unspecified) IBOutlet NSButtonCell *spuIrqAlwaysCell;
@property (weak, null_unspecified) IBOutlet NSButtonCell *rCountFixCell;
@property (weak, null_unspecified) IBOutlet NSButtonCell *vSyncWAFixCell;
@property (weak, null_unspecified) IBOutlet NSButtonCell *noFastBootCell;
@property (weak, null_unspecified) IBOutlet NSButtonCell *enableNetPlayCell;
@property (weak, null_unspecified) IBOutlet NSButtonCell *widescreen;

- (IBAction)setCheckbox:(nullable id)sender;
- (IBAction)setCheckboxInverse:(nullable id)sender;
- (IBAction)setVideoType:(nullable id)sender;

+ (void)setMemoryCard:(NSInteger)theCard toPath:(NSString *)theFile;
+ (void)setMemoryCard:(NSInteger)theCard toURL:(NSURL *)theURL;

- (IBAction)mcdNewClicked:(nullable id)sender;
- (IBAction)mcdChangeClicked:(nullable id)sender;

//- (void)tabView:(nonnull NSTabView *)tabView didSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem;

@end

NS_ASSUME_NONNULL_END
