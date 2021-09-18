
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIView-Internal.h>
#import <UIKit/UIScroller.h>

#import <UIKit/UIWebView.h>

struct _WKViewContext {
	void *drawCallback;
	void *drawUserInfo;
	void *eventCallback;
	void *eventUserInfo;
	void *notificationCallback;
	void *notificationUserInfo;
	void *layoutCallback;
	void *layoutUserInfo;
	void *responderCallback;
	void *responderUserInfo;
	void *hitTestCallback;
	void *hitTestUserInfo;
	void *willRemoveSubviewCallback;
};

#import <WebKit/WebDataSource.h>
#import <WebKit/WebView.h>
#import <WebKit/WebFrame.h>
#import <WebKit/WebPreferences.h>

// if activate these lines, can't compile this..... I disgust a warning msg.

#import <WebCore/DOMHTMLDocument.h>
#import <WebCore/DOMHTMLElement-DOMHTMLElementExtensions.h>

@interface ThreadView : UIView/*UIScroller*/ {
	UIWebView			*uiWebView_;
	UIScroller			*scroller_;
	
	UINavigationBar*	bar_;
	id					parentController_;
	
	BOOL				isMakingHTML_;
	BOOL				hasFinishedMakingHTML_;
	
	//
    int resourceCount_;
    int resourceCompletedCount_;
    int resourceFailedCount_;
}
//- (BOOL) respondsToSelector:(SEL) selector;
- (id) initWithFrame:(CGRect) frame  withParentController:(id)fp;
- (id) uiWebView;
- (void) setUpNavigationBar;

- (void)webView:(WebView*)sender didStartProvisionalLoadForFrame:(WebFrame*)frame;
- (id)webView:(WebView*)sender identifierForInitialRequest:(NSURLRequest*)request fromDataSource:(WebDataSource*)dataSource;
- (void)webView:(WebView*)sender resource:(id)identifier didFailLoadingWithError:(NSError*)error fromDataSource:(WebDataSource*)dataSource;
- (void)webView:(WebView*)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource*)dataSource;
- (void) view:(id)view didDrawInRect:(CGRect)rect duration:(float)duration;
- (void) view:(id)view didSetFrame:(CGRect)currentRect oldFrame:(CGRect)oldRect;
/*
- (BOOL) respondsToSelector:(SEL) selector;
*/
- (void) open2chURLwith2tch:(NSURL*) url;
- (void) controlSyndicator;
- (void) openThreadView:(NSNotification *)notification;
- (void) lostFocus:(id) fp;
- (void) load:(NSString*)str;
- (void) makeHTML:(id)path;
- (void) cancelMakingHTMLThread:(NSNotification *)notification ;
//- (void)postNotificationName:(NSString *) n;
- (NSString*) makeWeb:(NSString*)source;
- (id) navibar;
@end
