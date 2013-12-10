//
//  Created by petar on 3/18/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "GlobalHandler.h"
#import "DesktopBackgroundController.h"


@implementation GlobalHandler {
    int _minutes;
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)aNotification {
    [self setupBrowserForEachDesktop];
}

- (void)setupBrowserForEachDesktop {
    if (controller != NULL) {
        for (NSUInteger j = 0; j < controller.count; j++) {
            [[controller objectAtIndex:j] release];
        }
    }
    NSMutableArray *new_controllers = [[[NSMutableArray alloc] init] autorelease];
    NSArray *screens = [NSScreen screens];
    for (NSUInteger k = 0; k < screens.count; k++) {
        DesktopBackgroundController *window_controller = [[[DesktopBackgroundController alloc] init] autorelease];
        [window_controller createWindowWithContentRect:[[screens objectAtIndex:k] frame] showFrame:FALSE alphaValue:[activeOpacitySlider doubleValue] screen:[screens objectAtIndex:k]];
        [new_controllers addObject:window_controller];
    }
    controller = [[NSArray alloc] initWithArray:new_controllers];
}


- (void)awakeFromNib {

    [self initPrefs];
    [self setupBrowserForEachDesktop];

    NSMenu *m = mainmenu;
    NSStatusItem *item = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [item retain];
    [item setMenu:m];
    [item setTitle:@"WD"];
    [item setHighlightMode:YES];

    [self startTimer:_minutes];

    [NSApp deactivate];
}

- (void)initPrefs {
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    [defaultValues setObject:[NSNumber numberWithDouble:0.8] forKey:@"ActiveOpacity"];
    [defaultValues setObject:[NSNumber numberWithDouble:0.5] forKey:@"InactiveOpacity"];
    [defaultValues setObject:[NSNumber numberWithInt:0] forKey:@"RefreshInterval"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];

    [activeOpacitySlider setDoubleValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"ActiveOpacity"] doubleValue]];
    [inactiveOpacitySlider setDoubleValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"InactiveOpacity"] doubleValue]];

    _minutes = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RefreshInterval"] intValue];

    if (_minutes == 1)
        [refreshPopUp selectItemAtIndex:1];

    else if (_minutes == 5)
        [refreshPopUp selectItemAtIndex:2];

    else if (_minutes == 15)
        [refreshPopUp selectItemAtIndex:3];

    else if (_minutes == 30)
        [refreshPopUp selectItemAtIndex:4];

    else if (_minutes == 60)
        [refreshPopUp selectItemAtIndex:5];

    else if (_minutes == 2 * 60)
        [refreshPopUp selectItemAtIndex:6];

    else if (_minutes == 4 * 60)    // 4 hrs
        [refreshPopUp selectItemAtIndex:7];

    else if (_minutes == 8 * 60)    // 8 hrs
        [refreshPopUp selectItemAtIndex:8];

    else if (_minutes == 12 * 60)    // 12 hrs
        [refreshPopUp selectItemAtIndex:9];

    else if (_minutes == 24 * 60)    // 12 hrs
        [refreshPopUp selectItemAtIndex:10];

    else {
        _minutes = 0;
        [refreshPopUp selectItemAtIndex:0];
    }
}

- (void)startTimer:(int)mins {
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }

    if (mins == 0)
        return;

    timer = [NSTimer scheduledTimerWithTimeInterval:(mins * 60) target:self selector:@selector(refreshTimerFired:) userInfo:nil repeats:YES];
    [timer retain];
}

- (IBAction)setRefreshInterval:(id)sender {
    int selected = [(NSPopUpButton *) sender indexOfSelectedItem];
    int minutes = 0;

    if (selected == 1)
        minutes = 1;

    else if (selected == 2)
        minutes = 5;

    else if (selected == 3)
        minutes = 15;

    else if (selected == 4)
        minutes = 30;

    else if (selected == 5)
        minutes = 60;

    else if (selected == 6)
        minutes = 2 * 60;

    else if (selected == 7)
        minutes = 4 * 60;

    else if (selected == 8)
        minutes = 8 * 60;

    else if (selected == 9)
        minutes = 12 * 60;

    else if (selected == 10)
        minutes = 24 * 60;

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:minutes] forKey:@"RefreshInterval"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self startTimer:minutes];
}

- (void)refreshTimerFired:(NSTimer *)inTimer {
    for (NSUInteger j = 0; j < controller.count; j++) {
        [[controller objectAtIndex:j] refresh:self];
    }
}

- (IBAction)openFile:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
    
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setResolvesAliases:YES];
	[openPanel setAllowsMultipleSelection:NO];
    
	// XXX - Can we get the types from the Info.plist somehow?
    
	if ( [openPanel runModalForTypes:[NSArray arrayWithObjects:@"html", @"php", @"pl", nil]] == NSOKButton )
	{
		[self loadURL:[[openPanel URLs] objectAtIndex:0]];
	}
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [DesktopBackgroundController instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    for (NSUInteger i = 0; i < controller.count; i++) {
        [anInvocation invokeWithTarget:[controller objectAtIndex:i]];
    }
}

- (IBAction)refresh:(id)sender
{
    for (NSUInteger i = 0; i < controller.count; i++) {
        DesktopBackgroundController* c = [controller objectAtIndex:i];
        [c refresh];
    }
}


- (IBAction)openLocation:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
    [openLocationText setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"LastURL"]];
    
	[openLocationWindow center];
	[openLocationWindow makeKeyAndOrderFront:self];
	[openLocationWindow makeFirstResponder:openLocationText];
}


- (IBAction)openLocationCancel:(id)sender
{
	[openLocationWindow orderOut:self];
}


- (IBAction)openLocationOK:(id)sender
{
	[openLocationWindow orderOut:self];
    
	NSMutableString*	urlString;
	NSURL*				url;
    
	urlString = [NSMutableString stringWithString:
                 [openLocationText stringValue]];
	url = [NSURL URLWithString:urlString];
    
	if( [url scheme] == nil )
		[urlString insertString:@"http://" atIndex:0];
    
	[self loadURL:[NSURL URLWithString:urlString]];
}

- (IBAction)openAbout:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
    
	[aboutWindow center];
	[aboutWindow makeKeyAndOrderFront:self];
}



- (IBAction)prefs:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
    
	[prefsWindow center];
	[prefsWindow makeKeyAndOrderFront:self];
}


- (IBAction)prefsOK:(id)sender
{
	[prefsWindow orderOut:self];
    
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:[activeOpacitySlider doubleValue]] forKey:@"ActiveOpacity"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:[inactiveOpacitySlider doubleValue]] forKey:@"InactiveOpacity"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc {
    [controller release];
    [timer release];
    [super dealloc];
}

@end