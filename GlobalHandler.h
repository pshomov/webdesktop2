//
//  Created by petar on 3/18/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class DesktopBackgroundWindow;
@class DesktopBackgroundController;


@interface GlobalHandler : NSObject
{
    IBOutlet NSSlider* activeOpacitySlider;
    IBOutlet NSSlider* inactiveOpacitySlider;
    IBOutlet NSWindow* prefsWindow;
	IBOutlet NSPopUpButton* refreshPopUp;
    IBOutlet NSMenu* mainmenu;
    IBOutlet NSWindow* openLocationWindow;
    IBOutlet NSTextField* openLocationText;
	IBOutlet NSWindow* aboutWindow;


    NSArray* controller;
    NSTimer* timer;
}
- (IBAction)openLocation:(id)sender;
- (IBAction)openLocationCancel:(id)sender;
- (IBAction)openLocationOK:(id)sender;
- (IBAction)setRefreshInterval:(id)sender;
- (void)initPrefs;
- (IBAction)openAbout:(id)sender;
- (IBAction)prefs:(id)sender;
- (IBAction)prefsOK:(id)sender;


- (IBAction)refresh:(id)sender;

@end