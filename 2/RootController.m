
#import "RootController.h"
#import "MainController.h"
#import "BKMainController.h"
#import "MainView.h"
#import "global.h"

@implementation RootController

- (id) init {

	self = [super init];
	
	CGRect  screenRect = [UIHardware fullScreenApplicationContentRect];
	screenRect.origin.x = 0;	screenRect.origin.y = 0;
	rootView_ = [[UITransitionView alloc] initWithFrame:screenRect];
	
	mainController_ = [[MainController alloc] init];	
	[rootView_ addSubview:[mainController_ view]];
	
	bkMainController_ = [[BKMainController alloc] init];
	
	
	// notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(wiilOpenBKView:)
			name:@"wiilOpenBKView"
			object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(wiilCloseBKView:)
			name:@"wiilCloseBKView"
			object:nil];
	
	return self;
}

- (void) wiilOpenBKView:(NSNotification *)notification {
	[rootView_ transition:8 toView:[bkMainController_ view]];
	[bkMainController_ reloadTables];
}

- (void) wiilCloseBKView:(NSNotification *)notification {
	[rootView_ transition:9 toView:[mainController_ view]];
}

- (void) dealloc {
	[super dealloc];
}

- (id) view {
	return rootView_;
}

@end
