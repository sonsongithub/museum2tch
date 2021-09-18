
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIProgressHUD.h>

#import "CategoryView.h"
#import "BoardView.h"
#import "ThreadIndexView.h"
#import "ThreadView.h"
#import "MenuController.h"
#import "FavouriteView.h"
#import "FavouriteThreadView.h"
#import "PreferenceView.h"

@interface MainTransitionView : UITransitionView {
	CategoryView*			categoryView_;
	BoardView*				boardView_;
	ThreadIndexView*		threadIndexView_;
	ThreadView*				threadView_;
	FavouriteView*			favouriteView_;
	FavouriteThreadView*	favouriteThreadView_;
	PreferenceView*			preferenceView_;
	NSTimer*				spinnerDuration_;
}
- (void) transitionViewDidComplete:(UITransitionView*)view fromView:(UIView*)from toView:(UIView*)to;

- (void) showCategoryViewWithTransition:(int)trans fromView:(UIView*)from;
- (void) showBoardViewWithTransition:(int)trans fromView:(UIView*)from;

- (void) showThreadIndexViewWithTransition:(int)trans fromView:(UIView*)from;
- (void) openThreadIndex;

- (void) showThreadViewWithTransition:(int)trans fromView:(UIView*)from;
- (void) openThreadView;

- (void) showFavouriteViewWithTransition:(int)trans fromView:(UIView*)from;
- (void) openFavouriteView;

- (void) showFavouriteThreadViewWithTransition:(int)trans fromView:(UIView*)from;
- (void) openFavouriteThreadView;

- (void) showLoadingAfterReloadAndSendOpenMethodToDelegate:(id)delegate;
- (void) showLoadingAfterReloadAndSendReloadMethodToDelegate:(id)delegate;

- (BOOL) saveFarourite;

- (void) showPreferenceViewWithTransition:(int)trans fromView:(UIView*)from;
@end
