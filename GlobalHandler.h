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
	IBOutlet NSWindow* aboutWindow;
    IBOutlet NSSlider* activeOpacitySlider;
    IBOutlet NSSlider* inactiveOpacitySlider;
    IBOutlet NSTextField* openLocationText;
    IBOutlet NSWindow* openLocationWindow;
    IBOutlet NSWindow* prefsWindow;
	IBOutlet NSPopUpButton* refreshPopUp;
    IBOutlet NSMenu* mainmenu;


    CustomWindow* window;
    Controller* controller;
	BOOL bringToFront;
	NSURLRequest* cachedRequest;
	NSURL* location;
	NSTimer* timer;
	WebView* webView;
}
@property(nonatomic, assign) int mins;

- (IBAction)setRefreshInterval:(id)sender;
- (void)initPrefs;
@end