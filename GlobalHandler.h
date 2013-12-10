//
//  Created by petar on 3/18/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class CustomWindow;
@class Controller;


@interface GlobalHandler : NSObject
{
    IBOutlet NSSlider* activeOpacitySlider;
    IBOutlet NSSlider* inactiveOpacitySlider;
    IBOutlet NSWindow* prefsWindow;
	IBOutlet NSPopUpButton* refreshPopUp;
    IBOutlet NSMenu* mainmenu;
    IBOutlet NSWindow* openLocationWindow;
    IBOutlet NSTextField* openLocationText;


    NSArray* controller;
    NSTimer* timer;
}
- (IBAction)openLocation:(id)sender;
- (IBAction)openLocationCancel:(id)sender;
- (IBAction)openLocationOK:(id)sender;
- (IBAction)setRefreshInterval:(id)sender;
- (void)initPrefs;

- (IBAction)refresh:(id)sender;

@end