#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SNHUDActivityView.h"
#import "Downloader.h"
#import "PopupView.h"
#import "VerticalBarIndexView.h"

#define RES_PER_PAGE 100

@interface ThreadViewController : UIViewController < 
	UIWebViewDelegate
>
{
	IBOutlet UIToolbar			*underToolbar_;
    IBOutlet UIBarButtonItem	*addBookmarkButton_;
    IBOutlet UIBarButtonItem	*openBookmarkButton_;
    IBOutlet UIBarButtonItem	*reloadButton_;
    IBOutlet UIBarButtonItem	*replyButton_;
    IBOutlet UIView				*content_;
	IBOutlet UISegmentedControl *pagingButtons_;
	
	int							currentPage_;
	int							allres_;
	IBOutlet UIWebView			*webView_;
	
//	int							thread_id_;
	SNHUDActivityView			*hud_;
	PopupView					*popupView_;
	VerticalBarIndexView		*indexView_;
	
	Downloader					*downloader_;
//	NSString					*boardPath_;
//	NSString					*dat_;
	
	BOOL						scrollToLast_;
	
	UIImageView					*hudView_;
	UILabel						*currentPageLabel_;
	UILabel						*allResLabel_;
	
	UIAlertView					*confirmOpenSafari_;
}
#pragma mark For debug
- (BOOL) respondsToSelector:(SEL) selector;
- (void) setBoardPath:(NSString*)boardPath dat:(NSString*)dat;
#pragma mark Override
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void) lastPage;
- (void) load;
- (void) viewWillDisappear;
- (void) viewDidLoad;
- (void)dealloc;
- (void) setUIToolbarReload;
- (void) setUIToolbarStop;
- (void) reloadCurrentThread;
- (void) didFailLoadingWithIdentifier:(NSString*)identifier isDifferentURL:(BOOL)isDifferentURL;
- (void) didFinishLoading:(id)data identifier:(NSString*)identifier;
#pragma mark IBOutlet
- (IBAction)addBookmarkAction:(id)sender;
- (IBAction)openBookmarkAction:(id)sender;
- (IBAction) cancelLoading:(id)sender;
- (IBAction)reloadAction:(id)sender;
- (IBAction)replyAction:(id)sender;
- (IBAction)pagingAction:(id)sender;
#pragma mark UIViewControllerDelegate
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
#pragma mark UIWebViewControllerDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
#pragma mark Original method
- (void) setBoard:(NSString*)board dat:(NSString*)dat;
- (void) setDat:(NSData*)data;
- (void) setThreadID:(int) thread_id;
- (void) setPage:(int) page;
- (void) loadHTML;
- (void) makeHUDView;
- (void) showHUD;
- (void)hideHUD:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (NSString*) makeHTMLWithLandscape:(BOOL)landscape;
- (BOOL) isURLOf2ch:(NSString*)url;
#pragma mark For HUD
- (void) openActivityHUD:(id)obj;
@end
