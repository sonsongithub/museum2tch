
#import "MyApp.h"
#import "ThreadController.h"

#ifdef _OUTPUT_TO_LOG
	void NSLogToFile( NSString *str ) {
		[UIApp outputLog:str];
	}
#endif

@implementation MyApp

// override

- (void) applicationDidFinishLaunching: (id) unused {
#ifdef _OUTPUT_TO_LOG
	[self deleteLogFile];
#endif
	// Get screen rect
	CGRect  screenRect;
	screenRect = [UIHardware fullScreenApplicationContentRect];
	screenRect.origin.x = screenRect.origin.y = 0.0f;
		
	// Create window
	window_ = [[UIWindow alloc] initWithContentRect:screenRect];
	transitionView_ = [[UITransitionView alloc] initWithFrame:screenRect];
	[transitionView_ setDelegate:self];
	mainView_ = [[UIView alloc] initWithFrame:screenRect];
	
	// Set content view
	[mainView_ addSubview:transitionView_];
	[window_ setContentView:mainView_];
		
	//
	menuCon_ = [[MenuController alloc] initWithUserLibraryPath:[self preferencePath]];
	[menuCon_ retain];
	
	// make preferencse path	
	NSString *preferencePath = [self preferencePath];
	[[NSFileManager defaultManager] createDirectoryAtPath:preferencePath attributes:nil];
	DNSLog( @"Main - User's prefernce path - %@.", preferencePath );
	
	// Show window
	[window_ orderFront:self];
	[window_ makeKey:self];
	[window_ _setHidden:NO];
	[self showCategoryViewWithTransition:1];
}

// original method

- (NSString*) preferencePath {
	return [[[self userLibraryDirectory] stringByAppendingPathComponent: @"Preferences"] stringByAppendingPathComponent: @"com.sonson.2chviewer"];
}

- (id) menuController {
	return menuCon_;
}

// original method for transition view

- (void) showCategoryViewWithTransition:(int)trans {
	if (!categoryView_) {
		CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;
		categoryView_ = [[CategoryView alloc] initWithFrame:rect];
	}
	[transitionView_ transition:trans toView:categoryView_];
	DNSLog( @"Main - TransitionView - CategoryView." );
}

- (void) showBoardViewWithTransition:(int)trans {
	if (!boardView_) {
		CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;
		boardView_ = [[BoardView alloc] initWithFrame:rect withMainControllerId:self];
	}
	else {
		[boardView_ reload];
	}
	[transitionView_ transition:trans toView:boardView_];
	DNSLog( @"Main - TransitionView - BoardView." );
}

- (void) showBoardViewWithTransition:(int)trans fromView:(id)from{
	if (!boardView_) {
		CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;
		boardView_ = [[BoardView alloc] initWithFrame:rect withMainControllerId:self];
	}
	else {
		[boardView_ reload];
	}
	[transitionView_ transition:trans fromView:from toView:boardView_];
	DNSLog( @"Main - TransitionView - BoardView." );
}

- (void) showThreadIndexViewWithTransition:(int)trans andURL:(NSString*)url {
	if (!threadIndexView_) {
		CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;
		threadIndexView_ = [[ThreadIndexView alloc] initWithFrame:rect withMainControllerId:self];
	}
	if( trans == TRANSITION_VIEW_FORWARD ) {
		[self showProgressHUD:@"Loading..." withWindow:window_ withView:mainView_ withRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];
		spinnerDuration_ = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(reloadThreadIndex) userInfo:url repeats:NO];
	}
	else {
		[transitionView_ transition:TRANSITION_VIEW_BACK toView:threadIndexView_];
		DNSLog( @"Main - TransitionView - ThreadIndexView." );
	}
}

- (void) showThreadIndexViewWithTransition:(int)trans andURL:(NSString*)url fromView:(id)from{
	if (!threadIndexView_) {
		CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;
		threadIndexView_ = [[ThreadIndexView alloc] initWithFrame:rect withMainControllerId:self];
	}
	if( trans == TRANSITION_VIEW_FORWARD ) {
		[self showProgressHUD:@"Loading..." withWindow:window_ withView:mainView_ withRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];
		spinnerDuration_ = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(reloadThreadIndex) userInfo:url repeats:NO];
	}
	else {
		[transitionView_ transition:TRANSITION_VIEW_BACK fromView:from toView:threadIndexView_];
		DNSLog( @"Main - TransitionView - ThreadIndexView." );
	}
}

- (void) reloadThreadIndex {
	NSString *url = [spinnerDuration_ userInfo];
	if( [threadIndexView_ reload:url] ) {
		[transitionView_ transition:TRANSITION_VIEW_FORWARD toView:threadIndexView_];
		DNSLog( @"Main - TransitionView - ThreadIndexView." );
	}
	else {
		NSString *closeCaption = [NSString stringWithUTF8String:"閉じる"];
		NSString *errorCaption = [NSString stringWithUTF8String:"この板は読めませんでした"];
		[self showStandardAlertWithString:@"2chViewer" closeBtnTitle:closeCaption withError:errorCaption];
	}
	[self hideProgressHUD];
}

- (void) showThreadViewWithTransition:(int)trans andURL:(NSString*)url {
	if (!threadView_) {
		CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;
		threadView_ = [[ThreadView alloc] initWithFrame:rect];
	}
	[self showProgressHUD:@"Loading..." withWindow:window_ withView:mainView_ withRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];
	spinnerDuration_ = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(reloadThread) userInfo:url repeats:NO];
}

- (void) reloadThread {
	NSString *url = [spinnerDuration_ userInfo];
	if( [threadView_ reload:url] ) {
		[transitionView_ transition:TRANSITION_VIEW_FORWARD toView:threadView_];
		DNSLog( @"Main - TransitionView - ThreadView." );
	}
	else {
		NSString *closeCaption = [NSString stringWithUTF8String:"閉じる"];
		NSString *errorCaption = [NSString stringWithUTF8String:"このスレッドは読めませんでした"];
		[self showStandardAlertWithString:@"2chViewer" closeBtnTitle:closeCaption withError:errorCaption];
	}
	[self hideProgressHUD];
	DNSLog( @"Main - Hide already progress window." );
}

// delegate method

- (void)transitionViewDidComplete:(UITransitionView*)view fromView:(UIView*)from toView:(UIView*)to {
	DNSLog( @"Main - transitionViewDidComplete fromView toView" );
	if( from == threadView_ && to == threadIndexView_ ) {
		DNSLog( @"Main - back to thread index view" );
		[threadView_ releaseCache];
	}
	else if( from == threadIndexView_ && to == boardView_ ) {
		DNSLog( @"Main - back to thread board view" );
		[threadIndexView_ releaseCache];
	}
}

// Progress window and message window

- (void)showProgressHUD:(NSString *)label withWindow:(UIWindow *)w withView:(UIView *)v withRect:(struct CGRect)rect {
	progressSpinner_ = [[UIProgressHUD alloc] initWithWindow: w];
	[progressSpinner_ setText: label];
	[progressSpinner_ drawRect: rect];
	[progressSpinner_ show: YES];
	[v addSubview:progressSpinner_];
}

- (void) showStandardAlertWithString:(NSString *)title closeBtnTitle:(NSString *)closeTitle withError:(NSString *)error {
	id alertButton = [NSArray arrayWithObjects:@"Close",nil];
	id alert = [[UIAlertSheet alloc] initWithTitle:title buttons:alertButton defaultButtonIndex:0 delegate:self context:nil];
	[alert setBodyText: error];
	[alert popupAlertAnimated: TRUE];
}

- (void) alertSheet: (UIAlertSheet*)sheet buttonClicked:(int)button {
	[sheet dismissAnimated: TRUE];
}

- (void)hideProgressHUD {
	[progressSpinner_ show: NO];
	[progressSpinner_ removeFromSuperview];
}

#ifdef _OUTPUT_TO_LOG

- (void) deleteLogFile {
	NSString *path = [NSString stringWithFormat:@"%@/%@",[self preferencePath], @"log.txt"];
	int char_num = strlen( [path UTF8String] );
	char* filename = (char*)malloc ( sizeof(char) * char_num );
	memcpy( filename, [path UTF8String], char_num );
	FILE *fp = fopen( filename, "w" );
	fclose( fp );
	free( filename );
}

- (void) outputLog:(NSString*)str {
	NSString *path = [NSString stringWithFormat:@"%@/%@",[self preferencePath], @"log.txt"];
	int char_num = strlen( [path UTF8String] );
	char* filename = (char*)malloc ( sizeof(char) * char_num );
	memcpy( filename, [path UTF8String], char_num );
	char_num = strlen( [str UTF8String] );
	char* msg =(char*)malloc ( sizeof(char) * char_num );
	memcpy( msg, [str UTF8String], char_num );
	FILE *fp = fopen( filename, "a" );
	fprintf( fp, "%s\n", msg );
	fclose( fp );
	free( filename );
	free( msg );
}

#endif

@end
