#import "CustomWindow.h"

@implementation CustomWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag 
{
    NSWindow* result = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];

    [result setBackgroundColor:[NSColor clearColor]];
    [result setOpaque:NO];
	
    return result;
}


// Custom windows that use the NSBorderlessWindowMask can't become key by default.  Therefore, controls in such windows
// won't ever be enabled by default.  Thus, we override this method to change that.

- (BOOL)canBecomeKeyWindow
{
    return YES;
}


- (BOOL)canBecomeMainWindow
{
    return YES;
}


@end
