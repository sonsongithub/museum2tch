#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIProgressHUD.h>

#import "invariables.h"
#import "CategoryView.h"
#import "BoardView.h"
#import "ThreadIndexView.h"
#import "ThreadView.h"
#import "MenuController.h"

@interface MyApp : UIApplication {
	UIWindow*				window_;
	UITransitionView*		transitionView_;
	UIView*					mainView_;
	id						categoryView_;
	id						boardView_;
	id						threadIndexView_;
	id						threadView_;
	
	NSTimer*				spinnerDuration_;
	id						progressSpinner_;
	id						menuCon_;
}
// delegate message
- (void) applicationDidFinishLaunching: (id) unused;
// original method
- (NSString*) preferencePath;
- (id) menuController;
// original method for transition view
- (void) showCategoryViewWithTransition:(int)trans;
- (void) showBoardViewWithTransition:(int)trans;
- (void) showBoardViewWithTransition:(int)trans fromView:(id)from;
- (void) showThreadIndexViewWithTransition:(int)trans andURL:(NSString*)url;
- (void) showThreadIndexViewWithTransition:(int)trans andURL:(NSString*)url fromView:(id)from;
- (void) reloadThreadIndex;
- (void) showThreadViewWithTransition:(int)trans andURL:(NSString*)url;
- (void) reloadThread;
// delegate method
- (void) transitionViewDidComplete:(UITransitionView*)view fromView:(UIView*)from toView:(UIView*)to;
// Progress window and message window
- (void) showProgressHUD:(NSString *)label withWindow:(UIWindow *)w withView:(UIView *)v withRect:(struct CGRect)rect;
- (void) showStandardAlertWithString:(NSString *)title closeBtnTitle:(NSString *)closeTitle withError:(NSString *)error;
- (void) alertSheet: (UIAlertSheet*)sheet buttonClicked:(int)button;
- (void) hideProgressHUD;
#ifdef _OUTPUT_TO_LOG
- (void) deleteLogFile;
- (void) outputLog:(NSString*)str;
#endif
@end
