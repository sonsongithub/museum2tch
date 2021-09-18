
#import <GraphicsServices/GraphicsServices.h>
#import "MainView.h"
#import "MainController.h"
#import "global.h"

@implementation MainView

- (id) initWithFrame:(CGRect)frame withParentController:(id)fp {
	self = [super initWithFrame:frame];

	currentView_ = nil;
	previousView_ = nil;
	
	parentController_ = fp;
	
	currentView_ = nil;//[parentController_ categoryView];
	
	buttonDictionary_ = [[NSMutableDictionary dictionary] retain];
	
	id center = [NSNotificationCenter defaultCenter];

	transitionView_	= [[UITransitionView alloc] initWithFrame:CGRectMake(0, 44, 320, 372)];	// 416
	[transitionView_ setDelegate:self];
	[self addSubview:transitionView_];
	
	[self setUpUnderNavigationBar];
	[self setUpNavigationBar];
	
	// notification
    [center addObserver:self 
			selector:@selector(wiilForwardToView:)
			name:@"wiilForwardToView"
			object:nil];
    [center addObserver:self 
			selector:@selector(wiilBackToView:)
			name:@"wiilBackToView"
			object:nil];
			
	
	return self;
}

- (id) currentView {
	return currentView_;
}

- (id) buttonDictionary {
	return buttonDictionary_;
}

- (id) underNavigationbar {
	return underBar_;
}

- (id) navigationbar {
	return bar_;
}

- (void) dealloc {
	[buttonDictionary_ release];
	[super dealloc];
}

- (void) setUpUnderNavigationBar {
	CGRect sizeNavigationBar = CGRectMake( 0, 416, 320, 44);
	// navigation bar
	id bar = [[[UINavigationBar alloc] initWithFrame:sizeNavigationBar] autorelease];
	[bar enableAnimation];
	[bar setDelegate:self/*parentController_*/];
	underBar_ = bar;
	[self addSubview:bar];
	
	//
	UIPushButton* pushButton;
	UIImage* btnImage;
	CGSize size;
	
	int button_num = 4;
	float y_center = 22.0f;
	int margin = 320 / ( button_num );
	int x_pos = margin/2;
	
	pushButton = [[UIPushButton alloc] initWithTitle:nil autosizesToFit:YES];
	btnImage = [UIImage imageAtPath:[[NSBundle mainBundle] pathForResource:@"bookmark" ofType:@"png" inDirectory:@"/"]];
	size = [btnImage size];
	size.width *= 2.0;
	size.height *= 2.0;
	[pushButton setFrame: CGRectMake( x_pos - size.width/2, y_center - size.height/2, size.width, size.height)];
	x_pos += margin;
	[pushButton setDrawsShadow: YES];
	[pushButton setEnabled:YES];  //may not be needed
	[pushButton setBackground:btnImage forState:0];  //up state
	[pushButton setShowPressFeedback:YES];
	[bar addSubview:pushButton];
	[pushButton addTarget:parentController_ action:@selector(buttonEvent:) forEvents:255];
	[buttonDictionary_ setObject:pushButton forKey:@"bookmarkButton"];

	pushButton = [[UIPushButton alloc] initWithTitle:nil autosizesToFit:YES];
	btnImage = [UIImage imageAtPath:[[NSBundle mainBundle] pathForResource:@"add" ofType:@"png" inDirectory:@"/"]];
	[pushButton setBackground:btnImage forState:0];  //up state
	btnImage = [UIImage imageAtPath:[[NSBundle mainBundle] pathForResource:@"add_disable" ofType:@"png" inDirectory:@"/"]];
	[pushButton setBackground:btnImage forState:2];  //disable state
	size = [btnImage size];
	size.width *= 2.0;
	size.height *= 2.0;
	[pushButton setFrame: CGRectMake( x_pos - size.width/2, y_center - size.height/2, size.width, size.height)];
	x_pos += margin;
	[pushButton setDrawsShadow: YES];
	[pushButton setEnabled:NO];
	[pushButton setShowPressFeedback:YES];
	[pushButton addTarget:parentController_ action:@selector(buttonEvent:) forEvents:255];
	[bar addSubview:pushButton];
	[buttonDictionary_ setObject:pushButton forKey:@"addButton"];
	
	pushButton = [[UIPushButton alloc] initWithTitle:nil autosizesToFit:YES];
	btnImage = [UIImage imageAtPath:[[NSBundle mainBundle] pathForResource:@"up" ofType:@"png" inDirectory:@"/"]];
	[pushButton setBackground:btnImage forState:0];  //up state
	btnImage = [UIImage imageAtPath:[[NSBundle mainBundle] pathForResource:@"up_disable" ofType:@"png" inDirectory:@"/"]];
	[pushButton setBackground:btnImage forState:2];  //disable state
	size = [btnImage size];
	size.width *= 2.0;
	size.height *= 2.0;
	[pushButton setFrame: CGRectMake( x_pos - size.width/2, y_center - size.height/2, size.width, size.height)];
	x_pos += margin;
	[pushButton setDrawsShadow: YES];
	[pushButton setEnabled:NO];
	[pushButton setShowPressFeedback:YES];
	[pushButton addTarget:parentController_ action:@selector(buttonEvent:) forEvents:255];
	[bar addSubview:pushButton];
	[buttonDictionary_ setObject:pushButton forKey:@"upButton"];
	
	pushButton = [[UIPushButton alloc] initWithTitle:nil autosizesToFit:YES];
	btnImage = [UIImage imageAtPath:[[NSBundle mainBundle] pathForResource:@"down" ofType:@"png" inDirectory:@"/"]];
	[pushButton setBackground:btnImage forState:0];  //up state
	btnImage = [UIImage imageAtPath:[[NSBundle mainBundle] pathForResource:@"down_disable" ofType:@"png" inDirectory:@"/"]];
	[pushButton setBackground:btnImage forState:2];  //disable state
	size = [btnImage size];
	size.width *= 2.0;
	size.height *= 2.0;
	[pushButton setFrame: CGRectMake( x_pos - size.width/2, y_center - size.height/2, size.width, size.height)];
	x_pos += margin;
	[pushButton setDrawsShadow: YES];
	[pushButton setEnabled:NO];
	[pushButton setShowPressFeedback:YES];
	[pushButton addTarget:parentController_ action:@selector(buttonEvent:) forEvents:255];
	[bar addSubview:pushButton];
	[buttonDictionary_ setObject:pushButton forKey:@"downButton"];
}

- (void) setThreadViewButtonEnabled:(BOOL)fp {
	[[buttonDictionary_ objectForKey:@"downButton"] setEnabled:fp];
	[[buttonDictionary_ objectForKey:@"upButton"] setEnabled:fp];
	[[buttonDictionary_ objectForKey:@"addButton"] setEnabled:fp];
}

- (void) barPushEvent:(id)fp {
	NSLog( @"aa" );
}
/*
- (void) buttonEvent:(id)button {
	if ([button isPressed])
		return;
	if( button == [buttonDictionary_ objectForKey:@"upButton"] ) {
		if( currentView_ == [parentController_ threadView] )
			[[parentController_ threadView] pageBackward];
	}
	else if( button == [buttonDictionary_ objectForKey:@"downButton"] ) {
		if( currentView_ == [parentController_ threadView] )
			[[parentController_ threadView] pageForward];
	}
	else if( button == [buttonDictionary_ objectForKey:@"reloadButton"] ) {
		DNSLog( @"MainView - reloadButton - %@", currentView_ );
		if( [currentView_ respondsToSelector:@selector( reload )] ) {
			[currentView_ reload];
		}
	}
	else if( button == [buttonDictionary_ objectForKey:@"bookmarkButton"] ) {
		[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"wiilOpenBKView"
				object:self];
	}
	else if( button == [buttonDictionary_ objectForKey:@"addButton"] ) {
		id dict = [[parentController_ datFile] datInfo];
		[[NSNotificationCenter defaultCenter] 
		postNotificationName:@"addBookmark"
		object:dict];
		
	}
}
*/
- (void) setUpNavigationBar {
	CGRect sizeNavigationBar = CGRectMake(0, 0, 320, 44);
	// navigation bar
	bar_ = [[[UINavigationBar alloc] initWithFrame:sizeNavigationBar] autorelease];
	[bar_ enableAnimation];
	
	[bar_ setTapDelegate:parentController_];
	
	[bar_ setDelegate:self/*parentController_*/];
	
	NSString *title = NSLocalizedString( @"categoryNaviBarTitle", nil );
	barTitle_ = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
	[bar_ pushNavigationItem: barTitle_];
	[self addSubview:bar_];
	
	float y_center = 22.0f;
	UIPushButton* pushButton = [[UIPushButton alloc] initWithTitle:nil autosizesToFit:YES];
	UIImage* btnImage = [UIImage imageAtPath:[[NSBundle mainBundle] pathForResource:@"reload" ofType:@"png" inDirectory:@"/"]];
	CGSize size = [btnImage size];
	size.width *= 2.0;
	size.height *= 2.0;
	[pushButton setFrame: CGRectMake( 320 - 25 - size.width/2, y_center - size.height/2, size.width, size.height)];
	[pushButton setDrawsShadow: YES];
	[pushButton setEnabled:YES];  //may not be needed
//	[pushButton setStretchBackground:YES];
	[pushButton setBackground:btnImage forState:0];  //up state
	[pushButton setShowPressFeedback:YES];
	[pushButton addTarget:parentController_ action:@selector(buttonEvent:) forEvents:255];
	[bar_ addSubview:pushButton];
	
	[buttonDictionary_ setObject:pushButton forKey:@"reloadButton"];
}
- (void)navigationBar:(UINavigationBar*)navigationBar poppedItem:(UINavigationItem*)item {
	if( currentView_ == [parentController_ boardView] ) {
		[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"wiilBackToView"
				object:[parentController_ categoryView]];
	
	}
	if( currentView_ == [parentController_ threadTitleView] ) {
		[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"wiilBackToView"
				object:[parentController_ boardView]];
	
	}
	if( currentView_ == [parentController_ threadView] ) {
		[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"wiilBackToView"
				object:previousView_];
	}
}

- (void) setNavigationBarToView:(id)to FromView:(id)from {
	// forward
	if( to == [parentController_ boardView] ) {
		id title = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
		[title setTitle:[parentController_ currentCategoryName]];
		[bar_ pushNavigationItem:title];
	}
	if( to == [parentController_ threadTitleView] ) {
		id title = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
		[title setTitle:[parentController_ currentBoardName]];
		[bar_ pushNavigationItem:title];
	}
	if( to == [parentController_ threadView] ) {
		id title = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
		[title setTitle:[parentController_ currentThreadTitle]];
		[bar_ pushNavigationItem:title];
	}
}

/*
- (void) navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button {
	if( currentView_ == [parentController_ categoryView] || currentView_ == nil )
	if( navbar == bar_ ) {
		// make alert sheet
		id sheet = [[[UIAlertSheet alloc] initWithFrame:CGRectMake(0, 240, 320, 240)] autorelease];
		[sheet setTitle:NSLocalizedString( @"appName", nil )];
		[sheet setBodyText:NSLocalizedString( @"version", nil ) ];
		[sheet addButtonWithTitle:NSLocalizedString( @"okMsg", nil ) ];
		[sheet setRunsModal:NO];
		[sheet setAlertSheetStyle:0];
		[sheet setDelegate: UIApp ];
		//[sheet popupAlertAnimated: TRUE];
		[sheet presentSheetInView: self ];
	}
}
*/
- (void)transitionViewDidStart:(UITransitionView*)view {
	if( currentView_ == [parentController_ categoryView] || currentView_ == nil )
		[bar_ hideButtons];
}

- (void)transitionViewDidComplete:(UITransitionView*)view fromView:(UIView*)from toView:(UIView*)to {
	if( to != nil )	// set view state
		currentView_ = to;
	if( from != nil )
		previousView_ = from;
		
	if( currentView_ == [parentController_ categoryView] || currentView_ == nil )
		[bar_ showButtonsWithLeftTitle:NSLocalizedString( @"categoryNaviBarLeft", nil ) rightTitle:nil];
		
	if( [from respondsToSelector:@selector( lostFocus:)] )
		[from lostFocus:self];
		
	// set under navigationbar
	if( to == [parentController_ threadView] )
		[self setThreadViewButtonEnabled:YES];
	else
		[self setThreadViewButtonEnabled:NO];
}

- (void) wiilForwardToView:(NSNotification *)notification {
	id toView = [notification object];
	
	if( [toView respondsToSelector:@selector( didForwardAndGotFocus:)] )
		[toView didForwardAndGotFocus:self];
	
	if( toView != currentView_ ) {
		[self setNavigationBarToView:toView FromView:currentView_];
	
		[transitionView_ transition:1 toView:toView];
	}
}

- (void) wiilBackToView:(NSNotification *)notification {
	id toView = [notification object];
	
	if( [toView respondsToSelector:@selector( didBackAndGotFocus:)] )
		[toView didBackAndGotFocus:self];
	
	[transitionView_ transition:2 toView:toView];
}

@end
