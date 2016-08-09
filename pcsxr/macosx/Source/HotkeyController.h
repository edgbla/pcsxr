/**
 * HotkeyController 
 * Nicolas Pépin-Perreault - npepinpe - 2012
 */

#import <Cocoa/Cocoa.h>

@interface HotkeyController : NSView

@property (weak, null_unspecified) IBOutlet NSTextField *FastForward;
@property (weak, null_unspecified) IBOutlet NSTextField *SaveState;
@property (weak, null_unspecified) IBOutlet NSTextField *LoadState;
@property (weak, null_unspecified) IBOutlet NSTextField *NextState;
@property (weak, null_unspecified) IBOutlet NSTextField *PrevState;
@property (weak, null_unspecified) IBOutlet NSTextField *FrameLimit;


@property NSInteger configInput;

- (void) initialize;
- (BOOL) handleMouseDown:(nonnull NSEvent *)mouseEvent;
- (IBAction) hotkeySet:(nullable id)sender;
- (void) hotkeyCancel;

@end
