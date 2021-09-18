
#import "ThreadController.h"
#import "FavouriteThreadView.h"
#import "ThreadCell.h"
#import "global.h"

@implementation FavouriteThreadView

- (void) setupNavigationBar {
	// navigation bar
	CGRect sizeNavigationBar = CGRectMake(0, 0, 320, 44);
	UINavigationBar*bar = [[[UINavigationBar alloc] initWithFrame:sizeNavigationBar] autorelease];
	NSString *titleBackButton = NSLocalizedString( @"fabouriteThreadNaviBarLeft", nil );
	[bar showButtonsWithLeftTitle:titleBackButton rightTitle:nil leftBack:YES];
	[bar setBarStyle:5];
	[bar setDelegate:self];
	NSString *title = [UIApp boardTitle];
	naviTitle_ = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
	[bar pushNavigationItem: naviTitle_];
	[self addSubview:bar];
}

// UINavigationbar's delegate

- (void) navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button {
	switch (button) {
		case 0: // right
			break;
		case 1:	// left
			[self doBookmark];
			[[UIApp view] showFavouriteViewWithTransition:TRANSITION_VIEW_BACK fromView:self];
			break;
	}
}

// original method

- (void) setupButton {
	int i;
	int tag = 1;
	int style = 0;
	int type = 0;
	
	CGRect sizeButtonBar = CGRectMake(0, 416, 320, 44);
	
	NSMutableArray *ary = [NSMutableArray array];
	[ary addObject: [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget, 
		@"onPushBack", kUIButtonBarButtonAction, 
		@"b4_preveous_66.png", kUIButtonBarButtonInfo, 
		[NSNumber numberWithUnsignedInt:tag++], kUIButtonBarButtonTag, 
		[NSNumber numberWithUnsignedInt:style], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:type], kUIButtonBarButtonType,
		[NSValue valueWithSize:NSMakeSize(0., 0.)], kUIButtonBarButtonInfoOffset, 
		nil]
	];
	[ary addObject: [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget, 
		@"onPushReload", kUIButtonBarButtonAction, 
		@"b4_reload_67.png", kUIButtonBarButtonInfo, 
		[NSNumber numberWithUnsignedInt:tag++], kUIButtonBarButtonTag, 
		[NSNumber numberWithUnsignedInt:style], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:type], kUIButtonBarButtonType,
		[NSValue valueWithSize:NSMakeSize(0., 0.)], kUIButtonBarButtonInfoOffset, 
		nil]
	];
	[ary addObject: [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget, 
		@"onPushGotoLast", kUIButtonBarButtonAction, 
		@"b4_tail_67.png", kUIButtonBarButtonInfo,
		[NSNumber numberWithUnsignedInt:style], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:type], kUIButtonBarButtonType,
		[NSNumber numberWithUnsignedInt:tag++], kUIButtonBarButtonTag, 
		[NSValue valueWithSize:NSMakeSize(0., 0.)], kUIButtonBarButtonInfoOffset, 
		nil]
	];
	[ary addObject: [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget, 
		@"onPushForward", kUIButtonBarButtonAction, 
		@"b4_next_66.png", kUIButtonBarButtonInfo,
		[NSNumber numberWithUnsignedInt:style], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:type], kUIButtonBarButtonType,
		[NSNumber numberWithUnsignedInt:tag++], kUIButtonBarButtonTag, 
		[NSValue valueWithSize:NSMakeSize(0., 0.)], kUIButtonBarButtonInfoOffset, 
		nil]
	];
	
	id buttonBar = [[[UIButtonBar alloc] initInView:self withFrame:sizeButtonBar withItemList:ary] autorelease];
	
	int* buttons = (int*)malloc(sizeof( int ) * tag );
	for( i = 1; i < tag; i++ )
		buttons[i-1] = i;
	
	[buttonBar registerButtonGroup:1 withButtons:buttons withCount:tag-1	];
	[buttonBar showButtonGroup:1 withDuration:0.2];
	free( buttons );
	[self addSubview:buttonBar];
}

@end
