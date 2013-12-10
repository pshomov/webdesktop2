@class CustomWindow;

@interface Controller : NSObject <NSWindowDelegate> {
	IBOutlet NSWindow* aboutWindow;
    IBOutlet NSSlider* activeOpacitySlider;
    IBOutlet NSSlider* inactiveOpacitySlider;
    IBOutlet NSWindow* prefsWindow;
	IBOutlet NSPopUpButton* refreshPopUp;
    IBOutlet NSMenu* mainmenu;

    NSURLRequest* cachedRequest;
	NSURL* location;
    WebView* webView;
	CustomWindow* window;
}

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)opacityAdjust:(id)sender;
- (IBAction)openAbout:(id)sender;
- (IBAction)openFile:(id)sender;
- (IBAction)prefs:(id)sender;
- (IBAction)prefsOK:(id)sender;
- (void)refresh;

- (NSURL*)formatURL:(NSURL*)inURL;
- (void)loadURL:(NSURL*)inURL;
- (void)resetOpacity;

- (void)createWindowWithContentRect:(NSRect)contentRect showFrame:(BOOL)showFrame alphaValue:(CGFloat)alphaValue screen:(NSScreen*)screen;

@end
