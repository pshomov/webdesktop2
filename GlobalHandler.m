//
//  Created by petar on 3/18/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "GlobalHandler.h"
#import "CustomWindow.h"
#import "Controller.h"


@implementation GlobalHandler {
    int _mins;
}
@synthesize mins = _mins;


- (void)applicationDidChangeScreenParameters:(NSNotification *)aNotification
    {
        [self applicationDidBecomeActive:aNotification];
    }

    - (void)applicationDidBecomeActive:(NSNotification*)aNotification
    {
    	[self createWindowWithContentRect:[[NSScreen mainScreen] frame] showFrame:FALSE];

        [window setAlphaValue:[inactiveOpacitySlider doubleValue]];
    	[self setClickThrough:YES];
    }

    - (void)awakeFromNib
    {
    	NSRect contentRect;

    	[self initPrefs];

    	NSString* frameString = NULL;

    	if ( frameString )
    		contentRect = NSRectFromString(frameString);
    	else
    	{
    		contentRect = [[NSScreen mainScreen] frame];
    	}

    	[self createWindowWithContentRect:contentRect showFrame:NO];

    	if ( !frameString )
    		[window center];


        NSMenu* m = mainmenu;
        NSStatusItem* item = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        [item retain];
        [item setMenu:m];
        [item setTitle:@"WD"];
        [item setHighlightMode:YES];

        [self startTimer:_mins];

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

    _mins = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RefreshInterval"] intValue];

    if ( _mins == 1 )
		[refreshPopUp selectItemAtIndex:1];

	else if ( _mins == 5 )
		[refreshPopUp selectItemAtIndex:2];

	else if ( _mins == 15 )
		[refreshPopUp selectItemAtIndex:3];

	else if ( _mins == 30 )
		[refreshPopUp selectItemAtIndex:4];

	else if ( _mins == 60 )
		[refreshPopUp selectItemAtIndex:5];

	else if ( _mins == 2 * 60 )
		[refreshPopUp selectItemAtIndex:6];

	else if ( _mins == 4 * 60 )	// 4 hrs
		[refreshPopUp selectItemAtIndex:7];

	else if ( _mins == 8 * 60 )	// 8 hrs
		[refreshPopUp selectItemAtIndex:8];

	else if ( _mins == 12 * 60 )	// 12 hrs
		[refreshPopUp selectItemAtIndex:9];

	else if ( _mins == 24 * 60 )	// 12 hrs
		[refreshPopUp selectItemAtIndex:10];

	else
	{
		_mins = 0;
		[refreshPopUp selectItemAtIndex:0];
	}
}

- (void)createWindowWithContentRect:(NSRect)contentRect showFrame:(BOOL)showFrame
{

	CustomWindow* oldWindow = window;
    Controller* ctrlr = [[Controller alloc] init];
    controller = ctrlr;
    window = [[CustomWindow alloc] initWithContentRect:contentRect styleMask:(showFrame ? NSTitledWindowMask | NSResizableWindowMask : NSBorderlessWindowMask) backing:NSBackingStoreBuffered defer:NO];

    [ctrlr setwindow:window];

    [window setMinSize:NSMakeSize(200, 100)];
	[window setTitle:@"WebDesktop"];

    [window setLevel:kCGDesktopWindowLevel];

	[window setFrame:contentRect display:YES];
	[window setAlphaValue:[activeOpacitySlider doubleValue]];

	[window setDelegate:ctrlr];
	[self setClickThrough:NO];

	if ( !webView )
	{
		webView = [[WebView alloc] initWithFrame:[[window contentView] frame] frameName:@"main" groupName:@"main"];
		[webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[webView setUIDelegate:self];
		[webView setPolicyDelegate:self];
		[webView setDownloadDelegate:self];

		[[window contentView] addSubview:webView];
	}
	else
	{
		[webView setFrame:[[window contentView] frame]];
		[webView retain];
		[[window contentView] addSubview:webView];
		[webView release];
	}

	[window makeFirstResponder:webView];
    [controller setWebView:webView];

	if ( bringToFront )
		[window makeKeyAndOrderFront:nil];
	else
	{
		[window makeKeyWindow];
		[window orderBack:nil];
	}

	bringToFront = YES;

	if ( oldWindow )
		[oldWindow release];

    NSString* lastURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastURL"];
   	if ( lastURL )
   		[ctrlr loadURL:[NSURL URLWithString:lastURL]];
   	else
   		[ctrlr loadURL:[NSURL URLWithString:@"http://www.panic.com/"]];
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
- (void)setClickThrough:(BOOL)clickThrough
{
	void* ref = [window windowRef];

	if ( clickThrough )
	{
		ChangeWindowAttributes(ref,
				kWindowIgnoreClicksAttribute, kWindowNoAttributes);
	}
	else
	{
		ChangeWindowAttributes(ref,
				kWindowNoAttributes, kWindowIgnoreClicksAttribute);
	}

	[window setIgnoresMouseEvents:clickThrough];
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