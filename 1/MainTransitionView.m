
#import "MainTransitionView.h"
#import "global.h"

@implementation MainTransitionView

- (id)initWithFrame:(CGRect)frame {
	CGRect  screenRect;
	screenRect = [UIHardware fullScreenApplicationContentRect];
	screenRect.origin.x = screenRect.origin.y = 0.0f;
	
	self = [super initWithFrame:screenRect];
	[self setDelegate:self];
	
	return self;
}

- (void) dealloc {
	[categoryView_ release];
	[boardView_ release];
	[threadIndexView_ release];
	[threadView_ release];
	[favouriteView_ release];
	[favouriteThreadView_ release];
	[super dealloc];
}

// delegate

- (void)transitionViewDidComplete:(UITransitionView*)view fromView:(UIView*)from toView:(UIView*)to {
	if( view != self )
		return;
	if( from == threadIndexView_ && to == boardView_ ) {
		[threadIndexView_ release];
		threadIndexView_ = nil;
	}
	else if( from == threadIndexView_ && to == threadView_ ) {
	}
	else if( from == threadView_ && to == threadIndexView_ ) {
		[threadView_ release];
		threadView_ = nil;
	}
	else if( from == favouriteThreadView_ && to == favouriteView_ ) {
		[favouriteThreadView_ release];
		favouriteThreadView_ = nil;
	}
	else if( from == favouriteView_ && to == categoryView_ ) {
		[favouriteView_ release];
		favouriteView_ = nil;
	}
	else if( from == preferenceView_ ) {
		preferenceView_ = nil;
	}
}

// transite to category view

- (void) showCategoryViewWithTransition:(int)trans fromView:(UIView*)from {
	if ( !categoryView_) {
		CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;
		categoryView_ = [[CategoryView alloc] initWithFrame:rect];
	}
	[self transition:trans toView:categoryView_];
}

// transite to board view

- (void) showBoardViewWithTransition:(int)trans fromView:(UIView*)from {
	if ( !boardView_ ) {
		CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;
		boardView_ = [[BoardView alloc] initWithFrame:rect];
	}
	else {
		[boardView_ reload];
	}
	[self transition:trans fromView:from toView:boardView_];
}

- (void) showThreadIndexViewWithTransition:(int)trans fromView:(UIView*)from {
	if ( !threadIndexView_ ) {
		CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;
		threadIndexView_ = [[ThreadIndexView alloc] initWithFrame:rect];
	}
	if( trans == TRANSITION_VIEW_FORWARD ) {
		[UIApp showProgressHUD:@"Loading..."];
		spinnerDuration_ = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(openThreadIndex) userInfo:from repeats:NO];
	}
	else {
		[self transition:TRANSITION_VIEW_BACK fromView:from toView:threadIndexView_];
	}
}

- (void) openThreadIndex {
	id from = [spinnerDuration_ userInfo];
	if( [threadIndexView_ open] ) {
		[self transition:TRANSITION_VIEW_FORWARD fromView:from toView:threadIndexView_];
	}
	else {
		[UIApp showStandardAlertWithError:NSLocalizedString( @"threadTitleError", nil )];
	}
	[UIApp hideProgressHUD];
}

- (void) showThreadViewWithTransition:(int)trans fromView:(UIView*)from {
	if (!threadView_) {
		CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;
		threadView_ = [[ThreadView alloc] initWithFrame:rect];
	}
	[UIApp showProgressHUD:@"Loading..."];
	spinnerDuration_ = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(openThreadView) userInfo:from repeats:NO];
}

- (void) openThreadView {
	id from = [spinnerDuration_ userInfo];
	if( [threadView_ open] ) {
		[self transition:TRANSITION_VIEW_FORWARD fromView:from toView:threadView_];
	}
	else {
		[UIApp showStandardAlertWithError:NSLocalizedString( @"threadError", nil )];
	}
	[UIApp hideProgressHUD];
}

// original method for transition view

- (void) showFavouriteViewWithTransition:(int)trans fromView:(UIView*)from{
	if ( !favouriteView_ ) {
		CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;
		favouriteView_ = [[FavouriteView alloc] initWithFrame:rect];
	}
	if( trans == TRANSITION_VIEW_FORWARD ) {
		[UIApp showProgressHUD:@"Loading..."];
		spinnerDuration_ = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(openFavouriteView) userInfo:from repeats:NO];
	}
	else {
		[self transition:TRANSITION_VIEW_BACK fromView:from toView:favouriteView_];
	}
}

- (void) openFavouriteView {
	id from = [spinnerDuration_ userInfo];
	if( [favouriteView_ open] ) {
		[self transition:TRANSITION_VIEW_FORWARD fromView:from toView:favouriteView_];
	}
	else {
		[UIApp showStandardAlertWithError:NSLocalizedString( @"favouriteError", nil )];
	}
	[UIApp hideProgressHUD];
}

- (void) showFavouriteThreadViewWithTransition:(int)trans fromView:(UIView*)from{
	if ( !favouriteThreadView_ ) {
		CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;
		favouriteThreadView_ = [[FavouriteThreadView alloc] initWithFrame:rect];
	}
	[UIApp showProgressHUD:@"Loading..."];
	spinnerDuration_ = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(openFavouriteThreadView) userInfo:from repeats:NO];
}

- (void) openFavouriteThreadView {
	id from = [spinnerDuration_ userInfo];
	if( [favouriteThreadView_ open] ) {
		[self transition:TRANSITION_VIEW_FORWARD fromView:from toView:favouriteThreadView_];
	}
	else {
		[UIApp showStandardAlertWithError:NSLocalizedString( @"favouriteError", nil )];
	}
	[UIApp hideProgressHUD];
}

- (void) showPreferenceViewWithTransition:(int)trans fromView:(UIView*)from {
	if ( !preferenceView_ ) {
		CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;
		preferenceView_ = [[[PreferenceView alloc] initWithFrame:rect] autorelease];
	}
	[self transition:TRANSITION_VIEW_FORWARD fromView:from toView:preferenceView_];
}

// for a view which will reload itself
// callback, open method

- (void) showLoadingAfterReloadAndSendOpenMethodToDelegate:(id)delegate {
	[UIApp showProgressHUD:@"Loading..." ];
	[NSTimer scheduledTimerWithTimeInterval:0.02 target:delegate selector:@selector(open) userInfo:nil repeats:NO];
}

- (void) showLoadingAfterReloadAndSendReloadMethodToDelegate:(id)delegate {
	[UIApp showProgressHUD:@"Loading..." ];
	[NSTimer scheduledTimerWithTimeInterval:0.02 target:delegate selector:@selector(reload) userInfo:nil repeats:NO];
}

- (BOOL) saveFarourite {
	if( favouriteView_ )
		[favouriteView_ backupFavourite];
}

@end
