@class CustomWindow;

@interface Controller : NSObject
{
	IBOutlet NSWindow* aboutWindow;
    IBOutlet NSSlider* activeOpacitySlider;
    IBOutlet NSSlider* inactiveOpacitySlider;
    IBOutlet NSTextField* openLocationText;
    IBOutlet NSWindow* openLocationWindow;
    IBOutlet NSWindow* prefsWindow;
	IBOutlet NSPopUpButton* refreshPopUp;
    IBOutlet NSMenu* mainmenu;

	BOOL bringToFront;
	NSURLRequest* cachedRequest;
	NSURL* location;
	NSTimer* timer;
	WebView* webView;
	CustomWindow* window;
}

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)opacityAdjust:(id)sender;
- (IBAction)openAbout:(id)sender;
- (IBAction)openFile:(id)sender;
- (IBAction)openLocation:(id)sender;
- (IBAction)openLocationCancel:(id)sender;
- (IBAction)openLocationOK:(id)sender;
- (IBAction)prefs:(id)sender;
- (IBAction)prefsOK:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)setRefreshInterval:(id)sender;

- (void)createWindowWithContentRect:(NSRect)contentRect showFrame:(BOOL)showFrame;
- (NSURL*)formatURL:(NSURL*)inURL;
- (void)initPrefs;
- (void)loadURL:(NSURL*)inURL;
- (void)resetOpacity;
- (void)setClickThrough:(BOOL)clickThrough;
- (void)setWindowFrameEnabled:(BOOL)windowFrameEnabled;
- (void)startTimer:(int)mins;

@end
