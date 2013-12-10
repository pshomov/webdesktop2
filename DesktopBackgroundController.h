@class DesktopBackgroundWindow;

@interface DesktopBackgroundController : NSObject <NSWindowDelegate> {
    NSURLRequest* cachedRequest;
	NSURL* location;
    WebView* webView;
	DesktopBackgroundWindow* window;
}

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (void)refresh;

- (NSURL*)formatURL:(NSURL*)inURL;
- (void)loadURL:(NSURL*)inURL;

- (void)createWindowWithContentRect:(NSRect)contentRect showFrame:(BOOL)showFrame alphaValue:(CGFloat)alphaValue screen:(NSScreen*)screen;

@end
