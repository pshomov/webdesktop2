#import "Controller.h"
#import "CustomWindow.h"

@implementation Controller

- (NSWindow*)downloadWindowForAuthenticationSheet:(WebDownload*)download;
{
	[NSApp activateIgnoringOtherApps:YES];
	return window;
}


- (NSURL*)formatURL:(NSURL*)inURL
{
	NSMutableString* url;
	
	if ( inURL == nil ) 
		return nil;
		
	url = [NSMutableString stringWithString:[inURL absoluteString]];
	
	if( [inURL path] == nil || [[inURL path] length] == 0  )
	{
		[url appendString:@"/"];
		
		if( [inURL scheme] == nil )
			[url insertString:@"http://" atIndex:0];
		
		return [NSURL URLWithString:url];
	}
	else
	if( [[[inURL path] pathExtension] length] == 0 )
	{
		if( ![url hasSuffix:@"/"] )
			[url appendString:@"/"];
		
		inURL = [NSURL URLWithString:url];
	}

	return [NSURL URLWithString:[inURL absoluteString]];
}


- (IBAction)goBack:(id)sender
{
	[webView goBack];
}


- (void)goForward:(id)inSender
{
	[webView goForward];
}

- (void)loadURL:(NSURL*)inURL
{
	[location autorelease];
	location = [self formatURL:inURL];
	
	if ( location )
	{
		[location retain];
		
		NSString* ua = [webView userAgentForURL:inURL];
		if ( ua )
		{
			NSScanner* scanner = [NSScanner scannerWithString:ua];
			if ( scanner )
			{
				[scanner scanUpToString:@"AppleWebKit/" intoString:nil];
				[scanner scanString:@"AppleWebKit/" intoString:nil];

				NSString* webKitVersion = nil;
				[scanner scanUpToString:@" " intoString:&webKitVersion];
				
				if ( webKitVersion )
				{
					[webView setApplicationNameForUserAgent:[NSString 
										stringWithFormat:@"Safari/%@ (WebDesktop)", webKitVersion]]; // fix for Google Maps API javascript sniffer
				}
			}
		}
		
		WebFrame* mainFrame = [webView mainFrame];
		[mainFrame loadRequest:[NSURLRequest requestWithURL:location]];

		[[NSUserDefaults standardUserDefaults] setObject:[inURL absoluteString] forKey:@"LastURL"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	[window makeFirstResponder:webView];
}


- (IBAction)opacityAdjust:(id)sender
{
	[window setAlphaValue:[sender doubleValue]];
}


- (IBAction)openAbout:(id)sender
{
	bringToFront = NO;
	[NSApp activateIgnoringOtherApps:YES];

	[aboutWindow center];
	[aboutWindow makeKeyAndOrderFront:self];
}


- (IBAction)openFile:(id)sender
{   
	bringToFront = NO;
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


- (IBAction)openLocation:(id)sender
{
	bringToFront = NO;
	[NSApp activateIgnoringOtherApps:YES];

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


- (IBAction)prefs:(id)sender
{
	bringToFront = NO;
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
	
	[self resetOpacity];
}


- (IBAction)refresh:(id)sender
{
	[[webView mainFrame] reload];
}


- (void)refreshTimerFired:(NSTimer*)inTimer
{
	//NSLog(@"reloading page...");
	[self refresh:self];
}


- (void)resetOpacity
{
	if ( [NSApp isActive] )
		[window setAlphaValue:[activeOpacitySlider doubleValue]];
	else
		[window setAlphaValue:[inactiveOpacitySlider doubleValue]];
}

- (void)setwindow:(CustomWindow *)wnd {
    window = wnd;
}


- (BOOL)validateMenuItem:(NSMenuItem*)item
{
	if ( [item action] == @selector(goBack:) )
		return [webView canGoBack];

	if ( [item action] == @selector(goForward:) )
		return [webView canGoForward];
		
	return YES;
}


- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener
{
	[cachedRequest release];
	cachedRequest = [request copy];
	[listener use];
}


- (WebView*)webView:(WebView*)sender createWebViewWithRequest:(NSURLRequest*)request
{
	if ( request == nil )
		request = cachedRequest;
		
	[[NSWorkspace sharedWorkspace] openURL:[request URL]];
	
	[cachedRequest release];
	cachedRequest = nil;
	
	return nil;
}


- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message
{
	NSRunAlertPanel(@"WebDesktop", message, @"OK", nil, nil);
}


- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message
{
	return (NSRunAlertPanel(@"WebDesktop", message, @"Cancel", @"OK", nil) == NSAlertAlternateReturn);
}


- (void)windowDidMove:(NSNotification*)notification
{
	NSWindow* srcWindow = [notification object];
	NSRect frameRect = [srcWindow frame];
	NSRect contentRect = [NSWindow contentRectForFrameRect:frameRect styleMask:[srcWindow styleMask]];
	[[NSUserDefaults standardUserDefaults] setObject:NSStringFromRect(contentRect) forKey:@"WindowFrame"];	
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)setWebView:(WebView *)view {
   webView = view;
}
@end
