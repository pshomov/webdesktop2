//
//  Created by petar on 3/18/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "GlobalHandler.h"
#import "CustomWindow.h"
#import "Controller.h"


@implementation GlobalHandler {
    int _minutes;
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)aNotification
    {
        if (controller) [controller release];
        controller = [[Controller alloc] init];
        [controller createWindowWithContentRect:[[NSScreen mainScreen] frame] showFrame:FALSE alphaValue:0];
    }

    - (void)applicationDidBecomeActive:(NSNotification*)aNotification
    {

    }

    - (void)awakeFromNib
    {
    	NSRect contentRect;

    	[self initPrefs];

        controller = [[Controller alloc] init];
        [controller createWindowWithContentRect:[[NSScreen mainScreen] frame] showFrame:FALSE alphaValue:[activeOpacitySlider doubleValue]];

        NSMenu* m = mainmenu;
        NSStatusItem* item = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        [item retain];
        [item setMenu:m];
        [item setTitle:@"WD"];
        [item setHighlightMode:YES];

        [self startTimer:_minutes];

    	[NSApp deactivate];
    }
- (void)initPrefs
{
	NSMutableDictionary* defaultValues = [NSMutableDictionary dictionary];
	[defaultValues setObject:[NSNumber numberWithDouble:0.8] forKey:@"ActiveOpacity"];
	[defaultValues setObject:[NSNumber numberWithDouble:0.5] forKey:@"InactiveOpacity"];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:@"RefreshInterval"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];

	[activeOpacitySlider setDoubleValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"ActiveOpacity"] doubleValue]];
	[inactiveOpacitySlider setDoubleValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"InactiveOpacity"] doubleValue]];

    _minutes = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RefreshInterval"] intValue];

    if ( _minutes == 1 )
		[refreshPopUp selectItemAtIndex:1];

	else if ( _minutes == 5 )
		[refreshPopUp selectItemAtIndex:2];

	else if ( _minutes == 15 )
		[refreshPopUp selectItemAtIndex:3];

	else if ( _minutes == 30 )
		[refreshPopUp selectItemAtIndex:4];

	else if ( _minutes == 60 )
		[refreshPopUp selectItemAtIndex:5];

	else if ( _minutes == 2 * 60 )
		[refreshPopUp selectItemAtIndex:6];

	else if ( _minutes == 4 * 60 )	// 4 hrs
		[refreshPopUp selectItemAtIndex:7];

	else if ( _minutes == 8 * 60 )	// 8 hrs
		[refreshPopUp selectItemAtIndex:8];

	else if ( _minutes == 12 * 60 )	// 12 hrs
		[refreshPopUp selectItemAtIndex:9];

	else if ( _minutes == 24 * 60 )	// 12 hrs
		[refreshPopUp selectItemAtIndex:10];

	else
	{
		_minutes = 0;
		[refreshPopUp selectItemAtIndex:0];
	}
}

- (void)startTimer:(int)mins
{
	if ( timer )
	{
		[timer invalidate];
		[timer release];
		timer = nil;
	}

	if ( mins == 0 )
		return;

	timer = [NSTimer scheduledTimerWithTimeInterval:(mins * 60) target:self selector:@selector(refreshTimerFired:) userInfo:nil repeats:YES];
	[timer retain];
}

- (IBAction)setRefreshInterval:(id)sender
{
	int selected = [(NSPopUpButton*)sender indexOfSelectedItem];
	int mins = 0;

	if ( selected == 1 )
		mins = 1;

	else if ( selected == 2 )
		mins = 5;

	else if ( selected == 3 )
		mins = 15;

	else if ( selected == 4 )
		mins = 30;

	else if ( selected == 5 )
		mins = 60;

	else if ( selected == 6 )
		mins = 2 * 60;

	else if ( selected == 7 )
		mins = 4 * 60;

	else if ( selected == 8 )
		mins = 8 * 60;

	else if ( selected == 9 )
		mins = 12 * 60;

	else if ( selected == 10 )
		mins = 24 * 60;

	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:mins] forKey:@"RefreshInterval"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self startTimer:mins];
}

- (void)refreshTimerFired:(NSTimer*)inTimer
{
	//NSLog(@"reloading page...");
	[controller refresh:self];
}

@end